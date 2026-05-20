-- ============================================================================
-- CORDIC数字锁相模块 - M3.3阶段实现
-- CORDIC Lock-in Amplifier for NV Center ODMR
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.3 CORDIC数字锁相
-- 【知识来源】《ZYNQ 硬件工程知识库》- CORDIC算法与数字信号处理
-- 【设计原则】小步快跑：基础CORDIC实现，后续迭代优化
-- ============================================================================
-- 【Feature Flag】FEATURE_CORDIC_LIA - 控制CORDIC锁相使能/禁用
--   默认值：'1'（使能）
--   用途：L1回滚防线，出现问题时可快速禁用CORDIC功能
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- ============================================================================
-- 实体定义
-- ============================================================================
entity cordic_lia is
    generic (
        -- Feature Flag：CORDIC锁相使能开关（L1回滚防线）
        FEATURE_CORDIC_LIA : std_logic := '1';
        
        -- 数据位宽
        DATA_WIDTH      : integer := 16;
        -- CORDIC迭代次数（决定精度）
        ITERATIONS      : integer := 12;
        -- 内部计算位宽（防止溢出）
        INTERNAL_WIDTH  : integer := 20;
        -- 相位输出位宽
        PHASE_WIDTH     : integer := 16
    );
    port (
        -- =====================================================================
        -- 系统接口
        -- =====================================================================
        clk             : in  std_logic;    -- 系统时钟（100MHz）
        rst_n           : in  std_logic;    -- 复位，低电平有效
        
        -- =====================================================================
        -- 控制接口
        -- =====================================================================
        enable          : in  std_logic;    -- 模块使能
        start           : in  std_logic;    -- 开始计算
        
        -- =====================================================================
        -- 输入数据（来自ADC）
        -- =====================================================================
        adc_data        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        adc_valid       : in  std_logic;    -- ADC数据有效
        
        -- =====================================================================
        -- 参考信号（来自DDS）
        -- =====================================================================
        ref_sin         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- 参考正弦
        ref_cos         : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- 参考余弦
        ref_valid       : in  std_logic;    -- 参考信号有效
        
        -- =====================================================================
        -- 解调输出
        -- =====================================================================
        magnitude       : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- 幅值
        phase           : out std_logic_vector(PHASE_WIDTH-1 downto 0); -- 相位
        output_valid    : out std_logic;    -- 输出有效
        
        -- =====================================================================
        -- 状态输出
        -- =====================================================================
        busy            : out std_logic     -- 计算中指示
    );
end entity cordic_lia;

