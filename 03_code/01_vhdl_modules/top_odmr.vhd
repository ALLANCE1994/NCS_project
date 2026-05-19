-- ============================================================================
-- NV色心实验系统顶层模块
-- Top Level Module for NV Center ODMR Experiment System
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.0 顶层模块框架
-- 【知识来源】《ZYNQ 硬件工程知识库》- XDC约束、引脚分配
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 顶层实体定义
-- ============================================================================
entity top_odmr is
    port (
        -- =====================================================================
        -- 系统时钟与复位
        -- =====================================================================
        sys_clk_50m     : in  std_logic;    -- 50MHz系统时钟（来自板载晶振）
        sys_rst_n       : in  std_logic;    -- 系统复位，低电平有效
        
        -- =====================================================================
        -- PL端外设接口
        -- =====================================================================
        -- LED指示（用于状态显示）
        led             : out std_logic_vector(1 downto 0);
        
        -- 按键输入（用于手动触发/模式切换）
        key             : in  std_logic_vector(1 downto 0);
        
        -- =====================================================================
        -- DDS信号发生器接口（M3.1子模块）
        -- =====================================================================
        dds_clk_out     : out std_logic;    -- DDS时钟输出（至外部DAC）
        dds_data_out    : out std_logic_vector(13 downto 0);  -- DDS数据输出
        dds_valid       : out std_logic;    -- DDS数据有效指示
        
        -- =====================================================================
        -- ADC采集接口（M3.2子模块）
        -- =====================================================================
        adc_clk_in      : in  std_logic;    -- ADC采样时钟输入
        adc_data_in     : in  std_logic_vector(15 downto 0);  -- ADC数据输入
        adc_valid       : in  std_logic;    -- ADC数据有效指示
        adc_ovr         : in  std_logic;    -- ADC溢出指示
        
        -- =====================================================================
        -- 扫描控制接口（M3.4子模块）
        -- =====================================================================
        scan_trigger    : out std_logic;    -- 扫描触发信号
        scan_sync       : in  std_logic;    -- 扫描同步信号
        
        -- =====================================================================
        -- AXI-Lite接口（连接ZYNQ PS端）
        -- =====================================================================
        -- 时钟与复位
        s_axi_aclk      : in  std_logic;    -- AXI时钟
        s_axi_aresetn   : in  std_logic;    -- AXI复位，低电平有效
        
        -- 写地址通道
        s_axi_awaddr    : in  std_logic_vector(31 downto 0);
        s_axi_awprot    : in  std_logic_vector(2 downto 0);
        s_axi_awvalid   : in  std_logic;
        s_axi_awready   : out std_logic;
        
        -- 写数据通道
        s_axi_wdata     : in  std_logic_vector(31 downto 0);
        s_axi_wstrb     : in  std_logic_vector(3 downto 0);
        s_axi_wvalid    : in  std_logic;
        s_axi_wready    : out std_logic;
        
        -- 写响应通道
        s_axi_bresp     : out std_logic_vector(1 downto 0);
        s_axi_bvalid    : out std_logic;
        s_axi_bready    : in  std_logic;
        
        -- 读地址通道
        s_axi_araddr    : in  std_logic_vector(31 downto 0);
        s_axi_arprot    : in  std_logic_vector(2 downto 0);
        s_axi_arvalid   : in  std_logic;
        s_axi_arready   : out std_logic;
        
        -- 读数据通道
        s_axi_rdata     : out std_logic_vector(31 downto 0);
        s_axi_rresp     : out std_logic_vector(1 downto 0);
        s_axi_rvalid    : out std_logic;
        s_axi_rready    : in  std_logic
    );
end entity top_odmr;

