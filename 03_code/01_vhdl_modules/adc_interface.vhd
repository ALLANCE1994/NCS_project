-- ============================================================================
-- ADC采集接口模块 - M3.2阶段实现
-- ADC Data Acquisition Interface for NV Center ODMR
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.2 ADC采集接口
-- 【知识来源】《ZYNQ 硬件工程知识库》- 跨时钟域处理与FIFO设计
-- 【设计原则】小步快跑：基础ADC接口，后续迭代优化
-- ============================================================================
-- 【Feature Flag】FEATURE_ADC_INTERFACE - 控制ADC接口使能/禁用
--   默认值：'1'（使能）
--   用途：L1回滚防线，出现问题时可快速禁用ADC功能
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ============================================================================
-- 实体定义
-- ============================================================================
entity adc_interface is
    generic (
        -- Feature Flag：ADC接口使能开关（L1回滚防线）
        FEATURE_ADC_INTERFACE : std_logic := '1';
        
        -- ADC数据位宽
        ADC_WIDTH       : integer := 16;
        -- 系统时钟域数据位宽
        DATA_WIDTH      : integer := 16;
        -- FIFO深度（2的幂次）
        FIFO_DEPTH      : integer := 16;  -- 16个样本缓冲
        -- FIFO地址位宽
        FIFO_ADDR_WIDTH : integer := 4    -- log2(16) = 4
    );
    port (
        -- =====================================================================
        -- ADC时钟域接口（50MHz）
        -- =====================================================================
        adc_clk         : in  std_logic;    -- ADC采样时钟
        adc_rst_n       : in  std_logic;    -- ADC域复位
        
        -- ADC数据输入
        adc_data_in     : in  std_logic_vector(ADC_WIDTH-1 downto 0);
        adc_valid_in    : in  std_logic;    -- ADC数据有效
        adc_ovr_in      : in  std_logic;    -- ADC溢出指示
        
        -- =====================================================================
        -- 系统时钟域接口（100MHz）
        -- =====================================================================
        sys_clk         : in  std_logic;    -- 系统时钟
        sys_rst_n       : in  std_logic;    -- 系统域复位
        
        -- 控制接口
        enable          : in  std_logic;    -- 模块使能
        fifo_clear      : in  std_logic;    -- FIFO清零
        
        -- 数据输出
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_valid      : out std_logic;    -- 数据有效
        fifo_empty      : out std_logic;    -- FIFO空指示
        fifo_full       : out std_logic;    -- FIFO满指示
        fifo_count      : out std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);  -- FIFO计数
        
        -- 状态输出
        overflow_flag   : out std_logic;    -- 溢出标志
        overflow_cnt    : out std_logic_vector(15 downto 0)  -- 溢出计数
    );
end entity adc_interface;

