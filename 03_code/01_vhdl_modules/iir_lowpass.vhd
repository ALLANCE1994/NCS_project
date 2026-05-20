-- ============================================================================
-- IIR低通滤波器模块 - M3.5阶段实现
-- IIR Lowpass Filter for NV Center ODMR
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.5 IIR低通滤波器
-- 【知识来源】《ZYNQ 硬件工程知识库》- 数字信号处理与IIR滤波器设计
-- 【设计原则】小步快跑：二阶节级联，Q15定点系数
-- ============================================================================
-- 【Feature Flag】FEATURE_IIR_LOWPASS - 控制IIR滤波器使能/禁用
--   默认值：'1'（使能）
--   用途：L1回滚防线，出现问题时可快速禁用IIR功能
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 实体定义
-- ============================================================================
entity iir_lowpass is
    generic (
        -- Feature Flag：IIR滤波器使能开关（L1回滚防线）
        FEATURE_IIR_LOWPASS : std_logic := '1';
        
        -- 数据位宽
        DATA_WIDTH      : integer := 16;
        -- 系数位宽（Q15定点）
        COEFF_WIDTH     : integer := 16;
        -- 内部累加器位宽（防止溢出）
        ACC_WIDTH       : integer := 32
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
        
        -- =====================================================================
        -- 系数配置（Q15定点格式）
        -- =====================================================================
        -- 默认系数：二阶巴特沃斯低通，fc=10kHz@100MHz
        -- 可通过AXI寄存器动态配置
        coeff_a1        : in  std_logic_vector(COEFF_WIDTH-1 downto 0);  -- 反馈a1
        coeff_a2        : in  std_logic_vector(COEFF_WIDTH-1 downto 0);  -- 反馈a2
        coeff_b0        : in  std_logic_vector(COEFF_WIDTH-1 downto 0);  -- 前馈b0
        coeff_b1        : in  std_logic_vector(COEFF_WIDTH-1 downto 0);  -- 前馈b1
        coeff_b2        : in  std_logic_vector(COEFF_WIDTH-1 downto 0);  -- 前馈b2
        
        -- =====================================================================
        -- 数据接口
        -- =====================================================================
        data_in         : in  std_logic_vector(DATA_WIDTH-1 downto 0);   -- 输入数据
        data_valid      : in  std_logic;                                 -- 输入有效
        
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);   -- 输出数据
        out_valid       : out std_logic                                  -- 输出有效
    );
end entity iir_lowpass;

-- ============================================================================
-- 架构定义
-- ============================================================================
architecture rtl of iir_lowpass is

    -- ========================================================================
    -- Feature Flag 控制
    -- ========================================================================
    signal iir_active : std_logic;
    
    -- ========================================================================
    -- 二阶节内部信号（直接II型实现）
    -- ========================================================================
    -- 延迟线寄存器
    signal w_reg      : signed(ACC_WIDTH-1 downto 0);  -- 中间节点
    signal w_d1       : signed(ACC_WIDTH-1 downto 0);  -- w(n-1)
    signal w_d2       : signed(ACC_WIDTH-1 downto 0);  -- w(n-2)
    
    -- 系数寄存器（有符号）
    signal a1_signed  : signed(COEFF_WIDTH-1 downto 0);
    signal a2_signed  : signed(COEFF_WIDTH-1 downto 0);
    signal b0_signed  : signed(COEFF_WIDTH-1 downto 0);
    signal b1_signed  : signed(COEFF_WIDTH-1 downto 0);
    signal b2_signed  : signed(COEFF_WIDTH-1 downto 0);
    
    -- 乘法结果（扩展位宽：ACC_WIDTH + COEFF_WIDTH = 48位）
    signal mult_a1    : signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0);
    signal mult_a2    : signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0);
    signal mult_b0    : signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0);
    signal mult_b1    : signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0);
    signal mult_b2    : signed(ACC_WIDTH+COEFF_WIDTH-1 downto 0);
    
    -- 累加结果
    signal w_next     : signed(ACC_WIDTH-1 downto 0);
    signal y_out      : signed(ACC_WIDTH-1 downto 0);
    
    -- 输出寄存
    signal data_reg   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal valid_reg  : std_logic;

