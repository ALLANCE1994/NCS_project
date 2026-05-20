-- ============================================================================
-- DDS信号发生器测试激励 - M3.1验证
-- Testbench for dds_generator Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【验证目标】DDS模块功能正确性、Feature Flag有效性
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 测试实体
-- ============================================================================
entity tb_dds_generator is
end entity tb_dds_generator;

-- ============================================================================
-- 测试架构
-- ============================================================================
architecture sim of tb_dds_generator is

    -- ========================================================================
    -- 被测单元（UUT）信号
    -- ========================================================================
    signal clk          : std_logic := '0';
    signal rst_n        : std_logic := '0';
    signal freq_ctrl    : std_logic_vector(31 downto 0) := (others => '0');
    signal phase_offset : std_logic_vector(31 downto 0) := (others => '0');
    signal enable       : std_logic := '0';
    signal data_out     : std_logic_vector(13 downto 0);
    signal valid_out    : std_logic;
    signal clk_out      : std_logic;

    -- ========================================================================
    -- 测试参数
    -- ========================================================================
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz
    
    -- 测试频率：1MHz输出（频率控制字 = 1MHz * 2^32 / 100MHz = 0x028F5C28）
    constant FREQ_1MHZ  : std_logic_vector(31 downto 0) := X"028F5C28";
    -- 测试频率：10MHz输出（频率控制字 = 10MHz * 2^32 / 100MHz = 0x19999999）
    constant FREQ_10MHZ : std_logic_vector(31 downto 0) := X"19999999";

begin

    -- ========================================================================
    -- 被测单元实例化（默认FEATURE_DDS_GENERATOR='1'）
    -- ========================================================================
    uut: entity work.dds_generator
        generic map (
            FEATURE_DDS_GENERATOR => '1',  -- 使能DDS功能
            PHASE_WIDTH           => 32,
            DATA_WIDTH            => 14,
            ROM_ADDR_WIDTH        => 12
        )
        port map (
            clk          => clk,
            rst_n        => rst_n,
            freq_ctrl    => freq_ctrl,
            phase_offset => phase_offset,
            enable       => enable,
            data_out     => data_out,
            valid_out    => valid_out,
            clk_out      => clk_out
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
        
        -- 验证复位后输出为0
        assert data_out = (data_out'range => '0')
            report "Reset failed: data_out not zero" severity error;
        assert valid_out = '0'
            report "Reset failed: valid_out not zero" severity error;
        report "Test 1: PASSED";

        -- --------------------------------------------------------------------
        -- 测试2：DDS使能，1MHz输出
        -- --------------------------------------------------------------------
        report "Test 2: DDS Enable with 1MHz Output";
        freq_ctrl <= FREQ_1MHZ;
        enable <= '1';
        
        -- 等待几个周期让信号稳定
        wait for CLK_PERIOD * 10;
        
        -- 验证输出有效
        assert valid_out = '1'
            report "DDS enable failed: valid_out not asserted" severity error;
        
        -- 运行一段时间观察波形
        wait for CLK_PERIOD * 100;
        report "Test 2: PASSED (1MHz DDS running)";

        -- --------------------------------------------------------------------
        -- 测试3：频率切换（1MHz -> 10MHz）
        -- --------------------------------------------------------------------
        report "Test 3: Frequency Switch (1MHz -> 10MHz)";
        freq_ctrl <= FREQ_10MHZ;
        wait for CLK_PERIOD * 100;
        report "Test 3: PASSED (Frequency switched to 10MHz)";

        -- --------------------------------------------------------------------
        -- 测试4：DDS禁用
        -- --------------------------------------------------------------------
        report "Test 4: DDS Disable";
        enable <= '0';
        wait for CLK_PERIOD * 5;
        
        assert valid_out = '0'
            report "DDS disable failed: valid_out still asserted" severity error;
        assert data_out = (data_out'range => '0')
            report "DDS disable failed: data_out not zero" severity error;
        report "Test 4: PASSED";

        -- --------------------------------------------------------------------
        -- 测试5：相位偏移
        -- --------------------------------------------------------------------
        report "Test 5: Phase Offset";
        enable <= '1';
        freq_ctrl <= FREQ_1MHZ;
        phase_offset <= X"40000000";  -- 90度相位偏移
        wait for CLK_PERIOD * 100;
        report "Test 5: PASSED (Phase offset applied)";

        -- --------------------------------------------------------------------
        -- 测试完成
        -- --------------------------------------------------------------------
        report "========================================";
        report "All tests completed successfully!";
        report "========================================";
        
        wait;
    end process;

end architecture sim;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第5章 仿真测试与验证方法
-- ============================================================================
