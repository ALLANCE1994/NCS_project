-- ============================================================================
-- NV色心实验系统 - 顶层模块（M4.0 PS集成版）
-- NV Center ODMR Experiment System - Top Level Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M4.0 PS系统集成
-- 【知识来源】arch_base.md / 02_zynq_architecture_knowledge.md / pg155-axi-lite-ipif
-- 【设计原则】AXI4-Lite从接口统一寄存器映射，PS通过AXI控制PL端
-- ============================================================================
-- 【M4变更说明】
--   - 新增AXI4-Lite从接口（PS→PL寄存器读写）
--   - 时钟/复位改由AXI接口提供（PS7 FCLK_CLK0）
--   - 移除sys_clk_50m/sys_rst_n外部端口
--   - 各子模块保持不变，通过内部寄存器映射连接
-- ============================================================================
-- 【Feature Flag】FEATURE_TOP_ODMR - 顶层模块使能开关
--   默认值：'1'（使能）
--   用途：L1回滚防线
-- ============================================================================
-- 【数据通路】
--   PS7 → [AXI-Lite] → top_odmr寄存器 → DDS/ADC/SCAN/CORDIC/IIR
--   DDS → [外部DAC] → [NV色心] → [ADC] → adc_interface → CORDIC LIA → IIR
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_odmr is
    generic (
        FEATURE_TOP_ODMR : std_logic := '1'
    );
    port (
        -- =====================================================================
        -- AXI4-Lite从接口（PS7 M_AXI_GP0 → AXI Interconnect → 本接口）
        -- =====================================================================
        s_axi_aclk      : in  std_logic;
        s_axi_aresetn   : in  std_logic;
        s_axi_awaddr    : in  std_logic_vector(11 downto 0);
        s_axi_awprot    : in  std_logic_vector(2 downto 0);
        s_axi_awvalid   : in  std_logic;
        s_axi_awready   : out std_logic;
        s_axi_wdata     : in  std_logic_vector(31 downto 0);
        s_axi_wstrb     : in  std_logic_vector(3 downto 0);
        s_axi_wvalid    : in  std_logic;
        s_axi_wready    : out std_logic;
        s_axi_bresp     : out std_logic_vector(1 downto 0);
        s_axi_bvalid    : out std_logic;
        s_axi_bready    : in  std_logic;
        s_axi_araddr    : in  std_logic_vector(11 downto 0);
        s_axi_arprot    : in  std_logic_vector(2 downto 0);
        s_axi_arvalid   : in  std_logic;
        s_axi_arready   : out std_logic;
        s_axi_rdata     : out std_logic_vector(31 downto 0);
        s_axi_rresp     : out std_logic_vector(1 downto 0);
        s_axi_rvalid    : out std_logic;
        s_axi_rready    : in  std_logic;

        -- =====================================================================
        -- LED指示
        -- =====================================================================
        led             : out std_logic_vector(3 downto 0);

        -- =====================================================================
        -- 按键输入
        -- =====================================================================
        key             : in  std_logic_vector(3 downto 0);

        -- =====================================================================
        -- DDS信号发生器接口（14位数据）
        -- =====================================================================
        dds_clk_out     : out std_logic;
        dds_data_out    : out std_logic_vector(13 downto 0);
        dds_valid       : out std_logic;

        -- =====================================================================
        -- ADC采集接口（14位数据）
        -- =====================================================================
        adc_clk_in      : in  std_logic;
        adc_data_in     : in  std_logic_vector(13 downto 0);
        adc_valid       : in  std_logic;
        adc_ovr         : in  std_logic;

        -- =====================================================================
        -- 扫描同步接口
        -- =====================================================================
        scan_sync       : in  std_logic;
        scan_trigger    : out std_logic
    );
end entity top_odmr;

