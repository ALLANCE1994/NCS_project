-- ============================================================================
-- 频率扫描状态机模块 - M3.4阶段实现（时序优化版）
-- Frequency Scan Controller for NV Center ODMR
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.6 时序优化
-- 【知识来源】UG949 Vivado设计方法论 + KB-EXP-VIVADO-001经验知识库
-- 【设计原则】流水线打断长组合路径，目标WNS>0@50MHz
-- ============================================================================
-- 【Feature Flag】FEATURE_SCAN_CONTROLLER - 控制扫描状态机使能/禁用
--   默认值：'1'（使能）
--   用途：L1回滚防线
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity scan_controller is
    generic (
        FEATURE_SCAN_CONTROLLER : std_logic := '1';
        FREQ_WIDTH      : integer := 32;
        DWELL_WIDTH     : integer := 16;
        POINT_WIDTH     : integer := 16
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        enable          : in  std_logic;
        start_scan      : in  std_logic;
        stop_scan       : in  std_logic;
        freq_start      : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        freq_stop       : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        freq_step       : in  std_logic_vector(FREQ_WIDTH-1 downto 0);
        dwell_time      : in  std_logic_vector(DWELL_WIDTH-1 downto 0);
        total_points_in : in  std_logic_vector(POINT_WIDTH-1 downto 0);  -- 【新增】由PS端预计算传入
        dds_freq_out    : out std_logic_vector(FREQ_WIDTH-1 downto 0);
        dds_update      : out std_logic;
        acq_trigger     : out std_logic;
        acq_busy        : in  std_logic;
        scan_busy       : out std_logic;
        scan_done       : out std_logic;
        current_freq    : out std_logic_vector(FREQ_WIDTH-1 downto 0);
        point_count     : out std_logic_vector(POINT_WIDTH-1 downto 0);
        total_points    : out std_logic_vector(POINT_WIDTH-1 downto 0)
    );
end entity scan_controller;

architecture rtl of scan_controller is

    -- Feature Flag
    signal scan_active  : std_logic;

    -- 状态机
    type state_type is (IDLE, CALC_POINTS, SET_FREQ, DWELL_WAIT, CHECK_NEXT, DONE);
    signal state        : state_type;
    signal next_state   : state_type;

    -- 扫描参数寄存
    signal freq_start_reg   : unsigned(FREQ_WIDTH-1 downto 0);
    signal freq_stop_reg    : unsigned(FREQ_WIDTH-1 downto 0);
    signal freq_step_reg    : unsigned(FREQ_WIDTH-1 downto 0);
    signal dwell_time_reg   : unsigned(DWELL_WIDTH-1 downto 0);

    -- 扫描状态
    signal current_freq_reg : unsigned(FREQ_WIDTH-1 downto 0);
    signal next_freq        : unsigned(FREQ_WIDTH-1 downto 0);
    signal point_cnt        : unsigned(POINT_WIDTH-1 downto 0);
    signal total_pts        : unsigned(POINT_WIDTH-1 downto 0);
    signal dwell_cnt        : unsigned(DWELL_WIDTH-1 downto 0);

    -- ====================================================================
    -- 流水线寄存器（时序优化：打断长组合路径）
    -- ====================================================================
    -- 提前计算 next_freq + freq_step_reg，在SET_FREQ阶段完成加法
    signal next_freq_plus_step   : unsigned(FREQ_WIDTH-1 downto 0);
    signal next_freq_le_stop     : std_logic;  -- next_freq + step <= stop

    -- scan_complete 改为寄存器输出，避免组合逻辑
    signal scan_complete_reg     : std_logic;

    -- 控制信号
    signal dwell_done   : std_logic;

