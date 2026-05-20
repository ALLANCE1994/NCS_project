-- ============================================================================
-- DDS信号发生器模块 - M3.1阶段实现
-- Direct Digital Synthesizer for NV Center ODMR Experiment
-- ============================================================================
-- 【负责智能体】@H 硬件工程师
-- 【所属项目】NV色心实验系统（NCS_project）
-- 【目标平台】正点原子领航者ZYNQ7020（XC7Z020CLG400-2）
-- 【开发阶段】M3.1 DDS信号发生器
-- 【知识来源】《ZYNQ 硬件工程知识库》- FPGA资源与RTL设计
-- 【设计原则】小步快跑：基础框架实现，后续迭代优化
-- ============================================================================
-- 【Feature Flag】FEATURE_DDS_GENERATOR - 控制DDS模块使能/禁用
--   默认值：'1'（使能）
--   用途：L1回滚防线，出现问题时可快速禁用DDS功能
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- ============================================================================
-- 实体定义
-- ============================================================================
entity dds_generator is
    generic (
        -- Feature Flag：DDS模块使能开关（L1回滚防线）
        FEATURE_DDS_GENERATOR : std_logic := '1';
        
        -- 相位累加器位宽（32位提供0.023Hz@100MHz分辨率）
        PHASE_WIDTH     : integer := 32;
        -- DAC数据位宽（14位匹配AD9910）
        DATA_WIDTH      : integer := 14;
        -- ROM地址位宽（12位=4096点/周期）
        ROM_ADDR_WIDTH  : integer := 12
    );
    port (
        -- =====================================================================
        -- 系统接口
        -- =====================================================================
        clk             : in  std_logic;    -- 系统时钟（100MHz）
        rst_n           : in  std_logic;    -- 复位，低电平有效
        
        -- =====================================================================
        -- 控制接口（来自AXI寄存器）
        -- =====================================================================
        freq_ctrl       : in  std_logic_vector(PHASE_WIDTH-1 downto 0);  -- 频率控制字
        phase_offset    : in  std_logic_vector(PHASE_WIDTH-1 downto 0);  -- 相位偏移
        enable          : in  std_logic;                                 -- 模块使能
        
        -- =====================================================================
        -- 输出接口（至外部DAC）
        -- =====================================================================
        data_out        : out std_logic_vector(DATA_WIDTH-1 downto 0);   -- DDS数据输出
        valid_out       : out std_logic;                                 -- 数据有效
        clk_out         : out std_logic                                  -- 同步时钟输出
    );
end entity dds_generator;

-- ============================================================================
-- 架构定义
-- ============================================================================
architecture rtl of dds_generator is

    -- ========================================================================
    -- 内部信号定义
    -- ========================================================================
    
    -- 相位累加器
    signal phase_acc    : unsigned(PHASE_WIDTH-1 downto 0);
    signal phase_next   : unsigned(PHASE_WIDTH-1 downto 0);
    
    -- ROM地址（取相位累加器高12位）
    signal rom_addr     : unsigned(ROM_ADDR_WIDTH-1 downto 0);
    
    -- ROM数据输出
    signal rom_data     : signed(DATA_WIDTH-1 downto 0);
    
    -- 输出寄存
    signal data_reg     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal valid_reg    : std_logic;
    
    -- Feature Flag 控制信号
    signal dds_active   : std_logic;

    -- ========================================================================
    -- 正弦ROM查找表（使用函数生成，综合时自动推断为Block RAM）
    -- ========================================================================
    type rom_type is array (0 to 2**ROM_ADDR_WIDTH-1) of signed(DATA_WIDTH-1 downto 0);
    
    -- 正弦表生成函数
    function init_sin_rom return rom_type is
        variable rom : rom_type;
        variable sin_val : real;
        variable scaled_val : integer;
    begin
        for i in 0 to 2**ROM_ADDR_WIDTH-1 loop
            -- 计算正弦值（0到2π映射到0到4095）
            sin_val := sin(2.0 * MATH_PI * real(i) / real(2**ROM_ADDR_WIDTH));
            -- 缩放至14位有符号整数范围（-8192到8191）
            scaled_val := integer(sin_val * real(2**(DATA_WIDTH-1) - 1));
            rom(i) := to_signed(scaled_val, DATA_WIDTH);
        end loop;
        return rom;
    end function;
    
    -- ROM实例（使用函数初始化）
    constant SIN_ROM : rom_type := init_sin_rom;

begin

    -- ========================================================================
    -- Feature Flag 控制逻辑（L1回滚防线）
    -- ========================================================================
    -- 当 FEATURE_DDS_GENERATOR='0' 时，模块被禁用，输出固定值
    dds_active <= enable when FEATURE_DDS_GENERATOR = '1' else '0';

    -- ========================================================================
    -- 相位累加器（DDS核心）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            phase_acc <= (others => '0');
        elsif rising_edge(clk) then
            if dds_active = '1' then
                -- 相位累加：当前相位 + 频率控制字 + 相位偏移
                phase_acc <= phase_next;
            else
                phase_acc <= (others => '0');
            end if;
        end if;
    end process;
    
    -- 组合逻辑：计算下一相位
    phase_next <= phase_acc + unsigned(freq_ctrl) + unsigned(phase_offset);
    
    -- 提取ROM地址（相位累加器高12位）
    rom_addr <= phase_acc(PHASE_WIDTH-1 downto PHASE_WIDTH-ROM_ADDR_WIDTH);

    -- ========================================================================
    -- 正弦ROM查找（组合逻辑）
    -- ========================================================================
    rom_data <= SIN_ROM(to_integer(rom_addr));

    -- ========================================================================
    -- 输出寄存器（打一拍，改善时序）
    -- ========================================================================
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            data_reg  <= (others => '0');
            valid_reg <= '0';
        elsif rising_edge(clk) then
            if dds_active = '1' then
                data_reg  <= std_logic_vector(rom_data);
                valid_reg <= '1';
            else
                data_reg  <= (others => '0');
                valid_reg <= '0';
            end if;
        end if;
    end process;

    -- ========================================================================
    -- 输出端口连接
    -- ========================================================================
    data_out  <= data_reg;
    valid_out <= valid_reg;
    clk_out   <= clk when dds_active = '1' else '0';

end architecture rtl;

-- ============================================================================
-- 【知识来源】
-- - 文档名称：《ZYNQ 硬件工程知识库》
-- - 核心出处：第4章 FPGA资源与RTL设计 - DDS原理与实现
-- - 关键内容：相位累加器原理、ROM查找表、Block RAM推断
-- 
-- 【设计参数】
-- - 系统时钟：100MHz
-- - 相位累加器：32位
-- - 频率分辨率：100MHz / 2^32 = 0.023Hz
-- - ROM深度：4096点（12位地址）
-- - 数据位宽：14位（匹配AD9910）
-- ============================================================================