architecture rtl of top_odmr is

    -- ========================================================================
    -- 系统信号（M4: 时钟/复位来自AXI接口）
    -- ========================================================================
    signal sys_clk       : std_logic;  -- = s_axi_aclk (PS7 FCLK_CLK0)
    signal sys_rst_sync  : std_logic;
    signal rst_n         : std_logic;  -- 复位信号（not sys_rst_sync）
    
    -- ========================================================================
    -- AXI-Lite内部信号（解决out端口在进程中赋值的问题）
    -- ========================================================================
    signal s_axi_awready_i : std_logic;
    signal s_axi_wready_i  : std_logic;
    signal s_axi_bvalid_i  : std_logic;
    signal s_axi_arready_i : std_logic;
    signal s_axi_rvalid_i  : std_logic;
    signal s_axi_rdata_i   : std_logic_vector(31 downto 0);
    
    -- ========================================================================
    -- AXI-Lite寄存器阵列（16个32位寄存器，地址0x00~0x3C）
    -- ========================================================================
    type reg_array_t is array(0 to 15) of std_logic_vector(31 downto 0);
    signal regs          : reg_array_t;
    signal reg_aw_en     : std_logic;  -- 写地址使能
    signal reg_w_en      : std_logic;  -- 写数据使能
    signal reg_ar_en     : std_logic;  -- 读地址使能

    -- ========================================================================
    -- 模块使能信号
    -- ========================================================================
    signal dds_enable_i    : std_logic;
    signal scan_enable_i   : std_logic;
    signal scan_start_i    : std_logic;

    -- ========================================================================
    -- DDS内部信号
    -- ========================================================================
    signal dds_data_i       : std_logic_vector(13 downto 0); -- 内部信号
    signal dds_valid_i      : std_logic;                    -- 内部信号

    -- ========================================================================
    -- ADC接口输出信号（跨时钟域后）
    -- ========================================================================
    signal adc_data_16bit   : std_logic_vector(15 downto 0);
    signal adc_valid_out    : std_logic;
    signal adc_fifo_empty   : std_logic;
    signal adc_fifo_full    : std_logic;
    signal adc_fifo_count   : std_logic_vector(3 downto 0);
    signal adc_overflow_flag: std_logic;
    signal adc_overflow_cnt : std_logic_vector(15 downto 0);

    -- ========================================================================
    -- CORDIC锁相内部信号
    -- ========================================================================
    signal ref_sin          : std_logic_vector(15 downto 0);
    signal ref_cos          : std_logic_vector(15 downto 0);
    signal ref_valid        : std_logic;
    signal lia_magnitude    : std_logic_vector(15 downto 0);
    signal lia_phase        : std_logic_vector(15 downto 0);
    signal lia_valid        : std_logic;
    signal lia_busy         : std_logic;

    -- ========================================================================
    -- IIR滤波器内部信号
    -- ========================================================================
    signal iir_data_out     : std_logic_vector(15 downto 0);
    signal iir_valid        : std_logic;

    -- ========================================================================
    -- 扫描控制内部信号
    -- ========================================================================
    signal scan_busy        : std_logic;
    signal scan_done        : std_logic;
    signal scan_current_freq: std_logic_vector(31 downto 0);
    signal dds_freq_from_scan: std_logic_vector(31 downto 0);
    signal dds_update_from_scan: std_logic;

    -- ========================================================================
    -- LED控制信号
    -- ========================================================================
    signal heartbeat_cnt    : unsigned(24 downto 0);