begin

    -- ========================================================================
    -- Feature Flag 控制逻辑（L1回滚防线）
    -- ========================================================================
    iir_active <= enable when FEATURE_IIR_LOWPASS = '1' else '0';

    -- ========================================================================
    -- 系数转换（无符号输入转有符号）
    -- ========================================================================
    a1_signed <= signed(coeff_a1);
    a2_signed <= signed(coeff_a2);
    b0_signed <= signed(coeff_b0);
    b1_signed <= signed(coeff_b1);
    b2_signed <= signed(coeff_b2);

    -- ========================================================================
    -- 延迟线更新（时序逻辑）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            w_reg  <= (others => '0');
            w_d1   <= (others => '0');
            w_d2   <= (others => '0');
        elsif rising_edge(clk) then
            if iir_active = '1' and data_valid = '1' then
                w_reg <= w_next;
                w_d1  <= w_reg;
                w_d2  <= w_d1;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 反馈路径计算（直接II型）
    -- w(n) = x(n) - a1*w(n-1) - a2*w(n-2)
    -- ========================================================================
    mult_a1 <= w_d1 * a1_signed;
    mult_a2 <= w_d2 * a2_signed;
    
    -- 注意：Q15系数需要右移15位
    w_next <= resize(signed(data_in), ACC_WIDTH) 
              - resize(shift_right(mult_a1, 15), ACC_WIDTH)
              - resize(shift_right(mult_a2, 15), ACC_WIDTH);

    -- ========================================================================
    -- 前馈路径计算
    -- y(n) = b0*w(n) + b1*w(n-1) + b2*w(n-2)
    -- ========================================================================
    mult_b0 <= w_reg * b0_signed;
    mult_b1 <= w_d1 * b1_signed;
    mult_b2 <= w_d2 * b2_signed;
    
    y_out <= resize(shift_right(mult_b0, 15), ACC_WIDTH)
             + resize(shift_right(mult_b1, 15), ACC_WIDTH)
             + resize(shift_right(mult_b2, 15), ACC_WIDTH);

    -- ========================================================================
    -- 输出处理（限幅和格式化）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            data_reg  <= (others => '0');
            valid_reg <= '0';
        elsif rising_edge(clk) then
            valid_reg <= '0';
            
            if iir_active = '1' and data_valid = '1' then
                -- 限幅到16位范围
                if y_out > to_signed(2**(DATA_WIDTH-1)-1, ACC_WIDTH) then
                    data_reg <= std_logic_vector(to_signed(2**(DATA_WIDTH-1)-1, DATA_WIDTH));
                elsif y_out < to_signed(-(2**(DATA_WIDTH-1)), ACC_WIDTH) then
                    data_reg <= std_logic_vector(to_signed(-(2**(DATA_WIDTH-1)), DATA_WIDTH));
                else
                    data_reg <= std_logic_vector(resize(y_out, DATA_WIDTH));
                end if;
                
                valid_reg <= '1';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出端口连接
    -- ========================================================================
    data_out  <= data_reg;
    out_valid <= valid_reg;

end architecture rtl;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第4章 数字信号处理 - IIR滤波器设计与实现
-- - 关键内容：直接II型结构、Q15定点系数、溢出处理
-- 
-- 【设计参数】
-- - 系统时钟：100MHz
-- - 滤波器类型：二阶IIR（可级联实现高阶）
-- - 系数格式：Q15定点（-1.0到+0.99997）
-- - 数据位宽：16位输入/输出
-- - 内部位宽：32位（防止乘法溢出）
-- 
-- 【默认系数】（二阶巴特沃斯低通，fc=10kHz@100MHz采样率）
-- - b0 = 0.000944 * 32768 = 31  (0x001F)
-- - b1 = 0.001888 * 32768 = 62  (0x003E)
-- - b2 = 0.000944 * 32768 = 31  (0x001F)
-- - a1 = -1.9112  * 32768 = -62640 (0x0C70 - 需要符号处理)
-- - a2 = 0.91498  * 32768 = 29982 (0x751E)
-- ============================================================================
