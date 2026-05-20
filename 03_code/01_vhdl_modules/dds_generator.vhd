--------------------------------------------------------------------------------
-- Module: dds_generator
-- Description: DDS直接数字频率合成器 - ODMR激励信号源
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity dds_generator is
    generic (
        FEATURE_DDS_GENERATOR : std_logic := '1';
        PHASE_WIDTH           : integer := 32;    -- 相位累加器位宽
        DATA_WIDTH            : integer := 14;    -- DAC数据位宽
        ROM_ADDR_WIDTH        : integer := 12     -- ROM地址位宽
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        enable          : in  std_logic;
        freq_ctrl       : in  std_logic_vector(PHASE_WIDTH-1 downto 0);  -- 频率控制字
        phase_offset    : in  std_logic_vector(PHASE_WIDTH-1 downto 0); -- 相位偏移
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid_out       : out std_logic;
        clk_out         : out std_logic
    );
end entity dds_generator;

architecture rtl of dds_generator is
    signal phase_acc   : unsigned(PHASE_WIDTH-1 downto 0);
    signal phase_reg   : unsigned(PHASE_WIDTH-1 downto 0);
    signal rom_addr    : unsigned(ROM_ADDR_WIDTH-1 downto 0);
    signal sin_data    : signed(DATA_WIDTH-1 downto 0);
    signal enable_reg  : std_logic;
    signal dds_active  : std_logic;
    
    type sin_rom_type is array (0 to 2**ROM_ADDR_WIDTH-1) of signed(DATA_WIDTH-1 downto 0);
    function init_sin_rom return sin_rom_type is
        variable rom : sin_rom_type;
        constant SCALE : real := real(2**(DATA_WIDTH-1)) - 1.0;
    begin
        for i in 0 to 2**ROM_ADDR_WIDTH-1 loop
            rom(i) := to_signed(integer(SCALE * sin(2.0 * MATH_PI * real(i) / real(2**ROM_ADDR_WIDTH))), DATA_WIDTH);
        end loop;
        return rom;
    end function;
    constant SIN_ROM : sin_rom_type := init_sin_rom;
begin
    -- Feature Flag
    dds_active <= enable when FEATURE_DDS_GENERATOR = '1' else '0';

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            phase_acc <= (others => '0');
            enable_reg <= '0';
        elsif rising_edge(clk) then
            enable_reg <= dds_active;
            if dds_active = '1' then
                phase_acc <= phase_acc + unsigned(freq_ctrl);
            end if;
        end if;
    end process;
    
    phase_reg <= phase_acc + unsigned(phase_offset);
    rom_addr <= phase_reg(PHASE_WIDTH-1 downto PHASE_WIDTH-ROM_ADDR_WIDTH);
    sin_data <= SIN_ROM(to_integer(rom_addr));
    
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            data_out <= (others => '0');
            valid_out <= '0';
        elsif rising_edge(clk) then
            data_out <= std_logic_vector(sin_data);
            valid_out <= enable_reg;
        end if;
    end process;
    
    clk_out <= clk;
end architecture rtl;