-- ============================================================================
-- 架构定义
-- ============================================================================
architecture rtl of cordic_lia is

    -- ========================================================================
    -- Feature Flag 控制
    -- ========================================================================
    signal cordic_active : std_logic;
    
    -- ========================================================================
    -- CORDIC参数（arctan(2^-i) * 2^16 / (2*pi)，16位定点）
    -- ========================================================================
    type atan_table_type is array (0 to ITERATIONS-1) of signed(15 downto 0);
    constant ATAN_TABLE : atan_table_type := (
        X"2000",  -- atan(2^0) = 45.0 deg
        X"12E4",  -- atan(2^-1) = 26.565 deg
        X"09FB",  -- atan(2^-2) = 14.036 deg
        X"0511",  -- atan(2^-3) = 7.125 deg
        X"028B",  -- atan(2^-4) = 3.576 deg
        X"0146",  -- atan(2^-5) = 1.790 deg
        X"00A3",  -- atan(2^-6) = 0.895 deg
        X"0051",  -- atan(2^-7) = 0.448 deg
        X"0029",  -- atan(2^-8) = 0.224 deg
        X"0014",  -- atan(2^-9) = 0.112 deg
        X"000A",  -- atan(2^-10) = 0.056 deg
        X"0005"   -- atan(2^-11) = 0.028 deg
    );
    
    -- CORDIC增益补偿（1/CORDIC增益 ≈ 0.60725，16位定点）
    constant GAIN_COMP : signed(15 downto 0) := X"4DB9";
    
    -- ========================================================================
    -- 状态机定义
    -- ========================================================================
    type state_type is (IDLE, MULT_SIN, MULT_COS, CORDIC_ITER, OUTPUT);
    signal state : state_type;
    signal next_state : state_type;
    
    -- ========================================================================
    -- 乘法器信号（锁相检测：信号×参考）
    -- ========================================================================
    signal x_sin        : signed(INTERNAL_WIDTH-1 downto 0);  -- X = signal * sin
    signal y_cos        : signed(INTERNAL_WIDTH-1 downto 0);  -- Y = signal * cos
    signal mult_valid   : std_logic;
    
    -- ========================================================================
    -- CORDIC迭代信号
    -- ========================================================================
    signal x_reg        : signed(INTERNAL_WIDTH-1 downto 0);
    signal y_reg        : signed(INTERNAL_WIDTH-1 downto 0);
    signal z_reg        : signed(PHASE_WIDTH-1 downto 0);
    signal iter_cnt     : unsigned(3 downto 0);
    
    -- 迭代计算中间值
    signal x_shift      : signed(INTERNAL_WIDTH-1 downto 0);
    signal y_shift      : signed(INTERNAL_WIDTH-1 downto 0);
    
    -- ========================================================================
    -- 输出寄存
    -- ========================================================================
    signal mag_reg      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal phase_reg    : std_logic_vector(PHASE_WIDTH-1 downto 0);
    signal valid_reg    : std_logic;

