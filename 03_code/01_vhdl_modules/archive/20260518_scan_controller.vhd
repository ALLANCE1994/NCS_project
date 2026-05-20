--------------------------------------------------------------------------------
-- Module: scan_controller
-- Description: ODMR频率扫描控制器
-- Author: 【@H 硬件工程师】
-- Date: 2026-05-19
-- 归档原因：一步到位实现，违反小步快跑原则，将在M3.4重新开发
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scan_controller is
    generic (
        FREQ_WIDTH      : integer := 32;
        TIME_WIDTH      : integer := 32;
        MAX_POINTS      : integer := 1024
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        freq_start      : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        freq_stop       : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        freq_step       : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        integ_time      : in  std_logic_vector(TIME_WIDTH-1 downto 0);
        wait_time       : in  std_logic_vector(TIME_WIDTH-1 downto 0);
        scan_start      : in  std_logic;
        scan_stop       : in  std_logic;
        scan_done       : out std_logic;
        scan_busy       : out std_logic;
        current_freq    : out std_logic_vector(FREQ_WIDTH-1 downto 0);
        point_cnt       : out std_logic_vector(15 downto 0);
        total_points    : out std_logic_vector(15 downto 0);
        dds_freq        : out std_logic_vector(FREQ_WIDTH-1 downto 0);
        dds_en          : out std_logic;
        adc_sample_en   : out std_logic;
        lia_en          : out std_logic;
        lia_data_in     : in  std_logic_vector(31 downto 0);
        lia_valid       : in  std_logic;
        dma_data        : out std_logic_vector(63 downto 0);
        dma_valid       : out std_logic;
        dma_ready       : in  std_logic
    );
end entity;

architecture rtl of scan_controller is
    type state_type is (
        IDLE, LOAD_PARAMS, SET_FREQ, WAIT_STABLE, INTEGRATE,
        PROCESS_DATA, STORE_RESULT, CHECK_DONE, SCAN_COMPLETE
    );
    signal state : state_type;
    
    signal freq_start_reg   : unsigned(FREQ_WIDTH-1 downto 0);
    signal freq_stop_reg    : unsigned(FREQ_WIDTH-1 downto 0);
    signal freq_step_reg    : unsigned(FREQ_WIDTH-1 downto 0);
    signal integ_time_reg   : unsigned(TIME_WIDTH-1 downto 0);
    signal wait_time_reg    : unsigned(TIME_WIDTH-1 downto 0);
    signal freq_current     : unsigned(FREQ_WIDTH-1 downto 0);
    signal point_counter    : unsigned(15 downto 0);
    signal total_points_reg : unsigned(15 downto 0);
    signal timer_counter    : unsigned(TIME_WIDTH-1 downto 0);
    signal amplitude_reg    : std_logic_vector(31 downto 0);
    signal freq_out_reg     : std_logic_vector(FREQ_WIDTH-1 downto 0);
    signal scan_active      : std_logic;
begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= IDLE;
            scan_active <= '0';
            freq_start_reg <= (others => '0');
            freq_stop_reg <= (others => '0');
            freq_step_reg <= (others => '0');
            integ_time_reg <= (others => '0');
            wait_time_reg <= (others => '0');
            freq_current <= (others => '0');
            point_counter <= (others => '0');
            total_points_reg <= (others => '0');
            timer_counter <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    scan_active <= '0';
                    dds_en <= '0';
                    adc_sample_en <= '0';
                    lia_en <= '0';
                    dma_valid <= '0';
                    scan_done <= '0';
                    if scan_start = '1' then
                        state <= LOAD_PARAMS;
                    end if;
                when LOAD_PARAMS =>
                    freq_start_reg <= unsigned(freq_start);
                    freq_stop_reg <= unsigned(freq_stop);
                    freq_step_reg <= unsigned(freq_step);
                    integ_time_reg <= unsigned(integ_time);
                    wait_time_reg <= unsigned(wait_time);
                    freq_current <= unsigned(freq_start);
                    point_counter <= (others => '0');
                    if unsigned(freq_step) /= 0 then
                        total_points_reg <= resize((unsigned(freq_stop) - unsigned(freq_start)) / unsigned(freq_step) + 1, 16);
                    else
                        total_points_reg <= to_unsigned(1, 16);
                    end if;
                    scan_active <= '1';
                    state <= SET_FREQ;
                when SET_FREQ =>
                    dds_freq <= std_logic_vector(freq_current);
                    dds_en <= '1';
                    timer_counter <= (others => '0');
                    state <= WAIT_STABLE;
                when WAIT_STABLE =>
                    if timer_counter >= wait_time_reg then
                        timer_counter <= (others => '0');
                        state <= INTEGRATE;
                    else
                        timer_counter <= timer_counter + 1;
                    end if;
                when INTEGRATE =>
                    adc_sample_en <= '1';
                    lia_en <= '1';
                    if timer_counter >= integ_time_reg then
                        timer_counter <= (others => '0');
                        adc_sample_en <= '0';
                        lia_en <= '0';
                        state <= PROCESS_DATA;
                    else
                        timer_counter <= timer_counter + 1;
                    end if;
                when PROCESS_DATA =>
                    if lia_valid = '1' then
                        amplitude_reg <= lia_data_in;
                        freq_out_reg <= std_logic_vector(freq_current);
                        state <= STORE_RESULT;
                    end if;
                when STORE_RESULT =>
                    dma_data <= freq_out_reg & amplitude_reg;
                    dma_valid <= '1';
                    if dma_ready = '1' then
                        dma_valid <= '0';
                        state <= CHECK_DONE;
                    end if;
                when CHECK_DONE =>
                    if freq_current >= freq_stop_reg then
                        state <= SCAN_COMPLETE;
                    elsif scan_stop = '1' then
                        state <= SCAN_COMPLETE;
                    else
                        freq_current <= freq_current + freq_step_reg;
                        point_counter <= point_counter + 1;
                        state <= SET_FREQ;
                    end if;
                when SCAN_COMPLETE =>
                    scan_active <= '0';
                    scan_done <= '1';
                    dds_en <= '0';
                    if scan_start = '0' then
                        state <= IDLE;
                    end if;
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
    
    scan_busy <= scan_active;
    current_freq <= std_logic_vector(freq_current);
    point_cnt <= std_logic_vector(point_counter);
    total_points <= std_logic_vector(total_points_reg);
end architecture;
