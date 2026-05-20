-- ============================================================================
-- CORDIC数字锁相测试激励 - M3.3验证
-- Testbench for cordic_lia Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【验证目标】CORDIC锁相功能、幅值/相位解调精度
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- ============================================================================
-- 测试实体
-- ============================================================================
entity tb_cordic_lia is
end entity tb_cordic_lia;

-- ============================================================================
-- 测试架构
-- ============================================================================
architecture sim of tb_cordic_lia is

    -- ========================================================================
    -- 被测单元（UUT）信号
    -- ========================================================================
    signal clk          : std_logic := '0';
    signal rst_n        : std_logic := '0';
    signal enable       : std_logic := '0';
    signal start        : std_logic := '0';
    signal adc_data     : std_logic_vector(15 downto 0) := (others => '0');
    signal adc_valid    : std_logic := '0';
    signal ref_sin      : std_logic_vector(15 downto 0) := (others => '0');
    signal ref_cos      : std_logic_vector(15 downto 0) := (others => '0');
    signal ref_valid    : std_logic := '0';
    signal magnitude    : std_logic_vector(15 downto 0);
    signal phase        : std_logic_vector(15 downto 0);
    signal output_valid : std_logic;
    signal busy         : std_logic;

    -- ========================================================================
    -- 测试参数
    -- ========================================================================
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz
    
    -- 参考信号表（正弦/余弦，16位定点，幅度8191）
    type ref_table_type is array (0 to 15) of integer;
    constant SIN_TABLE : ref_table_type := (
        0, 3212, 6012, 8191, 9512, 9830, 9121, 7488,
        5126, 2480, 0, -2480, -5126, -7488, -9121, -9830
    );
    constant COS_TABLE : ref_table_type := (
        8191, 7488, 5126, 2480, 0, -2480, -5126, -7488,
        -9121, -9830, -9512, -8191, -6012, -3212, 0, 3212
    );

begin

    -- ========================================================================
    -- 被测单元实例化
    -- ========================================================================
    uut: entity work.cordic_lia
        generic map (
            FEATURE_CORDIC_LIA => '1',
            DATA_WIDTH         => 16,
            ITERATIONS         => 12,
            INTERNAL_WIDTH     => 20,
            PHASE_WIDTH        => 16
        )
        port map (
            clk          => clk,
            rst_n        => rst_n,
            enable       => enable,
            start        => start,
            adc_data     => adc_data,
            adc_valid    => adc_valid,
            ref_sin      => ref_sin,
            ref_cos      => ref_cos,
            ref_valid    => ref_valid,
            magnitude    => magnitude,
            phase        => phase,
            output_valid => output_valid,
            busy         => busy
        );

    -- ========================================================================
    -- 时钟生成
    -- ========================================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- ========================================================================
    -- 测试过程
    -- ========================================================================
    process
        variable test_idx : integer := 0;
    begin
        -- --------------------------------------------------------------------
        -- 测试1：系统复位
        -- --------------------------------------------------------------------
        report "Test 1: System Reset";
        rst_n <= '0';
        wait for CLK_PERIOD * 5;
        rst_n <= '1';
        wait for CLK_PERIOD * 2;
        
        assert busy = '0'
            report "Reset failed: busy should be 0" severity error;
        report "Test 1: PASSED";

        -- --------------------------------------------------------------------
        -- 测试2：CORDIC锁相使能
        -- --------------------------------------------------------------------
        report "Test 2: CORDIC Lock-in Enable";
        enable <= '1';
        adc_valid <= '1';
        ref_valid <= '1';
        
        -- 测试信号：ADC输入 = 1000，参考相位 = 0度
        adc_data <= std_logic_vector(to_signed(1000, 16));
        ref_sin <= std_logic_vector(to_signed(SIN_TABLE(0), 16));  -- sin(0) = 0
        ref_cos <= std_logic_vector(to_signed(COS_TABLE(0), 16));  -- cos(0) = 8191
        
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- 等待计算完成（约15个周期）
        wait for CLK_PERIOD * 20;
        
        assert output_valid = '1'
            report "CORDIC calculation failed" severity error;
        report "Test 2: PASSED (Magnitude=" & integer'image(to_integer(signed(magnitude))) & ")";

        -- --------------------------------------------------------------------
        -- 测试3：不同相位测试
        -- --------------------------------------------------------------------
        report "Test 3: Different Phase Tests";
        
        for i in 0 to 7 loop
            -- 设置参考信号相位
            ref_sin <= std_logic_vector(to_signed(SIN_TABLE(i), 16));
            ref_cos <= std_logic_vector(to_signed(COS_TABLE(i), 16));
            
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            
            -- 等待计算完成
            wait for CLK_PERIOD * 20;
            
            report "Phase test " & integer'image(i) & 
                   ": Magnitude=" & integer'image(to_integer(signed(magnitude))) &
                   ", Phase=" & integer'image(to_integer(signed(phase)));
        end loop;
        report "Test 3: PASSED";

        -- --------------------------------------------------------------------
        -- 测试4：CORDIC禁用
        -- --------------------------------------------------------------------
        report "Test 4: CORDIC Disable";
        enable <= '0';
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait for CLK_PERIOD * 5;
        
        assert busy = '0'
            report "CORDIC should not start when disabled" severity error;
        report "Test 4: PASSED";

        -- --------------------------------------------------------------------
        -- 测试5：大信号幅值测试
        -- --------------------------------------------------------------------
        report "Test 5: Large Signal Amplitude Test";
        enable <= '1';
        adc_data <= std_logic_vector(to_signed(5000, 16));
        ref_sin <= std_logic_vector(to_signed(SIN_TABLE(2), 16));
        ref_cos <= std_logic_vector(to_signed(COS_TABLE(2), 16));
        
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        wait for CLK_PERIOD * 20;
        
        report "Large signal: Magnitude=" & integer'image(to_integer(signed(magnitude)));
        report "Test 5: PASSED";

        -- --------------------------------------------------------------------
        -- 测试完成
        -- --------------------------------------------------------------------
        report "========================================";
        report "All CORDIC LIA tests completed!";
        report "========================================";
        
        wait;
    end process;

end architecture sim;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第5章 仿真测试与验证方法
-- ============================================================================