begin

    -- Feature Flag
    scan_active <= enable when FEATURE_SCAN_CONTROLLER = '1' else '0';

    -- ========================================================================
    -- 状态机（时序逻辑）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- 状态机（组合逻辑）
    process(state, scan_active, start_scan, stop_scan, scan_complete_reg, dwell_done, acq_busy)
    begin
        next_state <= state;

        case state is
            when IDLE =>
                if scan_active = '1' and start_scan = '1' then
                    next_state <= CALC_POINTS;
                end if;

            when CALC_POINTS =>
                next_state <= SET_FREQ;

            when SET_FREQ =>
                next_state <= DWELL_WAIT;

            when DWELL_WAIT =>
                if stop_scan = '1' then
                    next_state <= DONE;
                elsif dwell_done = '1' and acq_busy = '0' then
                    next_state <= CHECK_NEXT;
                end if;

            when CHECK_NEXT =>
                if scan_complete_reg = '1' then
                    next_state <= DONE;
                else
                    next_state <= SET_FREQ;
                end if;

            when DONE =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- ========================================================================
    -- 参数加载
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            freq_start_reg <= (others => '0');
            freq_stop_reg <= (others => '0');
            freq_step_reg <= (others => '0');
            dwell_time_reg <= (others => '0');
        elsif rising_edge(clk) then
            if state = IDLE and start_scan = '1' then
                freq_start_reg <= unsigned(freq_start);
                freq_stop_reg <= unsigned(freq_stop);
                freq_step_reg <= unsigned(freq_step);
                dwell_time_reg <= unsigned(dwell_time);
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 扫描点数加载（移除硬件除法，改为PS端预计算传入）
    -- 【时序优化】移除32位除法操作，避免238层组合逻辑深度
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            total_pts <= (others => '0');
        elsif rising_edge(clk) then
            if state = IDLE and start_scan = '1' then
                -- 直接使用PS端传入的预计算值
                total_pts <= unsigned(total_points_in);
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 频率更新（流水线优化版）
    -- ========================================================================
    -- 优化点1：在SET_FREQ阶段提前计算 next_freq + freq_step_reg
    --          打断CHECK_NEXT阶段的 32位加法+比较 组合路径
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_freq_reg <= (others => '0');
            next_freq <= (others => '0');
            next_freq_plus_step <= (others => '0');
            next_freq_le_stop <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start_scan = '1' then
                        current_freq_reg <= unsigned(freq_start);
                        next_freq <= unsigned(freq_start) + unsigned(freq_step);
                        -- 流水线：提前计算加法结果和比较结果
                        next_freq_plus_step <= unsigned(freq_start) + unsigned(freq_step) + unsigned(freq_step);
                        if unsigned(freq_start) + unsigned(freq_step) <= freq_stop_reg then
                            next_freq_le_stop <= '1';
                        else
                            next_freq_le_stop <= '0';
                        end if;
                    end if;

                when SET_FREQ =>
                    -- 流水线：在此阶段计算 next_freq + step
                    next_freq_plus_step <= next_freq + freq_step_reg;
                    if next_freq + freq_step_reg <= freq_stop_reg then
                        next_freq_le_stop <= '1';
                    else
                        next_freq_le_stop <= '0';
                    end if;

                when CHECK_NEXT =>
                    -- 使用已计算的流水线结果，无需组合加法
                    current_freq_reg <= next_freq;
                    next_freq <= next_freq_plus_step;

                when others =>
                    null;
            end case;
        end if;
    end process;

    -- ========================================================================
    -- 点数计数
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            point_cnt <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    point_cnt <= (others => '0');

                when CHECK_NEXT =>
                    if scan_complete_reg = '0' then
                        point_cnt <= point_cnt + 1;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    -- ========================================================================
    -- 驻留时间计数
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            dwell_cnt <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when SET_FREQ =>
                    dwell_cnt <= (others => '0');

                when DWELL_WAIT =>
                    if dwell_cnt < dwell_time_reg then
                        dwell_cnt <= dwell_cnt + 1;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    dwell_done <= '1' when dwell_cnt >= dwell_time_reg else '0';

    -- ========================================================================
    -- 扫描完成判断（流水线优化版）
    -- ========================================================================
    -- 优化点2：scan_complete 改为寄存器输出
    --          避免组合逻辑路径：next_freq > freq_stop_reg
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            scan_complete_reg <= '0';
        elsif rising_edge(clk) then
            -- 使用流水线寄存器 next_freq_le_stop 判断
            if next_freq_le_stop = '0' then
                scan_complete_reg <= '1';
            elsif point_cnt >= total_pts - 1 then
                scan_complete_reg <= '1';
            else
                scan_complete_reg <= '0';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出控制信号
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            dds_update <= '0';
            acq_trigger <= '0';
        elsif rising_edge(clk) then
            dds_update <= '0';
            acq_trigger <= '0';

            if state = SET_FREQ then
                dds_update <= '1';
            end if;

            if state = DWELL_WAIT and dwell_done = '1' then
                acq_trigger <= '1';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出端口连接
    -- ========================================================================
    dds_freq_out <= std_logic_vector(current_freq_reg);
    scan_busy <= '1' when state /= IDLE else '0';
    scan_done <= '1' when state = DONE else '0';
    current_freq <= std_logic_vector(current_freq_reg);
    point_count <= std_logic_vector(point_cnt);
    total_points <= std_logic_vector(total_pts);

end architecture rtl;
