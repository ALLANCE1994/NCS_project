-- ============================================================================
-- NV色心实验系统 - 顶层模块（M4.0 PS集成版 - V2）
-- NV Center ODMR Experiment System - Top Level Module
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M4.0 PS系统集成
-- 【知识来源】M2补充_AXI寄存器详细定义文档.md / arch_base.md
-- 【设计原则】AXI4-Lite从接口统一寄存器映射，PS通过AXI控制PL端
-- ============================================================================
-- 【M4变更说明】
--   - 新增AXI4-Lite从接口（PS→PL寄存器读写）
--   - 时钟/复位改由AXI接口提供（PS7 FCLK_CLK0 @50MHz）
--   - 移除sys_clk_50m/sys_rst_n外部端口
--   - 寄存器地址按4字节对齐（0x00, 0x04, 0x08...）
--   - 各子模块保持不变，通过内部寄存器映射连接
-- ============================================================================
-- 【Feature Flag】FEATURE_TOP_ODMR - 顶层模块使能开关
--   默认值：'1'（使能）
--   用途：L1回滚防线
-- ============================================================================
-- 【寄存器映射】（基于M2补充文档）
--   0x00: CTRL        - 全局控制（R/W）
--   0x04: STATUS      - 全局状态（R）
--   0x08: DDS_FREQ    - DDS频率控制字（R/W）
--   0x0C: DDS_PHASE   - DDS相位偏移（R/W）
--   0x10: SCAN_START  - 扫描起始频率（R/W）
--   0x14: SCAN_STOP   - 扫描终止频率（R/W）
--   0x18: SCAN_STEP   - 扫描步进（R/W）
--   0x1C: SCAN_DWELL  - 驻留时间（R/W）
--   0x20: SCAN_POINTS - 扫描总点数（R/W）
--   0x24: SCAN_CTRL   - 扫描控制（R/W）
--   0x28: ADC_DATA    - ADC数据（R）
--   0x2C: LIA_MAG     - 锁相幅值（R）
--   0x30: LIA_PHASE   - 锁相相位（R）
--   0x34: IIR_DATA    - IIR滤波数据（R）
--   0x38: CUR_FREQ    - 当前频率（R）
--   0x3C: POINT_COUNT - 点计数（R）
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
    -- AXI-Lite寄存器阵列（16个32位寄存器，地址0x00~0x3C，4字节对齐）
    -- ========================================================================
    type reg_array_t is array(0 to 15) of std_logic_vector(31 downto 0);
    signal regs          : reg_array_t;
    
    -- AXI写通道状态
    signal axi_awready_i : std_logic;
    signal axi_wready_i  : std_logic;
    signal axi_bvalid_i  : std_logic;
    signal axi_awaddr_i  : std_logic_vector(11 downto 0);
    
    -- AXI读通道状态
    signal axi_arready_i : std_logic;
    signal axi_rvalid_i  : std_logic;
    signal axi_rdata_i   : std_logic_vector(31 downto 0);
    signal axi_araddr_i  : std_logic_vector(11 downto 0);

    -- ========================================================================
    -- 模块使能信号
    -- ========================================================================
    signal dds_enable_i    : std_logic;
    signal scan_enable_i   : std_logic;
    signal scan_start_i    : std_logic;
    signal scan_stop_i     : std_logic;
    signal global_en_i     : std_logic;

    -- ========================================================================
    -- DDS内部信号
    -- ========================================================================
    signal dds_data_i       : std_logic_vector(13 downto 0);
    signal dds_valid_i      : std_logic;

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
    signal scan_point_count : std_logic_vector(15 downto 0);
    signal scan_total_pts   : std_logic_vector(15 downto 0);
    signal dds_freq_from_scan: std_logic_vector(31 downto 0);
    signal dds_update_from_scan: std_logic;

    -- ========================================================================
    -- LED控制信号
    -- ========================================================================
    signal heartbeat_cnt    : unsigned(24 downto 0);

    -- ========================================================================
    -- 地址解码函数（将AXI地址转为寄存器索引）
    -- 地址0x00,0x04,0x08... -> 索引0,1,2...
    -- ========================================================================
    function addr_to_index(addr : std_logic_vector(11 downto 0)) return integer is
    begin
        return to_integer(unsigned(addr(5 downto 2)));  -- 取bit[5:2]，即除以4
    end function;

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
    -- AXI4-Lite写通道状态机
    -- ========================================================================
    process(sys_clk, s_axi_aresetn)
    begin
        if s_axi_aresetn = '0' then
            axi_awready_i <= '0';
            axi_wready_i  <= '0';
            axi_bvalid_i  <= '0';
            axi_awaddr_i  <= (others => '0');
        elsif rising_edge(sys_clk) then
            -- 写地址就绪：收到AWVALID且当前无未完成的写操作
            if axi_awready_i = '0' and s_axi_awvalid = '1' then
                axi_awready_i <= '1';
                axi_awaddr_i  <= s_axi_awaddr;
            else
                axi_awready_i <= '0';
            end if;
            
            -- 写数据就绪：收到WVALID且当前无未完成的写操作
            if axi_wready_i = '0' and s_axi_wvalid = '1' then
                axi_wready_i <= '1';
            else
                axi_wready_i <= '0';
            end if;
            
            -- 写响应：写数据完成时发出BVALID
            if axi_wready_i = '1' and s_axi_wvalid = '1' then
                axi_bvalid_i <= '1';
            elsif s_axi_bready = '1' then
                axi_bvalid_i <= '0';
            end if;
        end if;
    end process;
    
    s_axi_awready <= axi_awready_i;
    s_axi_wready  <= axi_wready_i;
    s_axi_bvalid  <= axi_bvalid_i;
    s_axi_bresp   <= "00";  -- OKAY

    -- ========================================================================
    -- AXI4-Lite寄存器写入逻辑
    -- ========================================================================
    process(sys_clk)
        variable reg_idx : integer range 0 to 15;
    begin
        if rising_edge(sys_clk) then
            if s_axi_aresetn = '0' then
                -- 复位所有寄存器到默认值
                regs(0)  <= X"00000000";  -- CTRL
                regs(1)  <= X"00000000";  -- STATUS（只读，但初始化为0）
                regs(2)  <= X"00000000";  -- DDS_FREQ
                regs(3)  <= X"00000000";  -- DDS_PHASE
                regs(4)  <= X"00000000";  -- SCAN_START_FREQ
                regs(5)  <= X"00000000";  -- SCAN_STOP_FREQ
                regs(6)  <= X"00000000";  -- SCAN_STEP
                regs(7)  <= X"000003E8";  -- SCAN_DWELL (默认1000)
                regs(8)  <= X"00000000";  -- SCAN_POINTS
                regs(9)  <= X"00000000";  -- SCAN_CTRL
                regs(10) <= X"00000000";  -- ADC_DATA
                regs(11) <= X"00000000";  -- LIA_MAG
                regs(12) <= X"00000000";  -- LIA_PHASE
                regs(13) <= X"00000000";  -- IIR_DATA
                regs(14) <= X"00000000";  -- CUR_FREQ
                regs(15) <= X"00000000";  -- POINT_COUNT
            elsif axi_wready_i = '1' and s_axi_wvalid = '1' then
                -- 写寄存器（地址解码）
                reg_idx := addr_to_index(axi_awaddr_i);
                
                case reg_idx is
                    when 0 => regs(0) <= s_axi_wdata;  -- CTRL (R/W)
                    when 1 => null;                       -- STATUS (只读，忽略写)
                    when 2 => regs(2) <= s_axi_wdata;  -- DDS_FREQ (R/W)
                    when 3 => regs(3) <= s_axi_wdata;  -- DDS_PHASE (R/W)
                    when 4 => regs(4) <= s_axi_wdata;  -- SCAN_START_FREQ (R/W)
                    when 5 => regs(5) <= s_axi_wdata;  -- SCAN_STOP_FREQ (R/W)
                    when 6 => regs(6) <= s_axi_wdata;  -- SCAN_STEP (R/W)
                    when 7 => regs(7) <= s_axi_wdata;  -- SCAN_DWELL (R/W)
                    when 8 => regs(8) <= s_axi_wdata;  -- SCAN_POINTS (R/W)
                    when 9 => regs(9) <= s_axi_wdata;  -- SCAN_CTRL (R/W)
                    when others => null;  -- 其他寄存器只读，忽略写
                end case;
            end if;
        end if;
    end process;

    -- ========================================================================
    -- AXI4-Lite读通道状态机
    -- ========================================================================
    process(sys_clk, s_axi_aresetn)
    begin
        if s_axi_aresetn = '0' then
            axi_arready_i <= '0';
            axi_rvalid_i  <= '0';
            axi_araddr_i  <= (others => '0');
        elsif rising_edge(sys_clk) then
            -- 读地址就绪
            if axi_arready_i = '0' and s_axi_arvalid = '1' then
                axi_arready_i <= '1';
                axi_araddr_i  <= s_axi_araddr;
            else
                axi_arready_i <= '0';
            end if;
            
            -- 读数据有效
            if axi_arready_i = '1' and s_axi_arvalid = '1' then
                axi_rvalid_i <= '1';
            elsif s_axi_rready = '1' then
                axi_rvalid_i <= '0';
            end if;
        end if;
    end process;
    
    s_axi_arready <= axi_arready_i;
    s_axi_rvalid  <= axi_rvalid_i;
    s_axi_rdata   <= axi_rdata_i;
    s_axi_rresp   <= "00";  -- OKAY

    -- ========================================================================
    -- AXI4-Lite寄存器读取逻辑（组合逻辑）
    -- ========================================================================
    process(axi_araddr_i, regs, scan_busy, scan_done, adc_overflow_flag, 
            lia_busy, adc_data_16bit, lia_magnitude, lia_phase, iir_data_out,
            scan_current_freq, scan_point_count)
        variable reg_idx : integer range 0 to 15;
    begin
        reg_idx := addr_to_index(axi_araddr_i);
        
        case reg_idx is
            when 0 => axi_rdata_i <= regs(0);  -- CTRL
            when 1 => -- STATUS: 组合状态位
                axi_rdata_i <= (
                    0 => scan_busy,
                    1 => scan_done,
                    2 => adc_overflow_flag,
                    3 => lia_busy,
                    others => '0'
                );
            when 2 => axi_rdata_i <= regs(2);  -- DDS_FREQ
            when 3 => axi_rdata_i <= regs(3);  -- DDS_PHASE
            when 4 => axi_rdata_i <= regs(4);  -- SCAN_START_FREQ
            when 5 => axi_rdata_i <= regs(5);  -- SCAN_STOP_FREQ
            when 6 => axi_rdata_i <= regs(6);  -- SCAN_STEP
            when 7 => axi_rdata_i <= regs(7);  -- SCAN_DWELL
            when 8 => axi_rdata_i <= regs(8);  -- SCAN_POINTS
            when 9 => axi_rdata_i <= regs(9);  -- SCAN_CTRL
            when 10 => -- ADC_DATA
                axi_rdata_i <= X"0000" & adc_data_16bit;
            when 11 => -- LIA_MAG
                axi_rdata_i <= X"0000" & lia_magnitude;
            when 12 => -- LIA_PHASE
                axi_rdata_i <= X"0000" & lia_phase;
            when 13 => -- IIR_DATA
                axi_rdata_i <= X"0000" & iir_data_out;
            when 14 => -- CUR_FREQ
                axi_rdata_i <= scan_current_freq;
            when 15 => -- POINT_COUNT
                axi_rdata_i <= X"0000" & scan_point_count;
            when others => axi_rdata_i <= (others => '0');
        end case;
    end process;

    -- ========================================================================
    -- 控制信号映射（从AXI寄存器到内部信号）
    -- ========================================================================
    global_en_i   <= regs(0)(0);   -- CTRL[0] = GLOBAL_EN
    dds_enable_i  <= regs(0)(1);   -- CTRL[1] = DDS_EN
    scan_enable_i <= regs(0)(2);   -- CTRL[2] = SCAN_EN
    scan_start_i  <= regs(9)(0);   -- SCAN_CTRL[0] = START
    scan_stop_i   <= regs(9)(1);   -- SCAN_CTRL[1] = STOP
    scan_total_pts<= regs(8)(15 downto 0);  -- SCAN_POINTS低16位

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
    
    dds_data_out <= dds_data_i;
    dds_valid    <= dds_valid_i;

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
            enable          => global_en_i,
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
    -- ========================================================================
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
            enable       => global_en_i,
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
            enable     => global_en_i,
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
            stop_scan       => scan_stop_i,
            freq_start      => regs(4),           -- SCAN_START_FREQ
            freq_stop       => regs(5),           -- SCAN_STOP_FREQ
            freq_step       => regs(6),           -- SCAN_STEP
            dwell_time      => regs(7)(15 downto 0), -- SCAN_DWELL低16位
            total_points_in => regs(8)(15 downto 0), -- SCAN_POINTS低16位
            dds_freq_out    => dds_freq_from_scan,
            dds_update      => dds_update_from_scan,
            acq_trigger     => scan_trigger,
            acq_busy        => scan_sync,
            scan_busy       => scan_busy,
            scan_done       => scan_done,
            current_freq    => scan_current_freq,
            point_count     => scan_point_count,
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
    led(3) <= global_en_i;         -- 系统使能

end architecture rtl;
