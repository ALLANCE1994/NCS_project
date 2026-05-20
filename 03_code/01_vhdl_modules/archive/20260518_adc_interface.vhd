--------------------------------------------------------------------------------
-- Module: adc_interface
-- Description: ADC采集接口 - NV荧光信号数字化
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
-- 归档原因：一步到位实现，违反小步快跑原则，将在M3.2重新开发
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_interface is
    generic (
        DATA_WIDTH      : integer := 16;
        BURST_SIZE      : integer := 256
    );
    port (
        -- Clock and Reset
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        
        -- ADC Interface
        adc_clk         : in  std_logic;
        adc_data        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        adc_valid       : in  std_logic;
        adc_ovr         : in  std_logic;
        
        -- Data Output (跨时钟域)
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid      : out std_logic;
        
        -- Control
        sample_en       : in  std_logic;
        decimation      : in  std_logic_vector(15 downto 0);
        
        -- Status
        adc_overflow    : out std_logic
    );
end entity adc_interface;

architecture rtl of adc_interface is
    signal adc_data_sync   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal adc_valid_sync  : std_logic_vector(2 downto 0);
    signal adc_ovr_sync    : std_logic_vector(2 downto 0);
    signal decimation_cnt  : unsigned(15 downto 0);
    signal fifo_we         : std_logic;
    signal fifo_din        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_full       : std_logic;
begin
    -- CDC: 异步ADC时钟域到系统时钟域
    process(adc_clk, rst_n)
    begin
        if rst_n = '0' then
            adc_data_sync <= (others => '0');
            adc_valid_sync <= (others => '0');
            adc_ovr_sync <= (others => '0');
        elsif rising_edge(adc_clk) then
            adc_data_sync <= adc_data;
            adc_valid_sync <= adc_valid_sync(1 downto 0) & adc_valid;
            adc_ovr_sync <= adc_ovr_sync(1 downto 0) & adc_ovr;
        end if;
    end process;
    
    -- Decimation分频
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            decimation_cnt <= (others => '0');
            fifo_we <= '0';
            fifo_din <= (others => '0');
        elsif rising_edge(clk) then
            fifo_we <= '0';
            if sample_en = '1' and adc_valid_sync(2) = '1' then
                if decimation_cnt >= unsigned(decimation) - 1 then
                    decimation_cnt <= (others => '0');
                    fifo_we <= not fifo_full;
                    fifo_din <= adc_data_sync;
                else
                    decimation_cnt <= decimation_cnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- FIFO输出
    data_out <= fifo_din;
    data_valid <= fifo_we;
    adc_overflow <= adc_ovr_sync(2);
    fifo_full <= '0';  -- 占位，实际使用时实例化FIFO IP
    
end architecture rtl;