begin

    -- ========================================================================
    -- Feature Flag 控制逻辑（L1回滚防线）
    -- ========================================================================
    cordic_active <= enable when FEATURE_CORDIC_LIA = '1' else '0';

    -- ========================================================================
    -- 状态机（时序逻辑）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    -- 状态机（组合逻辑）
    process(state, cordic_active, start, adc_valid, ref_valid, iter_cnt)
    begin
        next_state <= state;
        
        case state is
            when IDLE =>
                if cordic_active = '1' and start = '1' and adc_valid = '1' and ref_valid = '1' then
                    next_state <= MULT_SIN;
                end if;
                
            when MULT_SIN =>
                next_state <= MULT_COS;
                
            when MULT_COS =>
                next_state <= CORDIC_ITER;
                
            when CORDIC_ITER =>
                if iter_cnt = ITERATIONS-1 then
                    next_state <= OUTPUT;
                end if;
                
            when OUTPUT =>
                next_state <= IDLE;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- ========================================================================
    -- 乘法器：信号×参考（锁相检测）
    -- ========================================================================
    process(clk, rst_n)
        variable mult_temp : signed(2*DATA_WIDTH-1 downto 0);
    begin
        if rst_n = '0' then
            x_sin <= (others => '0');
            y_cos <= (others => '0');
            mult_valid <= '0';
        elsif rising_edge(clk) then
            mult_valid <= '0';
            
            if state = MULT_SIN then
                -- X = adc_data * ref_sin（取高16位）
                mult_temp := signed(adc_data) * signed(ref_sin);
                x_sin <= resize(mult_temp(2*DATA_WIDTH-2 downto DATA_WIDTH-1), INTERNAL_WIDTH);
            elsif state = MULT_COS then
                -- Y = adc_data * ref_cos（取高16位）
                mult_temp := signed(adc_data) * signed(ref_cos);
                y_cos <= resize(mult_temp(2*DATA_WIDTH-2 downto DATA_WIDTH-1), INTERNAL_WIDTH);
                mult_valid <= '1';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- CORDIC迭代（向量模式：计算幅值和相位）
    -- ========================================================================
    process(clk, rst_n)
        variable x_new : signed(INTERNAL_WIDTH-1 downto 0);
        variable y_new : signed(INTERNAL_WIDTH-1 downto 0);
        variable z_new : signed(PHASE_WIDTH-1 downto 0);
    begin
        if rst_n = '0' then
            x_reg <= (others => '0');
            y_reg <= (others => '0');
            z_reg <= (others => '0');
            iter_cnt <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when MULT_COS =>
                    -- 初始化CORDIC寄存器
                    if mult_valid = '1' then
                        x_reg <= x_sin;
                        y_reg <= y_cos;
                        z_reg <= (others => '0');
                        iter_cnt <= (others => '0');
                    end if;
                    
                when CORDIC_ITER =>
                    -- CORDIC迭代：旋转使Y趋近于0
                    if y_reg > 0 then
                        -- 顺时针旋转
                        x_new := x_reg + y_shift;
                        y_new := y_reg - x_shift;
                        z_new := z_reg + resize(ATAN_TABLE(to_integer(iter_cnt)), PHASE_WIDTH);
                    else
                        -- 逆时针旋转
                        x_new := x_reg - y_shift;
                        y_new := y_reg + x_shift;
                        z_new := z_reg - resize(ATAN_TABLE(to_integer(iter_cnt)), PHASE_WIDTH);
                    end if;
                    
                    x_reg <= x_new;
                    y_reg <= y_new;
                    z_reg <= z_new;
                    iter_cnt <= iter_cnt + 1;
                    
                when others =>
                    iter_cnt <= (others => '0');
            end case;
        end if;
    end process;
    
    -- 移位操作（算术右移）
    x_shift <= shift_right(x_reg, to_integer(iter_cnt));
    y_shift <= shift_right(y_reg, to_integer(iter_cnt));

    -- ========================================================================
    -- 输出处理（增益补偿和格式化）
    -- ========================================================================
    process(clk, rst_n)
        variable mag_temp : signed(INTERNAL_WIDTH+16-1 downto 0);  -- x_reg(20位) * GAIN_COMP(16位) = 36位
        variable mag_comp : signed(INTERNAL_WIDTH-1 downto 0);
    begin
        if rst_n = '0' then
            mag_reg <= (others => '0');
            phase_reg <= (others => '0');
            valid_reg <= '0';
        elsif rising_edge(clk) then
            valid_reg <= '0';
            
            if state = OUTPUT then
                -- 幅值：X * 增益补偿（CORDIC增益 ≈ 1.647，需要补偿）
                mag_temp := x_reg * GAIN_COMP;
                mag_comp := mag_temp(INTERNAL_WIDTH+16-1 downto INTERNAL_WIDTH-4);  -- 提取20位(35 downto 16)
                
                -- 限幅和格式化输出
                if mag_comp > to_signed(2**(DATA_WIDTH-1)-1, INTERNAL_WIDTH) then
                    mag_reg <= std_logic_vector(to_signed(2**(DATA_WIDTH-1)-1, DATA_WIDTH));
                elsif mag_comp < to_signed(-(2**(DATA_WIDTH-1)), INTERNAL_WIDTH) then
                    mag_reg <= std_logic_vector(to_signed(-(2**(DATA_WIDTH-1)), DATA_WIDTH));
                else
                    mag_reg <= std_logic_vector(resize(mag_comp, DATA_WIDTH));
                end if;
                
                -- 相位：直接输出（已归一化到±π）
                phase_reg <= std_logic_vector(z_reg);
                
                valid_reg <= '1';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出端口连接
    -- ========================================================================
    magnitude    <= mag_reg;
    phase        <= phase_reg;
    output_valid <= valid_reg;
    busy         <= '1' when state /= IDLE else '0';

end architecture rtl;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第4章 数字信号处理 - CORDIC算法原理与实现
-- - 关键内容：旋转模式CORDIC、向量模式CORDIC、arctan查找表
-- 
-- 【设计参数】
-- - 系统时钟：100MHz
-- - 迭代次数：12次（精度约0.1度）
-- - 数据位宽：16位输入，20位内部计算
-- - 相位范围：-π 到 +π（16位定点表示）
-- - 延迟：约15个时钟周期（2乘法 + 12迭代 + 1输出）
-- ============================================================================