-- ============================================================================
-- 顶层架构定义
-- ============================================================================
architecture structural of top_odmr is

    -- ========================================================================
    -- 内部信号定义
    -- ========================================================================
    
    -- 时钟信号
    signal clk_100m       : std_logic;      -- 100MHz系统时钟（由PLL生成）
    signal clk_100m_locked: std_logic;      -- PLL锁定指示
    
    -- 复位信号
    signal rst_sync       : std_logic;      -- 同步复位信号
    
    -- LED控制信号
    signal led_reg        : std_logic_vector(1 downto 0);
    
    -- ========================================================================
    -- 子模块接口信号（预留，M3.1-M3.5逐步实现）
    -- ========================================================================
    
    -- DDS模块接口（M3.1）
    signal dds_freq_ctrl  : std_logic_vector(31 downto 0);  -- DDS频率控制字
    signal dds_enable     : std_logic;                        -- DDS使能
    
    -- ADC模块接口（M3.2）
    signal adc_data_out   : std_logic_vector(15 downto 0);  -- ADC处理后数据
    signal adc_data_valid : std_logic;                        -- ADC数据有效
    
    -- CORDIC模块接口（M3.3）
    signal cordic_i_in    : std_logic_vector(15 downto 0);  -- CORDIC I路输入
    signal cordic_q_in    : std_logic_vector(15 downto 0);  -- CORDIC Q路输入
    signal cordic_phase_out: std_logic_vector(15 downto 0); -- CORDIC相位输出
    
    -- 扫描控制器接口（M3.4）
    signal scan_freq_start: std_logic_vector(31 downto 0);  -- 扫描起始频率
    signal scan_freq_stop : std_logic_vector(31 downto 0);  -- 扫描终止频率
    signal scan_step      : std_logic_vector(15 downto 0);  -- 扫描步进
    signal scan_busy      : std_logic;                        -- 扫描进行中
    
    -- IIR滤波器接口（M3.5）
    signal iir_data_in    : std_logic_vector(15 downto 0);  -- IIR输入数据
    signal iir_data_out   : std_logic_vector(15 downto 0);  -- IIR输出数据

    -- ========================================================================
    -- AXI寄存器定义（PS端控制接口）
    -- ========================================================================
    
    -- 控制寄存器
    signal reg_control    : std_logic_vector(31 downto 0);  -- 0x00: 全局控制
    signal reg_dds_freq   : std_logic_vector(31 downto 0);  -- 0x04: DDS频率
    signal reg_scan_start : std_logic_vector(31 downto 0);  -- 0x08: 扫描起始
    signal reg_scan_stop  : std_logic_vector(31 downto 0);  -- 0x0C: 扫描终止
    signal reg_scan_step  : std_logic_vector(31 downto 0);  -- 0x10: 扫描步进
    signal reg_status     : std_logic_vector(31 downto 0);  -- 0x14: 状态寄存器
    
    -- AXI接口信号
    signal axi_awaddr_reg : std_logic_vector(31 downto 0);
    signal axi_araddr_reg : std_logic_vector(31 downto 0);
    signal axi_write_ready: std_logic;
    signal axi_read_ready : std_logic;

