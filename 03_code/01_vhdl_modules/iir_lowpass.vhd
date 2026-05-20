--------------------------------------------------------------------------------
-- Module: iir_lowpass
-- Description: IIR低通滤波器 - 提取ODMR信号包络
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity iir_lowpass is
    generic (
        FEATURE_IIR_LOWPASS : std_logic := '1';
        DATA_WIDTH          : integer := 16;
        COEFF_WIDTH         : integer := 16;
        ACC_WIDTH           : integer := 32
    );
    port (
        clk        : in  std_logic;
        rst_n      : in  std_logic;
        enable     : in  std_logic;
        coeff_a1   : in  std_logic_vector(COEFF_WIDTH-1 downto 0);
        coeff_a2   : in  std_logic_vector(COEFF_WIDTH-1 downto 0);
        coeff_b0   : in  std_logic_vector(COEFF_WIDTH-1 downto 0);
        coeff_b1   : in  std_logic_vector(COEFF_WIDTH-1 downto 0);
        coeff_b2   : in  std_logic_vector(COEFF_WIDTH-1 downto 0);
        data_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid : in  std_logic;
        data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        out_valid  : out std_logic
    );
end entity iir_lowpass;

architecture rtl of iir_lowpass is
    signal filter_active : std_logic;
    
    -- 延迟线
    signal x_n        : signed(DATA_WIDTH-1 downto 0);
    signal x_n1       : signed(DATA_WIDTH-1 downto 0);
    signal x_n2       : signed(DATA_WIDTH-1 downto 0);
    signal y_n1       : signed(DATA_WIDTH-1 downto 0);
    signal y_n2       : signed(DATA_WIDTH-1 downto 0);
    
    -- 系数寄存器
    signal a1_reg     : signed(COEFF_WIDTH-1 downto 0);
    signal a2_reg     : signed(COEFF_WIDTH-1 downto 0);
    signal b0_reg     : signed(COEFF_WIDTH-1 downto 0);
    signal b1_reg     : signed(COEFF_WIDTH-1 downto 0);
    signal b2_reg     : signed(COEFF_WIDTH-1 downto 0);
    
    -- 乘积累加
    signal mult_b0    : signed(ACC_WIDTH-1 downto 0);
    signal mult_b1    : signed(ACC_WIDTH-1 downto 0);
    signal mult_b2    : signed(ACC_WIDTH-1 downto 0);
    signal mult_a1    : signed(ACC_WIDTH-1 downto 0);
    signal mult_a2    : signed(ACC_WIDTH-1 downto 0);
    signal acc_sum    : signed(ACC_WIDTH-1 downto 0);
    signal y_n        : signed(DATA_WIDTH-1 downto 0);
    
    -- 输出有效延迟
    signal valid_pipe : std_logic_vector(2 downto 0);
begin
    -- Feature Flag
    filter_active <= enable when FEATURE_IIR_LOWPASS = '1' else '0';

    -- 系数寄存
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            a1_reg <= (others => '0');
            a2_reg <= (others => '0');
            b0_reg <= (others => '0');
            b1_reg <= (others => '0');
            b2_reg <= (others => '0');
        elsif rising_edge(clk) then
            if filter_active = '1' then
                a1_reg <= signed(coeff_a1);
                a2_reg <= signed(coeff_a2);
                b0_reg <= signed(coeff_b0);
                b1_reg <= signed(coeff_b1);
                b2_reg <= signed(coeff_b2);
            end if;
        end if;
    end process;

    -- 主滤波器处理
    process(clk, rst_n)
        variable b0_mult : signed(DATA_WIDTH+COEFF_WIDTH-1 downto 0);
        variable b1_mult : signed(DATA_WIDTH+COEFF_WIDTH-1 downto 0);
        variable b2_mult : signed(DATA_WIDTH+COEFF_WIDTH-1 downto 0);
        variable a1_mult : signed(DATA_WIDTH+COEFF_WIDTH-1 downto 0);
        variable a2_mult : signed(DATA_WIDTH+COEFF_WIDTH-1 downto 0);
        variable sum     : signed(ACC_WIDTH-1 downto 0);
    begin
        if rst_n = '0' then
            x_n1 <= (others => '0');
            x_n2 <= (others => '0');
            y_n1 <= (others => '0');
            y_n2 <= (others => '0');
            valid_pipe <= (others => '0');
        elsif rising_edge(clk) then
            valid_pipe <= valid_pipe(1 downto 0) & '0';
            
            if filter_active = '1' and data_valid = '1' then
                -- 输入采样
                x_n <= signed(data_in);
                
                -- 计算乘法（假设系数为Q15格式，即1.15定点数）
                b0_mult := signed(data_in) * b0_reg;
                b1_mult := x_n1 * b1_reg;
                b2_mult := x_n2 * b2_reg;
                a1_mult := y_n1 * a1_reg;
                a2_mult := y_n2 * a2_reg;
                
                -- 累加（注意：IIR是y = b0*x + b1*x1 + b2*x2 - a1*y1 - a2*y2）
                sum := resize(shift_right(b0_mult, COEFF_WIDTH-1), ACC_WIDTH)
                     + resize(shift_right(b1_mult, COEFF_WIDTH-1), ACC_WIDTH)
                     + resize(shift_right(b2_mult, COEFF_WIDTH-1), ACC_WIDTH)
                     - resize(shift_right(a1_mult, COEFF_WIDTH-1), ACC_WIDTH)
                     - resize(shift_right(a2_mult, COEFF_WIDTH-1), ACC_WIDTH);
                
                -- 更新延迟线
                x_n2 <= x_n1;
                x_n1 <= signed(data_in);
                y_n2 <= y_n1;
                y_n1 <= resize(sum, DATA_WIDTH);
                
                valid_pipe(0) <= '1';
            end if;
        end if;
    end process;
    
    -- 输出
    data_out <= std_logic_vector(y_n1);
    out_valid <= valid_pipe(2);
    
end architecture rtl;