begin

    -- ========================================================================
    -- 时钟/复位分配（M4: 来自AXI接口）
    -- ========================================================================
    sys_clk <= s_axi_aclk;

    process(sys_clk, s_axi_aresetn)
    begin
        if s_axi_aresetn = '0' then
            sys_rst_sync <= '1';
        elsif rising_edge(sys_clk) then
            sys_rst_sync <= '0';
        end if;
    end process;
    rst_n <= not sys_rst_sync;

    -- ========================================================================
    -- Feature Flag 控制逻辑（L1回滚防线）
    -- ========================================================================
    -- sys_active由AXI寄存器CTRL[0]控制

    -- ========================================================================
    -- AXI-Lite写通道逻辑
    -- ========================================================================
    reg_aw_en <= s_axi_awvalid and s_axi_awready;
    reg_w_en  <= s_axi_wvalid and s_axi_wready;

    -- 写地址就绪
    process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if s_axi_aresetn = '0' then
                s_axi_awready_i <= '0';
            else
                s_axi_awready_i <= s_axi_awvalid and not s_axi_wready_i;
            end if;
        end if;
    end process;

    -- 写数据就绪 + 寄存器写入
    process(sys_clk)
        variable awaddr_int : integer range 0 to 15;
    begin
        if rising_edge(sys_clk) then
            if s_axi_aresetn = '0' then
                s_axi_wready_i <= '0';
                s_axi_bvalid_i <= '0';
            else
                s_axi_wready_i <= s_axi_wvalid and s_axi_awready_i;
                s_axi_bvalid_i <= reg_w_en;

                -- 寄存器写入（地址解码）
                if reg_w_en = '1' then
                    awaddr_int := to_integer(unsigned(s_axi_awaddr(3 downto 0)));
                    case awaddr_int is
                        when 0 => regs(0) <= s_axi_wdata;  -- CTRL
                        when 1 => null;                       -- STATUS: 只读
                        when 2 => regs(2) <= s_axi_wdata;  -- DDS_FREQ
                        when 3 => regs(3) <= s_axi_wdata;  -- DDS_PHASE
                        when 4 => regs(4) <= s_axi_wdata;  -- SCAN_START_FREQ
                        when 5 => regs(5) <= s_axi_wdata;  -- SCAN_STOP_FREQ
                        when 6 => regs(6) <= s_axi_wdata;  -- SCAN_STEP
                        when 7 => regs(7) <= s_axi_wdata;  -- SCAN_DWELL
                        when 8 => regs(8) <= s_axi_wdata;  -- SCAN_POINTS
                        when 9 => regs(9) <= s_axi_wdata;  -- SCAN_CTRL
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    s_axi_bresp <= "00";  -- OKAY

    -- ========================================================================
    -- AXI-Lite读通道逻辑
    -- ========================================================================
    process(sys_clk)
        variable araddr_int : integer range 0 to 15;
    begin
        if rising_edge(sys_clk) then
            if s_axi_aresetn = '0' then
                s_axi_arready_i <= '0';
                s_axi_rvalid_i  <= '0';
                s_axi_rdata_i   <= (others => '0');
            else
                s_axi_arready_i <= s_axi_arvalid;
                s_axi_rvalid_i  <= s_axi_arvalid;

                if s_axi_arvalid = '1' then
                    araddr_int := to_integer(unsigned(s_axi_araddr(3 downto 0)));
                    case araddr_int is
                        when 0 => s_axi_rdata_i <= regs(0);  -- CTRL
                        when 1 => -- STATUS: 组合状态
                            s_axi_rdata_i <= (0 => scan_busy, 1 => scan_done,
                                            2 => adc_overflow_flag, 3 => lia_busy,
                                            others => '0');
                        when 2 => s_axi_rdata_i <= regs(2);  -- DDS_FREQ
                        when 3 => s_axi_rdata_i <= regs(3);  -- DDS_PHASE
                        when 4 => s_axi_rdata_i <= regs(4);  -- SCAN_START_FREQ
                        when 5 => s_axi_rdata_i <= regs(5);  -- SCAN_STOP_FREQ
                        when 6 => s_axi_rdata_i <= regs(6);  -- SCAN_STEP
                        when 7 => s_axi_rdata_i <= regs(7);  -- SCAN_DWELL
                        when 8 => s_axi_rdata_i <= regs(8);  -- SCAN_POINTS
                        when 9 => s_axi_rdata_i <= regs(9);  -- SCAN_CTRL
                        when 10 => -- ADC_DATA
                            s_axi_rdata_i <= X"0000" & adc_data_16bit;
                        when 11 => -- LIA_MAG
                            s_axi_rdata_i <= X"0000" & lia_magnitude;
                        when 12 => -- LIA_PHASE
                            s_axi_rdata_i <= X"0000" & lia_phase;
                        when 13 => -- IIR_DATA
                            s_axi_rdata_i <= X"0000" & iir_data_out;
                        when 14 => -- CURRENT_FREQ
                            s_axi_rdata_i <= scan_current_freq;
                        when 15 => -- POINT_COUNT (高16位扩展)
                            s_axi_rdata_i <= X"0000" & regs(8)(15 downto 0);  -- SCAN_POINTS寄存器
                        when others => s_axi_rdata_i <= (others => '0');
                    end case;
                end if;
            end if;
        end if;
    end process;

    s_axi_rresp <= "00";  -- OKAY

    -- ========================================================================
    -- AXI-Lite端口信号赋值（内部信号→端口）
    -- ========================================================================
    s_axi_awready <= s_axi_awready_i;
    s_axi_wready  <= s_axi_wready_i;
    s_axi_bvalid  <= s_axi_bvalid_i;
    s_axi_arready <= s_axi_arready_i;
    s_axi_rvalid  <= s_axi_rvalid_i;
    s_axi_rdata   <= s_axi_rdata_i;

    -- ========================================================================
    -- 控制信号映射（从AXI寄存器到内部信号）
    -- ========================================================================
    dds_enable_i  <= regs(0)(1);   -- CTRL[1] = DDS_EN
    scan_enable_i <= regs(0)(2);   -- CTRL[2] = SCAN_EN
    scan_start_i  <= regs(9)(0);   -- SCAN_CTRL[0] = START

    -- ========================================================================
    -- M3.1 DDS信号发生器实例
    -- ========================================================================
    inst_dds_generator : entity work.dds_generator
        generic map (
            FEATURE_DDS_GENERATOR => '1',
            PHASE_WIDTH           => 32,
            DATA_WIDTH            => 14,
            ROM_ADDR_WIDTH        => 12
        )
        port map (
            clk          => sys_clk,
            rst_n        => rst_n,
            enable       => dds_enable_i,
            freq_ctrl    => regs(2),        -- DDS_FREQ寄存器
            phase_offset => regs(3),        -- DDS_PHASE寄存器
            data_out     => dds_data_i,
            valid_out    => dds_valid_i,
            clk_out      => dds_clk_out
        );
    
    -- 内部信号赋值给输出端口
    dds_data_out <= dds_data_i;
    dds_valid      <= dds_valid_i;

    -- ========================================================================
    -- M3.2 ADC采集接口实例（跨时钟域 + FIFO）
    -- ========================================================================
    inst_adc_interface : entity work.adc_interface
        generic map (
            FEATURE_ADC_INTERFACE => '1',
            ADC_WIDTH             => 14,
            DATA_WIDTH            => 16,
            FIFO_DEPTH            => 16,
            FIFO_ADDR_WIDTH       => 4
        )
        port map (
            adc_clk         => adc_clk_in,
            adc_rst_n       => rst_n,
            adc_data_in     => adc_data_in,
            adc_valid_in    => adc_valid,
            adc_ovr_in      => adc_ovr,
            sys_clk         => sys_clk,
            sys_rst_n       => rst_n,
            enable          => regs(0)(0),   -- CTRL[0] = GLOBAL_EN
            fifo_clear      => '0',
            data_out        => adc_data_16bit,
            data_valid      => adc_valid_out,
            fifo_empty      => adc_fifo_empty,
            fifo_full       => adc_fifo_full,
            fifo_count      => adc_fifo_count,
            overflow_flag   => adc_overflow_flag,
            overflow_cnt    => adc_overflow_cnt
        );

    -- ========================================================================
    -- 参考信号（M3阶段简化：DDS有效时输出满幅）
    -- ========================================================================-- 参考信号默认值（M3阶段简化：DDS有效时输出满幅）
    ref_sin   <= X"7FFF" when dds_valid_i = '1' else X"0000";
    ref_cos   <= X"7FFF" when dds_valid_i = '1' else X"0000";
    ref_valid <= dds_valid_i;

    -- ========================================================================
    -- M3.3 CORDIC数字锁相放大器实例
    -- ========================================================================
    inst_cordic_lia : entity work.cordic_lia
        generic map (
            FEATURE_CORDIC_LIA => '1',
            DATA_WIDTH         => 16,
            ITERATIONS         => 12,
            INTERNAL_WIDTH     => 20,
            PHASE_WIDTH        => 16
        )
        port map (
            clk          => sys_clk,
            rst_n        => rst_n,
            enable       => regs(0)(0),   -- CTRL[0] = GLOBAL_EN
            start        => '1',
            adc_data     => adc_data_16bit,
            adc_valid    => adc_valid_out,
            ref_sin      => ref_sin,
            ref_cos      => ref_cos,
            ref_valid    => ref_valid,
            magnitude    => lia_magnitude,
            phase        => lia_phase,
            output_valid => lia_valid,
            busy         => lia_busy
        );

    -- ========================================================================
    -- M3.5 IIR低通滤波器实例
    -- ========================================================================
    inst_iir_lowpass : entity work.iir_lowpass
        generic map (
            FEATURE_IIR_LOWPASS => '1',
            DATA_WIDTH          => 16,
            COEFF_WIDTH         => 16,
            ACC_WIDTH           => 32
        )
        port map (
            clk        => sys_clk,
            rst_n      => rst_n,
            enable     => regs(0)(0),   -- CTRL[0] = GLOBAL_EN
            coeff_a1   => X"F5E7",   -- 默认a1（二阶巴特沃斯10kHz）
            coeff_a2   => X"751E",   -- 默认a2
            coeff_b0   => X"001F",   -- 默认b0
            coeff_b1   => X"003E",   -- 默认b1
            coeff_b2   => X"001F",   -- 默认b2
            data_in    => lia_magnitude,
            data_valid => lia_valid,
            data_out   => iir_data_out,
            out_valid  => iir_valid
        );

    -- ========================================================================
    -- M3.4 扫描控制器实例
    -- ========================================================================
    inst_scan_controller : entity work.scan_controller
        generic map (
            FEATURE_SCAN_CONTROLLER => '1',
            FREQ_WIDTH              => 32,
            DWELL_WIDTH             => 16,
            POINT_WIDTH             => 16
        )
        port map (
            clk             => sys_clk,
            rst_n           => rst_n,
            enable          => scan_enable_i,
            start_scan      => scan_start_i,
            stop_scan       => regs(9)(1),       -- SCAN_CTRL[1] = STOP
            freq_start      => regs(4),           -- SCAN_START_FREQ寄存器
            freq_stop       => regs(5),           -- SCAN_STOP_FREQ寄存器
            freq_step       => regs(6),           -- SCAN_STEP寄存器
            dwell_time      => regs(7)(15 downto 0), -- SCAN_DWELL低16位
            total_points_in => regs(8)(15 downto 0), -- SCAN_POINTS低16位
            dds_freq_out    => dds_freq_from_scan,
            dds_update      => dds_update_from_scan,
            acq_trigger     => scan_trigger,
            acq_busy        => scan_sync,
            scan_busy       => scan_busy,
            scan_done       => scan_done,
            current_freq    => scan_current_freq,
            point_count     => open,
            total_points    => open
        );

    -- ========================================================================
    -- LED状态指示
    -- ========================================================================
    process(sys_clk, sys_rst_sync)
    begin
        if sys_rst_sync = '1' then
            heartbeat_cnt <= (others => '0');
        elsif rising_edge(sys_clk) then
            heartbeat_cnt <= heartbeat_cnt + 1;
        end if;
    end process;

    led(0) <= heartbeat_cnt(24);   -- 心跳
    led(1) <= dds_enable_i;        -- DDS使能
    led(2) <= scan_busy;           -- 扫描进行中
    led(3) <= regs(0)(0);          -- 系统使能

end architecture rtl;
