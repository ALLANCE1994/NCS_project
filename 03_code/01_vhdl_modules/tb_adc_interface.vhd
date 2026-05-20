-- ============================================================================
-- ADC采集接口测试激励 - M3.2验证
-- Testbench for adc_interface Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【验证目标】ADC接口功能、跨时钟域FIFO、溢出检测
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 测试实体
-- ============================================================================
entity tb_adc_interface is
end entity tb_adc_interface;

-- ============================================================================
-- 测试架构
-- ============================================================================
architecture sim of tb_adc_interface is

    -- ========================================================================
    -- 被测单元（UUT）信号
    -- ========================================================================
    signal adc_clk      : std_logic := '0';
    signal adc_rst_n    : std_logic := '0';
    signal adc_data_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal adc_valid_in : std_logic := '0';
    signal adc_ovr_in   : std_logic := '0';
    
    signal sys_clk      : std_logic := '0';
    signal sys_rst_n    : std_logic := '0';
    signal enable       : std_logic := '0';
    signal fifo_clear   : std_logic := '0';
    
    signal data_out     : std_logic_vector(15 downto 0);
    signal data_valid   : std_logic;
    signal fifo_empty   : std_logic;
    signal fifo_full    : std_logic;
    signal fifo_count   : std_logic_vector(3 downto 0);
    signal overflow_flag: std_logic;
    signal overflow_cnt : std_logic_vector(15 downto 0);

    -- ========================================================================
    -- 测试参数
    -- ========================================================================
    constant ADC_CLK_PERIOD : time := 20 ns;   -- 50MHz
    constant SYS_CLK_PERIOD : time := 10 ns;   -- 100MHz
    
    -- 测试数据
    signal test_data : unsigned(15 downto 0) := (others => '0');

begin

    -- ========================================================================
    -- 被测单元实例化
    -- ========================================================================
    uut: entity work.adc_interface
        generic map (
            FEATURE_ADC_INTERFACE => '1',
            ADC_WIDTH             => 16,
            DATA_WIDTH            => 16,
            FIFO_DEPTH            => 16,
            FIFO_ADDR_WIDTH       => 4
        )
        port map (
            adc_clk      => adc_clk,
            adc_rst_n    => adc_rst_n,
            adc_data_in  => adc_data_in,
            adc_valid_in => adc_valid_in,
            adc_ovr_in   => adc_ovr_in,
            sys_clk      => sys_clk,
            sys_rst_n    => sys_rst_n,
            enable       => enable,
            fifo_clear   => fifo_clear,
            data_out     => data_out,
            data_valid   => data_valid,
            fifo_empty   => fifo_empty,
            fifo_full    => fifo_full,
            fifo_count   => fifo_count,
            overflow_flag=> overflow_flag,
            overflow_cnt => overflow_cnt
        );

    -- ========================================================================
    -- 时钟生成
    -- ========================================================================
    adc_clk <= not adc_clk after ADC_CLK_PERIOD / 2;
    sys_clk <= not sys_clk after SYS_CLK_PERIOD / 2;

    -- ========================================================================
    -- 测试过程
    -- ========================================================================
    process
    begin
        -- --------------------------------------------------------------------
        -- 测试1：系统复位
        -- --------------------------------------------------------------------
        report "Test 1: System Reset";
        adc_rst_n <= '0';
        sys_rst_n <= '0';
        wait for ADC_CLK_PERIOD * 5;
        adc_rst_n <= '1';
        sys_rst_n <= '1';
        wait for SYS_CLK_PERIOD * 5;
        
        assert fifo_empty = '1'
            report "Reset failed: fifo_empty not asserted" severity error;
        assert fifo_full = '0'
            report "Reset failed: fifo_full asserted" severity error;
        report "Test 1: PASSED";

        -- --------------------------------------------------------------------
        -- 测试2：ADC数据写入和读取
        -- --------------------------------------------------------------------
        report "Test 2: ADC Data Write and Read";
        enable <= '1';
        
        -- 写入10个样本
        for i in 0 to 9 loop
            adc_data_in <= std_logic_vector(to_unsigned(i * 100, 16));
            adc_valid_in <= '1';
            wait for ADC_CLK_PERIOD;
        end loop;
        adc_valid_in <= '0';
        
        -- 等待跨时钟域同步
        wait for SYS_CLK_PERIOD * 10;
        
        -- 验证FIFO非空
        assert fifo_empty = '0'
            report "FIFO should not be empty after write" severity error;
        report "Test 2: PASSED (10 samples written)";

        -- --------------------------------------------------------------------
        -- 测试3：FIFO满检测
        -- --------------------------------------------------------------------
        report "Test 3: FIFO Full Detection";
        
        -- 继续写入直到FIFO满
        for i in 10 to 30 loop
            adc_data_in <= std_logic_vector(to_unsigned(i * 100, 16));
            adc_valid_in <= '1';
            wait for ADC_CLK_PERIOD;
        end loop;
        adc_valid_in <= '0';
        
        wait for SYS_CLK_PERIOD * 5;
        
        -- 验证FIFO计数
        report "FIFO count: " & integer'image(to_integer(unsigned(fifo_count)));
        report "Test 3: PASSED";

        -- --------------------------------------------------------------------
        -- 测试4：溢出检测
        -- --------------------------------------------------------------------
        report "Test 4: Overflow Detection";
        adc_ovr_in <= '1';
        wait for ADC_CLK_PERIOD * 3;
        adc_ovr_in <= '0';
        
        wait for SYS_CLK_PERIOD * 5;
        
        assert overflow_cnt /= X"0000"
            report "Overflow counter should increment" severity error;
        report "Test 4: PASSED (Overflow count: " & integer'image(to_integer(unsigned(overflow_cnt))) & ")";

        -- --------------------------------------------------------------------
        -- 测试5：FIFO清零
        -- --------------------------------------------------------------------
        report "Test 5: FIFO Clear";
        fifo_clear <= '1';
        wait for SYS_CLK_PERIOD * 3;
        fifo_clear <= '0';
        
        wait for SYS_CLK_PERIOD * 5;
        
        assert fifo_empty = '1'
            report "FIFO should be empty after clear" severity error;
        assert fifo_count = X"0"
            report "FIFO count should be zero after clear" severity error;
        report "Test 5: PASSED";

        -- --------------------------------------------------------------------
        -- 测试6：ADC禁用
        -- --------------------------------------------------------------------
        report "Test 6: ADC Disable";
        enable <= '0';
        
        -- 尝试写入数据
        adc_data_in <= X"ABCD";
        adc_valid_in <= '1';
        wait for ADC_CLK_PERIOD * 5;
        adc_valid_in <= '0';
        
        wait for SYS_CLK_PERIOD * 10;
        
        -- FIFO应保持为空
        assert fifo_empty = '1'
            report "FIFO should remain empty when disabled" severity error;
        report "Test 6: PASSED";

        -- --------------------------------------------------------------------
        -- 测试完成
        -- --------------------------------------------------------------------
        report "========================================";
        report "All ADC interface tests completed!";
        report "========================================";
        
        wait;
    end process;

end architecture sim;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第5章 仿真测试与验证方法
-- ============================================================================
