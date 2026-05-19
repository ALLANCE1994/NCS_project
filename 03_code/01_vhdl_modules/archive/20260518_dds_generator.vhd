--------------------------------------------------------------------------------
-- Module: dds_generator
-- Description: DDS直接数字频率合成器 - ODMR激励信号源
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
-- 归档原因：一步到位实现，违反小步快跑原则，将在M3.1重新开发
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dds_generator is
    generic (
        PHASE_WIDTH     : integer := 32;    -- 相位累加器位宽
        DATA_WIDTH      : integer := 14     -- DAC数据位宽
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        freq_ctrl       : in  std_logic_vector(PHASE_WIDTH-1 downto 0);  -- 频率控制字
        phase_offset    : in  std_logic_vector(PHASE_WIDTH-1 downto 0); -- 相位偏移
        enable          : in  std_logic;
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid      : out std_logic;
        clk_out         : out std_logic
    );
end entity dds_generator;

architecture rtl of dds_generator is
    signal phase_acc   : unsigned(PHASE_WIDTH-1 downto 0);
    signal phase_reg   : unsigned(PHASE_WIDTH-1 downto 0);
    signal rom_addr    : unsigned(11 downto 0);
    signal sin_data    : signed(13 downto 0);
    signal enable_reg  : std_logic;
    
    type sin_rom_type is array (0 to 4095) of signed(13 downto 0);
    function init_sin_rom return sin_rom_type is
        variable rom : sin_rom_type;
    begin
        for i in 0 to 4095 loop
            rom(i) := to_signed(integer(8191.0 * sin(2.0 * 3.14159265359 * real(i) / 4096.0)), 14);
        end loop;
        return rom;
    end function;
    constant SIN_ROM : sin_rom_type := init_sin_rom;
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            phase_acc <= (others => '0');
            enable_reg <= '0';
        elsif rising_edge(clk) then
            enable_reg <= enable;
            if enable = '1' then
                phase_acc <= phase_acc + unsigned(freq_ctrl);
            end if;
        end if;
    end process;
    
    phase_reg <= phase_acc + unsigned(phase_offset);
    rom_addr <= phase_reg(PHASE_WIDTH-1 downto PHASE_WIDTH-12);
    sin_data <= SIN_ROM(to_integer(rom_addr));
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            data_out <= (others => '0');
            data_valid <= '0';
        elsif rising_edge(clk) then
            data_out <= std_logic_vector(sin_data);
            data_valid <= enable_reg;
        end if;
    end process;
    
    clk_out <= clk;
end architecture rtl;
