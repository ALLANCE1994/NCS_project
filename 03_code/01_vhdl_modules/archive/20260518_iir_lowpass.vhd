--------------------------------------------------------------------------------
-- Module: iir_lowpass
-- Description: IIR低通滤波器 - 提取ODMR信号包络
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
-- 归档原因：一步到位实现，违反小步快跑原则，将在M3.5重新开发
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity iir_lowpass is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        data_in     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid  : in  std_logic;
        filter_en   : in  std_logic;
        data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0);
        output_valid: out std_logic
    );
end entity;

architecture rtl of iir_lowpass is
    signal x_n        : signed(DATA_WIDTH-1 downto 0);
    signal x_n1       : signed(DATA_WIDTH-1 downto 0);
    signal y_n1       : signed(DATA_WIDTH-1 downto 0);
    signal mult_b0    : signed(DATA_WIDTH+31 downto 0);
    signal mult_b1    : signed(DATA_WIDTH+31 downto 0);
    signal mult_a1    : signed(DATA_WIDTH+31 downto 0);
    signal y_n        : signed(DATA_WIDTH+31 downto 0);
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            x_n1 <= (others => '0');
            y_n1 <= (others => '0');
        elsif rising_edge(clk) then
            if data_valid = '1' and filter_en = '1' then
                x_n <= signed(data_in);
                mult_b0 <= to_signed(8589934, 32) * x_n;
                mult_b1 <= to_signed(17179869, 32) * x_n1;
                mult_a1 <= to_signed(-8556380160, 32) * y_n1;
                y_n <= (mult_b0(DATA_WIDTH+31 downto DATA_WIDTH-8)) +
                       (mult_b1(DATA_WIDTH+31 downto DATA_WIDTH-8)) -
                       (mult_a1(DATA_WIDTH+31 downto DATA_WIDTH-8));
                x_n1 <= x_n;
                y_n1 <= y_n(DATA_WIDTH+31 downto 32);
            end if;
        end if;
    end process;
    data_out <= std_logic_vector(y_n1);
    output_valid <= data_valid;
end architecture;
