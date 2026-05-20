--------------------------------------------------------------------------------
-- Module: adc_interface
-- Description: ADC采集接口 - NV荧光信号数字化
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_interface is
    generic (
        FEATURE_ADC_INTERFACE : std_logic := '1';
        ADC_WIDTH             : integer := 14;
        DATA_WIDTH            : integer := 16;
        FIFO_DEPTH            : integer := 16;
        FIFO_ADDR_WIDTH       : integer := 4
    );
    port (
        -- ADC Clock Domain
        adc_clk       : in  std_logic;
        adc_rst_n     : in  std_logic;
        adc_data_in   : in  std_logic_vector(ADC_WIDTH-1 downto 0);
        adc_valid_in  : in  std_logic;
        adc_ovr_in    : in  std_logic;
        
        -- System Clock Domain
        sys_clk       : in  std_logic;
        sys_rst_n     : in  std_logic;
        enable        : in  std_logic;
        fifo_clear    : in  std_logic;
        
        -- Data Output
        data_out      : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid    : out std_logic;
        
        -- FIFO Status
        fifo_empty    : out std_logic;
        fifo_full     : out std_logic;
        fifo_count    : out std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
        
        -- Overflow Status
        overflow_flag : out std_logic;
        overflow_cnt  : out std_logic_vector(15 downto 0)
    );
end entity adc_interface;

architecture rtl of adc_interface is
    signal adc_data_sync   : std_logic_vector(ADC_WIDTH-1 downto 0);
    signal adc_valid_sync  : std_logic_vector(2 downto 0);
    signal adc_ovr_sync    : std_logic_vector(2 downto 0);
    signal fifo_we         : std_logic;
    signal fifo_din        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_full_int   : std_logic;
    signal fifo_empty_int  : std_logic;
    signal fifo_cnt_int    : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal overflow_reg    : std_logic;
    signal overflow_count  : unsigned(15 downto 0);
    signal adc_active      : std_logic;
    signal rst_n_combined  : std_logic;
begin
    -- Feature Flag and combined reset
    adc_active <= enable when FEATURE_ADC_INTERFACE = '1' else '0';
    rst_n_combined <= sys_rst_n and adc_rst_n;

    -- CDC: 异步ADC时钟域到系统时钟域
    process(adc_clk, adc_rst_n)
    begin
        if adc_rst_n = '0' then
            adc_data_sync <= (others => '0');
            adc_valid_sync <= (others => '0');
            adc_ovr_sync <= (others => '0');
        elsif rising_edge(adc_clk) then
            adc_data_sync <= adc_data_in;
            adc_valid_sync <= adc_valid_sync(1 downto 0) & adc_valid_in;
            adc_ovr_sync <= adc_ovr_sync(1 downto 0) & adc_ovr_in;
        end if;
    end process;
    
    -- FIFO写控制（简化实现）
    process(sys_clk, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            fifo_we <= '0';
            fifo_din <= (others => '0');
            fifo_cnt_int <= (others => '0');
        elsif rising_edge(sys_clk) then
            fifo_we <= '0';
            
            if fifo_clear = '1' then
                fifo_cnt_int <= (others => '0');
            elsif adc_active = '1' and adc_valid_sync(2) = '1' then
                if fifo_cnt_int < FIFO_DEPTH then
                    fifo_we <= '1';
                    -- 符号扩展或零扩展ADC数据到DATA_WIDTH
                    if ADC_WIDTH < DATA_WIDTH then
                        fifo_din <= (DATA_WIDTH-1 downto ADC_WIDTH => adc_data_sync(ADC_WIDTH-1)) & adc_data_sync;
                    elsif ADC_WIDTH > DATA_WIDTH then
                        fifo_din <= adc_data_sync(ADC_WIDTH-1 downto ADC_WIDTH-DATA_WIDTH);
                    else
                        fifo_din <= adc_data_sync;
                    end if;
                    fifo_cnt_int <= fifo_cnt_int + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- 溢出检测
    process(sys_clk, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            overflow_reg <= '0';
            overflow_count <= (others => '0');
        elsif rising_edge(sys_clk) then
            if fifo_clear = '1' then
                overflow_reg <= '0';
                overflow_count <= (others => '0');
            else
                overflow_reg <= adc_ovr_sync(2);
                if adc_ovr_sync(2) = '1' and overflow_reg = '0' then
                    overflow_count <= overflow_count + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- FIFO输出（简化实现，直接输出）
    data_out <= fifo_din;
    data_valid <= fifo_we;
    
    -- FIFO状态
    fifo_empty_int <= '1' when fifo_cnt_int = 0 else '0';
    fifo_full_int <= '1' when fifo_cnt_int >= FIFO_DEPTH else '0';
    
    fifo_empty <= fifo_empty_int;
    fifo_full <= fifo_full_int;
    fifo_count <= std_logic_vector(fifo_cnt_int);
    
    overflow_flag <= overflow_reg;
    overflow_cnt <= std_logic_vector(overflow_count);
    
end architecture rtl;
