-- ============================================================================
-- 频率扫描状态机测试激励 - M3.4验证
-- Testbench for scan_controller Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【验证目标】扫描状态机、频率步进、驻留时间控制
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 测试实体
-- ============================================================================
entity tb_scan_controller is
end entity tb_scan_controller;

-- ============================================================================
-- 测试架构
-- ============================================================================
architecture sim of tb_scan_controller is

    -- ========================================================================
    -- 被测单元（UUT）信号
    -- ========================================================================
    signal clk          : std_logic := '0';
    signal rst_n        : std_logic := '0';
    signal enable       : std_logic := '0';
    signal start_scan   : std_logic := '0';
    signal stop_scan    : std_logic := '0';
    signal freq_start   : std_logic_vector(31 downto 0) := (others => '0');
    signal freq_stop    : std_logic_vector(31 downto 0) := (others => '0');
    signal freq_step    : std_logic_vector(31 downto 0) := (others => '0');
    signal dwell_time   : std_logic_vector(15 downto 0) := (others => '0');
    signal dds_freq_out : std_logic_vector(31 downto 0);
    signal dds_update   : std_logic;
    signal acq_trigger  : std_logic;
    signal acq_busy     : std_logic := '0';
    signal scan_busy    : std_logic;
    signal scan_done    : std_logic;
    signal current_freq : std_logic_vector(31 downto 0);
    signal point_count  : std_logic_vector(15 downto 0);
    signal total_points : std_logic_vector(15 downto 0);

    -- ========================================================================
    -- 测试参数
    -- ========================================================================
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz
    
    -- 测试频率参数（模拟2.8-3.0GHz范围）
    constant FREQ_2_8G  : std_logic_vector(31 downto 0) := X"0A3D70A4";  -- 2.8GHz控制字
    constant FREQ_3_0G  : std_logic_vector(31 downto 0) := X"0AE147AE";  -- 3.0GHz控制字
    constant FSTEP_10M  : std_logic_vector(31 downto 0) := X"0051EB85";  -- 10MHz步进

begin

    -- ========================================================================
    -- 被测单元实例化
    -- ========================================================================
    uut: entity work.scan_controller
        generic map (
            FEATURE_SCAN_CONTROLLER => '1',
            FREQ_WIDTH              => 32,
            DWELL_WIDTH             => 16,
            POINT_WIDTH             => 16
        )
        port map (
            clk          => clk,
            rst_n        => rst_n,
            enable       => enable,
            start_scan   => start_scan,
            stop_scan    => stop_scan,
            freq_start   => freq_start,
            freq_stop    => freq_stop,
            freq_step    => freq_step,
            dwell_time   => dwell_time,
            dds_freq_out => dds_freq_out,
            dds_update   => dds_update,
            acq_trigger  => acq_trigger,
            acq_busy     => acq_busy,
            scan_busy    => scan_busy,
            scan_done    => scan_done,
            current_freq => current_freq,
            point_count  => point_count,
            total_points => total_points
        );

    -- ========================================================================
    -- 时钟生成
    -- ========================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- ========================================================================
    -- 测试过程
    -- ========================================================================
    process
    begin
        -- --------------------------------------------------------------------
        -- 测试1：系统复位
        -- --------------------------------------------------------------------
        report "Test 1: System Reset";
        rst_n <= '0';
        wait for CLK_PERIOD * 5;
        rst_n <= '1';
        wait for CLK_PERIOD * 2;
        
        assert scan_busy = '0'
            report "Reset failed: scan_busy should be 0" severity error;
        assert scan_done = '0'
            report "Reset failed: scan_done should be 0" severity error;
        report "Test 1: PASSED";

        -- --------------------------------------------------------------------
        -- 测试2：扫描使能
        -- --------------------------------------------------------------------
        report "Test 2: Scan Enable";
        enable <= '1';
        freq_start <= FREQ_2_8G;
        freq_stop <= FREQ_3_0G;
        freq_step <= FSTEP_10M;
        dwell_time <= X"000A";  -- 10个时钟周期驻留
        
        wait for CLK_PERIOD * 2;
        
        start_scan <= '1';
        wait for CLK_PERIOD;
        start_scan <= '0';
        
        -- 等待扫描开始
        wait for CLK_PERIOD * 5;
        
        assert scan_busy = '1'
            report "Scan should be busy after start" severity error;
        report "Test 2: PASSED (Scan started)";

        -- --------------------------------------------------------------------
        -- 测试3：等待扫描完成
        -- --------------------------------------------------------------------
        report "Test 3: Wait for Scan Completion";
        
        -- 模拟采集忙信号
        wait until acq_trigger = '1';
        acq_busy <= '1';
        wait for CLK_PERIOD * 5;
        acq_busy <= '0';
        
        -- 等待扫描完成
        wait until scan_done = '1' for CLK_PERIOD * 500;
        
        if scan_done = '1' then
            report "Test 3: PASSED (Scan completed)";
            report "Total points: " & integer'image(to_integer(unsigned(total_points)));
            report "Final point count: " & integer'image(to_integer(unsigned(point_count)));
        else
            report "Test 3: FAILED (Scan did not complete in time)" severity error;
        end if;

        -- --------------------------------------------------------------------
        -- 测试4：扫描禁用
        -- --------------------------------------------------------------------
        report "Test 4: Scan Disable";
        enable <= '0';
        wait for CLK_PERIOD * 2;
        
        start_scan <= '1';
        wait for CLK_PERIOD;
        start_scan <= '0';
        wait for CLK_PERIOD * 10;
        
        assert scan_busy = '0'
            report "Scan should not start when disabled" severity error;
        report "Test 4: PASSED";

        -- --------------------------------------------------------------------
        -- 测试5：停止扫描
        -- --------------------------------------------------------------------
        report "Test 5: Stop Scan";
        enable <= '1';
        start_scan <= '1';
        wait for CLK_PERIOD;
        start_scan <= '0';
        wait for CLK_PERIOD * 20;
        
        -- 中途停止
        stop_scan <= '1';
        wait for CLK_PERIOD;
        stop_scan <= '0';
        wait for CLK_PERIOD * 5;
        
        assert scan_done = '1'
            report "Scan should be done after stop" severity error;
        report "Test 5: PASSED";

        -- --------------------------------------------------------------------
        -- 测试6：单点扫描
        -- --------------------------------------------------------------------
        report "Test 6: Single Point Scan";
        freq_start <= FREQ_2_8G;
        freq_stop <= FREQ_2_8G;  -- 起始=终止，单点
        freq_step <= FSTEP_10M;
        dwell_time <= X"0005";
        
        start_scan <= '1';
        wait for CLK_PERIOD;
        start_scan <= '0';
        
        wait until scan_done = '1' for CLK_PERIOD * 100;
        
        assert total_points = X"0001"
            report "Single point scan should have 1 point" severity error;
        report "Test 6: PASSED";

        -- --------------------------------------------------------------------
        -- 测试完成
        -- --------------------------------------------------------------------
        report "========================================";
        report "All scan controller tests completed!";
        report "========================================";
        
        wait;
    end process;

end architecture sim;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第5章 仿真测试与验证方法
-- ============================================================================