-- ============================================================================
-- 架构定义
-- ============================================================================
architecture rtl of adc_interface is

    -- ========================================================================
    -- Feature Flag 控制
    -- ========================================================================
    signal adc_active   : std_logic;
    
    -- ========================================================================
    -- 异步FIFO信号
    -- ========================================================================
    type fifo_mem_type is array (0 to FIFO_DEPTH-1) of 
                          std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_mem     : fifo_mem_type;
    
    -- 写指针（ADC时钟域）
    signal wr_ptr       : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal wr_ptr_gray  : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal wr_ptr_gray_sys : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal wr_ptr_gray_sys_d : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    
    -- 读指针（系统时钟域）
    signal rd_ptr       : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal rd_ptr_gray  : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal rd_ptr_gray_adc : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal rd_ptr_gray_adc_d : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    
    -- FIFO状态
    signal fifo_cnt     : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    signal full_flag    : std_logic;
    signal empty_flag   : std_logic;
    
    -- 写使能
    signal wr_en        : std_logic;
    
    -- ========================================================================
    -- 格雷码转换函数
    -- ========================================================================
    function bin_to_gray(bin : unsigned) return unsigned is
    begin
        return bin xor shift_right(bin, 1);
    end function;
    
    function gray_to_bin(gray : unsigned) return unsigned is
        variable bin : unsigned(gray'range);
    begin
        bin(gray'high) := gray(gray'high);
        for i in gray'high-1 downto gray'low loop
            bin(i) := gray(i) xor bin(i+1);
        end loop;
        return bin;
    end function;
    
    -- ========================================================================
    -- 溢出检测
    -- ========================================================================
    signal ovr_detected : std_logic;
    signal ovr_counter  : unsigned(15 downto 0);

begin

    -- ========================================================================
    -- Feature Flag 控制逻辑（L1回滚防线）
    -- ========================================================================
    adc_active <= enable when FEATURE_ADC_INTERFACE = '1' else '0';

    -- ========================================================================
    -- ADC时钟域：写FIFO
    -- ========================================================================
    process(adc_clk, adc_rst_n)
    begin
        if adc_rst_n = '0' then
            wr_ptr <= (others => '0');
            wr_ptr_gray <= (others => '0');
            ovr_detected <= '0';
        elsif rising_edge(adc_clk) then
            -- 写指针格雷码转换
            wr_ptr_gray <= bin_to_gray(wr_ptr);
            
            -- FIFO写入
            if adc_active = '1' and adc_valid_in = '1' then
                if full_flag = '0' then
                    fifo_mem(to_integer(wr_ptr)) <= adc_data_in;
                    wr_ptr <= wr_ptr + 1;
                end if;
            end if;
            
            -- 溢出检测
            if adc_ovr_in = '1' then
                ovr_detected <= '1';
            end if;
            
            -- FIFO清零
            if fifo_clear = '1' then
                wr_ptr <= (others => '0');
                wr_ptr_gray <= (others => '0');
            end if;
        end if;
    end process;
    
    -- 写使能（用于状态判断）
    wr_en <= adc_active and adc_valid_in and not full_flag;

    -- ========================================================================
    -- 跨时钟域：写指针同步到系统时钟域
    -- ========================================================================
    process(sys_clk, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            wr_ptr_gray_sys <= (others => '0');
            wr_ptr_gray_sys_d <= (others => '0');
        elsif rising_edge(sys_clk) then
            wr_ptr_gray_sys <= wr_ptr_gray;
            wr_ptr_gray_sys_d <= wr_ptr_gray_sys;
        end if;
    end process;

    -- ========================================================================
    -- 系统时钟域：读FIFO
    -- ========================================================================
    process(sys_clk, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            rd_ptr <= (others => '0');
            rd_ptr_gray <= (others => '0');
        elsif rising_edge(sys_clk) then
            -- 读指针格雷码转换
            rd_ptr_gray <= bin_to_gray(rd_ptr);
            
            -- FIFO读取（当FIFO非空时自动读取）
            if empty_flag = '0' then
                rd_ptr <= rd_ptr + 1;
            end if;
            
            -- FIFO清零
            if fifo_clear = '1' then
                rd_ptr <= (others => '0');
                rd_ptr_gray <= (others => '0');
            end if;
        end if;
    end process;
    
    -- 数据输出
    data_out <= fifo_mem(to_integer(rd_ptr));
    data_valid <= not empty_flag;

    -- ========================================================================
    -- 跨时钟域：读指针同步到ADC时钟域
    -- ========================================================================
    process(adc_clk, adc_rst_n)
    begin
        if adc_rst_n = '0' then
            rd_ptr_gray_adc <= (others => '0');
            rd_ptr_gray_adc_d <= (others => '0');
        elsif rising_edge(adc_clk) then
            rd_ptr_gray_adc <= rd_ptr_gray;
            rd_ptr_gray_adc_d <= rd_ptr_gray_adc;
        end if;
    end process;

    -- ========================================================================
    -- FIFO状态计算（系统时钟域）
    -- ========================================================================
    process(wr_ptr_gray_sys_d, rd_ptr)
        variable wr_ptr_bin : unsigned(FIFO_ADDR_WIDTH-1 downto 0);
    begin
        wr_ptr_bin := gray_to_bin(wr_ptr_gray_sys_d);
        
        if wr_ptr_bin >= rd_ptr then
            fifo_cnt <= wr_ptr_bin - rd_ptr;
        else
            fifo_cnt <= to_unsigned(FIFO_DEPTH, FIFO_ADDR_WIDTH) - (rd_ptr - wr_ptr_bin);
        end if;
    end process;
    
    -- 空满判断
    empty_flag <= '1' when fifo_cnt = 0 else '0';
    full_flag <= '1' when fifo_cnt = FIFO_DEPTH-1 else '0';  -- 保留一个位置区分空满

    -- ========================================================================
    -- 溢出计数（系统时钟域）
    -- ========================================================================
    process(sys_clk, sys_rst_n)
    begin
        if sys_rst_n = '0' then
            ovr_counter <= (others => '0');
        elsif rising_edge(sys_clk) then
            if ovr_detected = '1' then
                ovr_counter <= ovr_counter + 1;
            end if;
            
            if fifo_clear = '1' then
                ovr_counter <= (others => '0');
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出端口连接
    -- ========================================================================
    fifo_empty   <= empty_flag;
    fifo_full    <= full_flag;
    fifo_count   <= std_logic_vector(fifo_cnt);
    overflow_flag <= ovr_detected;
    overflow_cnt  <= std_logic_vector(ovr_counter);

end architecture rtl;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第4章 跨时钟域处理 - 异步FIFO设计
-- - 关键内容：格雷码指针同步、空满判断、双时钟域FIFO
-- 
-- 【设计参数】
-- - ADC时钟：50MHz（外部ADC提供）
-- - 系统时钟：100MHz
-- - FIFO深度：16个样本
-- - 数据位宽：16位
-- ============================================================================