begin

    -- ========================================================================
    -- 时钟管理（使用PLL生成100MHz系统时钟）
    -- ========================================================================
    -- 注意：实际实现时使用Clocking Wizard IP核
    -- 此处为框架定义，M3.1阶段完善
    
    clk_100m <= sys_clk_50m;  -- 临时直连，后续替换为PLL输出
    clk_100m_locked <= '1';    -- 临时置1，后续由PLL提供
    
    -- ========================================================================
    -- 复位同步（异步复位，同步释放）
    -- ========================================================================
    process(sys_clk_50m, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            rst_sync <= '1';
        elsif rising_edge(sys_clk_50m) then
            rst_sync <= not clk_100m_locked;
        end if;
    end process;
    
    -- ========================================================================
    -- LED状态指示
    -- ========================================================================
    process(sys_clk_50m, rst_sync)
        variable cnt : unsigned(24 downto 0);
    begin
        if rst_sync = '1' then
            cnt := (others => '0');
            led_reg <= "00";
        elsif rising_edge(sys_clk_50m) then
            cnt := cnt + 1;
            if cnt = 0 then
                led_reg <= not led_reg;  -- LED闪烁指示系统运行
            end if;
        end if;
    end process;
    
    led <= led_reg;
    
    -- ========================================================================
    -- 子模块实例化区域（M3.1-M3.5逐步实现）
    -- ========================================================================
    
    -- ------------------------------------------------------------------------
    -- M3.1: DDS信号发生器实例化（占位符）
    -- ------------------------------------------------------------------------
    -- dds_generator_inst: entity work.dds_generator
    --     port map (
    --         clk         => clk_100m,
    --         rst         => rst_sync,
    --         freq_ctrl   => dds_freq_ctrl,
    --         enable      => dds_enable,
    --         data_out    => dds_data_out,
    --         valid_out   => dds_valid,
    --         clk_out     => dds_clk_out
    --     );
    
    -- 临时输出
    dds_clk_out  <= clk_100m;
    dds_data_out <= (others => '0');
    dds_valid    <= '0';
    
    -- ------------------------------------------------------------------------
    -- M3.2: ADC采集接口实例化（占位符）
    -- ------------------------------------------------------------------------
    -- adc_interface_inst: entity work.adc_interface
    --     port map (...);
    
    adc_data_out   <= adc_data_in;
    adc_data_valid <= adc_valid;
    
    -- ------------------------------------------------------------------------
    -- M3.3: CORDIC数字锁相实例化（占位符）
    -- ------------------------------------------------------------------------
    -- cordic_lia_inst: entity work.cordic_lia
    --     port map (...);
    
    cordic_phase_out <= (others => '0');
    
    -- ------------------------------------------------------------------------
    -- M3.4: 扫描状态机实例化（占位符）
    -- ------------------------------------------------------------------------
    -- scan_controller_inst: entity work.scan_controller
    --     port map (...);
    
    scan_trigger <= '0';
    scan_busy    <= '0';
    
    -- ------------------------------------------------------------------------
    -- M3.5: IIR低通滤波器实例化（占位符）
    -- ------------------------------------------------------------------------
    -- iir_lowpass_inst: entity work.iir_lowpass
    --     port map (...);
    
    iir_data_out <= iir_data_in;
    
    -- ========================================================================
    -- AXI-Lite接口实现（基础寄存器读写）
    -- ========================================================================
    
    -- 写地址通道
    s_axi_awready <= axi_write_ready;
    
    -- 写数据通道
    s_axi_wready <= axi_write_ready;
    
    -- 写响应通道
    s_axi_bresp  <= "00";  -- OKAY响应
    s_axi_bvalid <= '1' when (s_axi_wvalid = '1' and s_axi_awvalid = '1') else '0';
    
    -- 读地址通道
    s_axi_arready <= axi_read_ready;
    
    -- 读数据通道
    s_axi_rdata  <= reg_control when axi_araddr_reg = X"00000000" else
                    reg_dds_freq when axi_araddr_reg = X"00000004" else
                    reg_scan_start when axi_araddr_reg = X"00000008" else
                    reg_scan_stop when axi_araddr_reg = X"0000000C" else
                    reg_scan_step when axi_araddr_reg = X"00000010" else
                    reg_status when axi_araddr_reg = X"00000014" else
                    (others => '0');
    s_axi_rresp  <= "00";  -- OKAY响应
    s_axi_rvalid <= axi_read_ready;
    
    -- AXI控制逻辑（简化版，M3.1阶段完善）
    process(s_axi_aclk, s_axi_aresetn)
    begin
        if s_axi_aresetn = '0' then
            axi_awaddr_reg  <= (others => '0');
            axi_araddr_reg  <= (others => '0');
            axi_write_ready <= '0';
            axi_read_ready  <= '0';
            reg_control     <= (others => '0');
            reg_dds_freq    <= (others => '0');
            reg_scan_start  <= (others => '0');
            reg_scan_stop   <= (others => '0');
            reg_scan_step   <= (others => '0');
            reg_status      <= X"00000001";  -- 系统就绪
            
        elsif rising_edge(s_axi_aclk) then
            -- 写地址锁存
            if s_axi_awvalid = '1' and axi_write_ready = '0' then
                axi_awaddr_reg <= s_axi_awaddr;
                axi_write_ready <= '1';
            else
                axi_write_ready <= '0';
            end if;
            
            -- 写数据寄存器更新
            if s_axi_wvalid = '1' and s_axi_awvalid = '1' then
                case s_axi_awaddr is
                    when X"00000000" => reg_control <= s_axi_wdata;
                    when X"00000004" => reg_dds_freq <= s_axi_wdata;
                    when X"00000008" => reg_scan_start <= s_axi_wdata;
                    when X"0000000C" => reg_scan_stop <= s_axi_wdata;
                    when X"00000010" => reg_scan_step <= s_axi_wdata;
                    when others => null;
                end case;
            end if;
            
            -- 读地址锁存
            if s_axi_arvalid = '1' and axi_read_ready = '0' then
                axi_araddr_reg <= s_axi_araddr;
                axi_read_ready <= '1';
            else
                axi_read_ready <= '0';
            end if;
            
        end if;
    end process;
    
    -- 寄存器映射到内部信号
    dds_freq_ctrl   <= reg_dds_freq;
    dds_enable      <= reg_control(0);
    scan_freq_start <= reg_scan_start;
    scan_freq_stop  <= reg_scan_stop;
    scan_step       <= reg_scan_step(15 downto 0);

end architecture structural;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第2章 XDC约束与时序约束、第4章 原理图引脚与板级资源
-- - 关键内容：ZYNQ7020引脚分配、AXI总线接口定义、时钟管理
-- ============================================================================
