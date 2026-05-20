--------------------------------------------------------------------------------
-- Module: cordic_lia
-- Description: CORDIC数字锁相放大器 - ODMR信号解调
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_lia is
    generic (
        FEATURE_CORDIC_LIA : std_logic := '1';
        DATA_WIDTH         : integer := 16;
        ITERATIONS         : integer := 12;
        INTERNAL_WIDTH     : integer := 20;
        PHASE_WIDTH        : integer := 16
    );
    port (
        clk          : in  std_logic;
        rst_n        : in  std_logic;
        enable       : in  std_logic;
        start        : in  std_logic;
        adc_data     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        adc_valid    : in  std_logic;
        ref_sin      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        ref_cos      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        ref_valid    : in  std_logic;
        magnitude    : out std_logic_vector(DATA_WIDTH-1 downto 0);
        phase        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        output_valid : out std_logic;
        busy         : out std_logic
    );
end entity cordic_lia;

architecture rtl of cordic_lia is
    signal cordic_active : std_logic;
    signal busy_reg      : std_logic;
    
    -- 混频器信号
    signal mix_x         : signed(INTERNAL_WIDTH-1 downto 0);
    signal mix_y         : signed(INTERNAL_WIDTH-1 downto 0);
    signal mix_valid     : std_logic;
    
    -- CORDIC迭代寄存器
    type x_reg_type is array (0 to ITERATIONS) of signed(INTERNAL_WIDTH-1 downto 0);
    type y_reg_type is array (0 to ITERATIONS) of signed(INTERNAL_WIDTH-1 downto 0);
    type z_reg_type is array (0 to ITERATIONS) of signed(PHASE_WIDTH-1 downto 0);
    signal x_reg         : x_reg_type;
    signal y_reg         : y_reg_type;
    signal z_reg         : z_reg_type;
    signal iter_cnt      : integer range 0 to ITERATIONS;
    signal rot_valid     : std_logic;
    
    -- 输出寄存器
    signal mag_reg       : signed(INTERNAL_WIDTH-1 downto 0);
    signal phase_reg     : signed(PHASE_WIDTH-1 downto 0);
    signal valid_reg     : std_logic;
    signal processing    : std_logic;
    
    -- CORDIC角度表（arctan(2^-i)）
    type angle_table_type is array (0 to ITERATIONS-1) of signed(PHASE_WIDTH-1 downto 0);
    constant ANGLE_TABLE : angle_table_type := (
        to_signed(8192, PHASE_WIDTH),   -- 45.0 deg
        to_signed(4836, PHASE_WIDTH),   -- 26.565 deg
        to_signed(2555, PHASE_WIDTH),   -- 14.036 deg
        to_signed(1297, PHASE_WIDTH),   -- 7.125 deg
        to_signed(651, PHASE_WIDTH),    -- 3.576 deg
        to_signed(326, PHASE_WIDTH),    -- 1.790 deg
        to_signed(163, PHASE_WIDTH),    -- 0.895 deg
        to_signed(81, PHASE_WIDTH),     -- 0.448 deg
        to_signed(41, PHASE_WIDTH),     -- 0.224 deg
        to_signed(20, PHASE_WIDTH),     -- 0.112 deg
        to_signed(10, PHASE_WIDTH),     -- 0.056 deg
        to_signed(5, PHASE_WIDTH)       -- 0.028 deg
    );
    
