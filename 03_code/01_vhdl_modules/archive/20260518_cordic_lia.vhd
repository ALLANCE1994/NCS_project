--------------------------------------------------------------------------------
-- Module: cordic_lia
-- Description: CORDIC数字锁相放大器 - ODMR信号解调
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
-- 归档原因：一步到位实现，违反小步快跑原则，将在M3.3重新开发
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_lia is
    generic (
        DATA_WIDTH     : integer := 16;
        ITERATIONS     : integer := 16
    );
    port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        signal_in     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        ref_in        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        input_valid   : in  std_logic;
        lia_en        : in  std_logic;
        magnitude      : out std_logic_vector(31 downto 0);
        phase_out     : out std_logic_vector(31 downto 0);
        output_valid  : out std_logic;
        data_ready    : out std_logic
    );
end entity;

architecture rtl of cordic_lia is
    signal mix_x       : signed(31 downto 0);
    type x_reg_type is array (0 to ITERATIONS) of signed(31 downto 0);
    type y_reg_type is array (0 to ITERATIONS) of signed(31 downto 0);
    type z_reg_type is array (0 to ITERATIONS) of signed(31 downto 0);
    signal x_reg       : x_reg_type;
    signal y_reg       : y_reg_type;
    signal z_reg       : z_reg_type;
    signal iter_cnt    : unsigned(4 downto 0);
    signal rot_valid   : std_logic;
    signal mag_reg     : signed(31 downto 0);
    signal phase_reg   : signed(31 downto 0);
    signal valid_reg   : std_logic;
    
    type angle_table_type is array (0 to ITERATIONS-1) of signed(31 downto 0);
    constant ANGLE_TABLE : angle_table_type := (
        to_signed(134217728, 32), to_signed(79457195, 32),
        to_signed(42093041, 32), to_signed(21043727, 32),
        to_signed(10536035, 32), to_signed(5272519, 32),
        to_signed(2637126, 32), to_signed(1318696, 32),
        to_signed(659354, 32), to_signed(329682, 32),
        to_signed(164842, 32), to_signed(82421, 32),
        to_signed(41210, 32), to_signed(20605, 32),
        to_signed(10303, 32), to_signed(5151, 32)
    );
    
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            mix_x <= (others => '0');
        elsif rising_edge(clk) then
            if input_valid = '1' and lia_en = '1' then
                mix_x <= resize(signed(signal_in) * signed(ref_in), 32);
            end if;
        end if;
    end process;
    
    process(clk, rst_n)
        variable y_sign : std_logic;
    begin
        if rst_n = '0' then
            for i in 0 to ITERATIONS loop
                x_reg(i) <= (others => '0');
                y_reg(i) <= (others => '0');
                z_reg(i) <= (others => '0');
            end loop;
            iter_cnt <= (others => '0');
            rot_valid <= '0';
        elsif rising_edge(clk) then
            rot_valid <= '0';
            if input_valid = '1' and lia_en = '1' then
                x_reg(0) <= resize(mix_x, 32);
                y_reg(0) <= (others => '0');
                z_reg(0) <= (others => '0');
                iter_cnt <= (others => '0');
            end if;
            if lia_en = '1' and iter_cnt < ITERATIONS then
                iter_cnt <= iter_cnt + 1;
                if iter_cnt < ITERATIONS then
                    if y_reg(iter_cnt)(31) = '1' then y_sign := '0';
                    else y_sign := '1';
                    end if;
                    if y_sign = '1' then
                        x_reg(iter_cnt+1) <= x_reg(iter_cnt) - shift_right(y_reg(iter_cnt), to_integer(iter_cnt));
                        y_reg(iter_cnt+1) <= y_reg(iter_cnt) + shift_right(x_reg(iter_cnt), to_integer(iter_cnt));
                        z_reg(iter_cnt+1) <= z_reg(iter_cnt) - ANGLE_TABLE(to_integer(iter_cnt));
                    else
                        x_reg(iter_cnt+1) <= x_reg(iter_cnt) + shift_right(y_reg(iter_cnt), to_integer(iter_cnt));
                        y_reg(iter_cnt+1) <= y_reg(iter_cnt) - shift_right(x_reg(iter_cnt), to_integer(iter_cnt));
                        z_reg(iter_cnt+1) <= z_reg(iter_cnt) + ANGLE_TABLE(to_integer(iter_cnt));
                    end if;
                end if;
                if iter_cnt = ITERATIONS - 1 then rot_valid <= '1'; end if;
            else
                iter_cnt <= (others => '0');
            end if;
        end if;
    end process;
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            mag_reg <= (others => '0');
            phase_reg <= (others => '0');
            valid_reg <= '0';
        elsif rising_edge(clk) then
            valid_reg <= '0';
            if rot_valid = '1' then
                mag_reg <= x_reg(ITERATIONS);
                phase_reg <= z_reg(ITERATIONS);
                valid_reg <= '1';
            end if;
        end if;
    end process;
    
    magnitude <= std_logic_vector(mag_reg);
    phase_out <= std_logic_vector(phase_reg);
    output_valid <= valid_reg;
    data_ready <= '1' when lia_en = '1' else '0';
end architecture;