begin
    -- Feature Flag
    cordic_active <= enable when FEATURE_CORDIC_LIA = '1' else '0';

    -- =======================================================================
    -- 混频器：ADC数据与参考信号相乘
    -- =======================================================================
    process(clk, rst_n)
        variable mix_x_full : signed(2*DATA_WIDTH-1 downto 0);
        variable mix_y_full : signed(2*DATA_WIDTH-1 downto 0);
    begin
        if rst_n = '0' then
            mix_x <= (others => '0');
            mix_y <= (others => '0');
            mix_valid <= '0';
        elsif rising_edge(clk) then
            mix_valid <= '0';
            if cordic_active = '1' and adc_valid = '1' and ref_valid = '1' then
                -- X通道：ADC * ref_sin
                mix_x_full := signed(adc_data) * signed(ref_sin);
                mix_x <= resize(shift_right(mix_x_full, DATA_WIDTH-INTERNAL_WIDTH+DATA_WIDTH), INTERNAL_WIDTH);
                
                -- Y通道：ADC * ref_cos
                mix_y_full := signed(adc_data) * signed(ref_cos);
                mix_y <= resize(shift_right(mix_y_full, DATA_WIDTH-INTERNAL_WIDTH+DATA_WIDTH), INTERNAL_WIDTH);
                
                mix_valid <= '1';
            end if;
        end if;
    end process;
    
    -- =======================================================================
    -- CORDIC迭代核心（向量模式）
    -- =======================================================================
    process(clk, rst_n)
        variable y_sign : std_logic;
    begin
        if rst_n = '0' then
            for i in 0 to ITERATIONS loop
                x_reg(i) <= (others => '0');
                y_reg(i) <= (others => '0');
                z_reg(i) <= (others => '0');
            end loop;
            iter_cnt <= 0;
            rot_valid <= '0';
            processing <= '0';
        elsif rising_edge(clk) then
            rot_valid <= '0';
            
            -- 启动新的CORDIC计算
            if cordic_active = '1' and start = '1' and processing = '0' then
                processing <= '1';
                iter_cnt <= 0;
            elsif cordic_active = '1' and mix_valid = '1' and processing = '0' then
                x_reg(0) <= mix_x;
                y_reg(0) <= mix_y;
                z_reg(0) <= (others => '0');
                processing <= '1';
                iter_cnt <= 0;
            end if;
            
            -- CORDIC迭代
            if processing = '1' and cordic_active = '1' then
                if iter_cnt < ITERATIONS then
                    -- 判断Y的符号决定旋转方向
                    if y_reg(iter_cnt)(INTERNAL_WIDTH-1) = '1' then
                        y_sign := '0';  -- Y为负，顺时针旋转
                    else
                        y_sign := '1';  -- Y为正，逆时针旋转
                    end if;
                    
                    if y_sign = '1' then
                        x_reg(iter_cnt+1) <= x_reg(iter_cnt) + shift_right(y_reg(iter_cnt), iter_cnt);
                        y_reg(iter_cnt+1) <= y_reg(iter_cnt) - shift_right(x_reg(iter_cnt), iter_cnt);
                        z_reg(iter_cnt+1) <= z_reg(iter_cnt) + ANGLE_TABLE(iter_cnt);
                    else
                        x_reg(iter_cnt+1) <= x_reg(iter_cnt) - shift_right(y_reg(iter_cnt), iter_cnt);
                        y_reg(iter_cnt+1) <= y_reg(iter_cnt) + shift_right(x_reg(iter_cnt), iter_cnt);
                        z_reg(iter_cnt+1) <= z_reg(iter_cnt) - ANGLE_TABLE(iter_cnt);
                    end if;
                    
                    iter_cnt <= iter_cnt + 1;
                    
                    if iter_cnt = ITERATIONS - 1 then
                        rot_valid <= '1';
                        processing <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- =======================================================================
    -- 输出寄存器
    -- =======================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            mag_reg <= (others => '0');
            phase_reg <= (others => '0');
            valid_reg <= '0';
            busy_reg <= '0';
        elsif rising_edge(clk) then
            valid_reg <= '0';
            
            if cordic_active = '1' then
                busy_reg <= processing;
                
                if rot_valid = '1' then
                    -- 幅度输出（X寄存器最终值乘以CORDIC增益补偿因子 ~0.607）
                    -- x_reg是INTERNAL_WIDTH(20)位，乘3后40位，需resize回INTERNAL_WIDTH(20)位
                    mag_reg <= resize(shift_right(x_reg(ITERATIONS) * 3, 2), INTERNAL_WIDTH);
                    -- z_reg是INTERNAL_WIDTH(20)位，需截断到PHASE_WIDTH(16)位
                    phase_reg <= z_reg(ITERATIONS)(PHASE_WIDTH-1 downto 0);
                    valid_reg <= '1';
                end if;
            else
                busy_reg <= '0';
            end if;
        end if;
    end process;
    
    -- 输出映射
    magnitude <= std_logic_vector(resize(mag_reg, DATA_WIDTH));
    phase <= std_logic_vector(resize(phase_reg, DATA_WIDTH));
    output_valid <= valid_reg;
    busy <= busy_reg;
    
end architecture rtl;
