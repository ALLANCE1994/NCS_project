#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SRS SG386微波源USB控制驱动
负责智能体：【@S 软件工程师】
功能：控制SG386微波源的频率、功率、调制等参数
硬件接口：USB转串口 (FTDI FT232R)
适用场景：NV色心ODMR实验微波激发

【知识来源】：SRS SG386用户手册 + NV项目物理参数要求
"""

import serial
import time
import logging
from typing import Optional, Tuple

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('SG386_Controller')


class SG386Controller:
    """
    【@S 软件工程师】SRS SG386微波源控制器
    
    SG386是Stanford Research Systems生产的微波频率综合器，
    频率范围10-20 GHz，用于NV色心ODMR实验的微波激发。
    
    主要特性：
    - 频率范围: 10-20 GHz
    - 频率分辨率: 1 Hz
    - 功率范围: -75 to +10 dBm
    - 调制模式: AM, FM, PM, PULSE
    """
    
    # ============================================================
    # 硬件参数常量
    # ============================================================
    FREQ_MIN = 10e9       # 10 GHz (最小频率)
    FREQ_MAX = 20e9       # 20 GHz (最大频率)
    FREQ_RESOLUTION = 1   # 1 Hz (频率分辨率)
    
    POWER_MIN = -75.0     # -75 dBm (最小功率)
    POWER_MAX = 10.0      # +10 dBm (最大功率)
    POWER_RESOLUTION = 0.01  # 0.01 dBm (功率分辨率)
    
    # 串口默认参数
    DEFAULT_PORT = '/dev/ttyUSB0'
    DEFAULT_BAUDRATE = 115200
    DEFAULT_TIMEOUT = 1.0
    
    # ============================================================
    # 初始化与资源管理
    # ============================================================
    
    def __init__(self, port: str = DEFAULT_PORT, baudrate: int = DEFAULT_BAUDRATE):
        """
        【@S 软件工程师】初始化SG386控制器
        
        Args:
            port: 串口设备路径
                - Linux: '/dev/ttyUSB0'
                - Windows: 'COM3'
            baudrate: 波特率 (固定115200)
        
        Returns:
            None
        
        Raises:
            serial.SerialException: 串口打开失败
        """
        self.port = port
        self.baudrate = baudrate
        self.ser: Optional[serial.Serial] = None
        self._is_connected = False
        
        try:
            self.ser = serial.Serial(
                port=port,
                baudrate=baudrate,
                timeout=self.DEFAULT_TIMEOUT,
                bytesize=serial.EIGHTBITS,
                parity=serial.PARITY_NONE,
                stopbits=serial.STOPBITS_ONE
            )
            self._is_connected = True
            logger.info(f"【@S 软件工程师】SG386串口已打开: {port} @ {baudrate} bps")
            time.sleep(0.5)  # 等待设备初始化
            
            # 查询设备ID确认连接
            device_id = self.query("*IDN?")
            logger.info(f"【@S 软件工程师】设备ID: {device_id}")
            
        except serial.SerialException as e:
            logger.error(f"【@S 软件工程师】串口打开失败: {e}")
            self._is_connected = False
            raise
    
    def __enter__(self):
        """上下文管理器入口"""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """上下文管理器出口，自动关闭串口"""
        self.close()
        return False
    
    # ============================================================
    # 串口通信基础
    # ============================================================
    
    def _send_command(self, cmd: str) -> bool:
        """
        【@S 软件工程师】发送SCPI命令到设备
        
        Args:
            cmd: SCPI格式命令字符串
        
        Returns:
            bool: 发送成功返回True
        
        Raises:
            ConnectionError: 串口未连接
        """
        if not self._is_connected:
            raise ConnectionError("SG386串口未连接")
        
        try:
            cmd_bytes = (cmd + '\n').encode('ascii')
            self.ser.write(cmd_bytes)
            self.ser.flush()
            logger.debug(f"【@S 软件工程师】发送: {cmd.strip()}")
            return True
        except Exception as e:
            logger.error(f"【@S 软件工程师】命令发送失败: {e}")
            return False
    
    def _read_response(self, timeout: float = 0.1) -> str:
        """
        【@S 软件工程师】读取设备响应
        
        Args:
            timeout: 读取超时时间(秒)
        
        Returns:
            str: 设备响应字符串，无响应返回空字符串
        """
        if not self._is_connected:
            return ""
        
        try:
            # 设置临时超时
            original_timeout = self.ser.timeout
            self.ser.timeout = timeout
            
            response = b''
            start_time = time.time()
            
            # 循环读取直到超时或达到最大长度
            while time.time() - start_time < timeout:
                if self.ser.in_waiting > 0:
                    chunk = self.ser.read(self.ser.in_waiting)
                    response += chunk
                time.sleep(0.01)
            
            # 恢复原始超时
            self.ser.timeout = original_timeout
            
            return response.decode('ascii', errors='ignore').strip()
            
        except Exception as e:
            logger.error(f"【@S 软件工程师】读取响应失败: {e}")
            return ""
    
    def query(self, cmd: str, timeout: float = 0.1) -> str:
        """
        【@S 软件工程师】发送命令并读取响应（SCPI标准查询）
        
        Args:
            cmd: SCPI查询命令（以?结尾）
            timeout: 响应超时时间
        
        Returns:
            str: 设备响应
        """
        self._send_command(cmd)
        return self._read_response(timeout)
    
    # ============================================================
    # 频率控制
    # ============================================================
    
    def set_frequency(self, freq_hz: float) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设置输出频率
        
        Args:
            freq_hz: 频率值(Hz)，范围10-20 GHz
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        
        Raises:
            ValueError: 频率超出范围
        
        Example:
            >>> sg.set_frequency(2.87e9)  # 设置为2.87 GHz
            (True, '2.870000000 GHz')
        """
        # 参数校验
        if not (self.FREQ_MIN <= freq_hz <= self.FREQ_MAX):
            raise ValueError(
                f"频率{freq_hz/1e9:.2f} GHz超出范围 "
                f"[{self.FREQ_MIN/1e9:.0f}, {self.FREQ_MAX/1e9:.0f}] GHz"
            )
        
        # SG386使用THz单位，保留9位小数
        freq_thz = freq_hz / 1e12
        cmd = f"FREQ {freq_thz:.9f} THz"
        
        success = self._send_command(cmd)
        response = self._read_response()
        
        if success:
            logger.info(f"【@S 软件工程师】频率设置: {freq_hz/1e9:.6f} GHz")
        
        return success, response
    
    def get_frequency(self) -> float:
        """
        【@S 软件工程师】读取当前频率设置
        
        Returns:
            float: 当前频率(Hz)
        """
        response = self.query("FREQ?")
        
        try:
            # 解析响应，提取数值
            # 格式: "2.870000000 THz"
            freq_thz = float(response.split()[0])
            freq_hz = freq_thz * 1e12
            return freq_hz
        except (ValueError, IndexError) as e:
            logger.error(f"【@S 软件工程师】频率读取失败: {e}")
            return 0.0
    
    # ============================================================
    # 功率控制
    # ============================================================
    
    def set_power(self, power_dbm: float) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设置输出功率
        
        Args:
            power_dbm: 功率值(dBm)，范围-75到+10 dBm
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        
        Raises:
            ValueError: 功率超出范围
        
        Example:
            >>> sg.set_power(-10.0)  # 设置为-10 dBm
            (True, '-10.00 dBm')
        """
        # 参数校验
        if not (self.POWER_MIN <= power_dbm <= self.POWER_MAX):
            raise ValueError(
                f"功率{power_dbm:.2f} dBm超出范围 "
                f"[{self.POWER_MIN:.0f}, {self.POWER_MAX:.0f}] dBm"
            )
        
        # SG386功率命令格式
        cmd = f"AMPL {power_dbm:.2f} DBM"
        
        success = self._send_command(cmd)
        response = self._read_response()
        
        if success:
            logger.info(f"【@S 软件工程师】功率设置: {power_dbm:.2f} dBm")
        
        return success, response
    
    def get_power(self) -> float:
        """
        【@S 软件工程师】读取当前功率设置
        
        Returns:
            float: 当前功率(dBm)
        """
        response = self.query("AMPL?")
        
        try:
            # 解析响应
            # 格式: "-10.00 dBm"
            power_dbm = float(response.split()[0])
            return power_dbm
        except (ValueError, IndexError) as e:
            logger.error(f"【@S 软件工程师】功率读取失败: {e}")
            return 0.0
    
    # ============================================================
    # 输出开关控制
    # ============================================================
    
    def output_on(self) -> Tuple[bool, str]:
        """
        【@S 软件工程师】开启微波输出
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        
        Note:
            开启输出后，微波信号从RF OUTPUT端口输出
        """
        success = self._send_command("ENBR 1")
        response = self._read_response()
        
        if success:
            logger.info("【@S 软件工程师】微波输出已开启")
        
        return success, response
    
    def output_off(self) -> Tuple[bool, str]:
        """
        【@S 软件工程师】关闭微波输出
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        """
        success = self._send_command("ENBR 0")
        response = self._read_response()
        
        if success:
            logger.info("【@S 软件工程师】微波输出已关闭")
        
        return success, response
    
    def get_output_status(self) -> bool:
        """
        【@S 软件工程师】查询输出状态
        
        Returns:
            bool: True=开启, False=关闭
        """
        response = self.query("ENBR?")
        return "1" in response
    
    # ============================================================
    # 调制控制 (AM/FM/PM/PULSE)
    # ============================================================
    
    def set_amplitude_modulation(
        self, 
        enable: bool, 
        depth_percent: float = 100.0,
        frequency_hz: float = 1e3
    ) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设置幅度调制(AM)
        
        Args:
            enable: 是否启用AM
            depth_percent: 调制深度(0-100%)
            frequency_hz: 调制频率(Hz)
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        
        Note:
            AM调制用于NV色心的微波幅值调制实验
        """
        if enable:
            # 启用AM
            self._send_command("AM ON")
            # 设置调制深度
            self._send_command(f"AM:DEP {depth_percent:.1f}")
            # 设置调制频率
            self._send_command(f"AM:FREQ {frequency_hz:.2f}")
            logger.info(
                f"【@S 软件工程师】AM已启用: "
                f"深度={depth_percent:.1f}%, 频率={frequency_hz:.1f} Hz"
            )
        else:
            self._send_command("AM OFF")
            logger.info("【@S 软件工程师】AM已禁用")
        
        return True, ""
    
    def set_frequency_modulation(
        self,
        enable: bool,
        deviation_hz: float = 1e6,
        rate_hz: float = 1e3
    ) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设置频率调制(FM)
        
        Args:
            enable: 是否启用FM
            deviation_hz: 频偏(Hz)
            rate_hz: 调制速率(Hz)
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        """
        if enable:
            self._send_command("FM ON")
            # 设置频偏
            self._send_command(f"FM:DEV {deviation_hz:.0f}")
            # 设置调制速率
            self._send_command(f"FM:RATE {rate_hz:.2f}")
            logger.info(
                f"【@S 软件工程师】FM已启用: "
                f"频偏={deviation_hz/1e6:.2f} MHz, 速率={rate_hz:.1f} Hz"
            )
        else:
            self._send_command("FM OFF")
            logger.info("【@S 软件工程师】FM已禁用")
        
        return True, ""
    
    def set_pulse_modulation(
        self,
        enable: bool,
        period_us: float = 1000.0,
        width_us: float = 100.0
    ) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设置脉冲调制
        
        Args:
            enable: 是否启用脉冲调制
            period_us: 脉冲周期(微秒)
            width_us: 脉冲宽度(微秒)
        
        Returns:
            Tuple[bool, str]: (是否成功, 设备响应)
        
        Note:
            脉冲调制用于NV色心的脉冲ODMR实验
        """
        if enable:
            self._send_command("PM ON")
            # 设置脉冲周期和宽度
            self._send_command(f"PM:PER {period_us:.2f}")
            self._send_command(f"PM:WID {width_us:.2f}")
            logger.info(
                f"【@S 软件工程师】脉冲调制已启用: "
                f"周期={period_us:.1f} us, 宽度={width_us:.1f} us"
            )
        else:
            self._send_command("PM OFF")
            logger.info("【@S 软件工程师】脉冲调制已禁用")
        
        return True, ""
    
    # ============================================================
    # 状态查询
    # ============================================================
    
    def get_status(self) -> dict:
        """
        【@S 软件工程师】获取完整状态信息
        
        Returns:
            dict: 状态信息字典
                - frequency: 频率(Hz)
                - power: 功率(dBm)
                - output_on: 输出开关状态
                - connected: 连接状态
        """
        return {
            'frequency': self.get_frequency(),
            'power': self.get_power(),
            'output_on': self.get_output_status(),
            'connected': self._is_connected
        }
    
    def self_test(self) -> Tuple[bool, str]:
        """
        【@S 软件工程师】设备自检
        
        Returns:
            Tuple[bool, str]: (是否通过, 状态信息)
        """
        try:
            # 查询设备ID
            device_id = self.query("*IDN?")
            
            # 查询状态寄存器
            status = self.query("*STB?")
            
            # 查询错误
            error = self.query("ERR?")
            
            is_ok = "SG386" in device_id and "0," not in error
            
            info = f"ID: {device_id}, STB: {status}, ERR: {error}"
            
            if is_ok:
                logger.info(f"【@S 软件工程师】自检通过: {info}")
            else:
                logger.warning(f"【@S 软件工程师】自检警告: {info}")
            
            return is_ok, info
            
        except Exception as e:
            logger.error(f"【@S 软件工程师】自检失败: {e}")
            return False, str(e)
    
    # ============================================================
    # 资源清理
    # ============================================================
    
    def close(self):
        """
        【@S 软件工程师】关闭串口连接
        
        Note:
            推荐使用with语句自动管理:
            >>> with SG386Controller() as sg:
            ...     sg.set_frequency(2.87e9)
        """
        if self.ser and self.ser.is_open:
            # 确保输出关闭
            self.output_off()
            # 关闭串口
            self.ser.close()
            logger.info("【@S 软件工程师】SG386串口已关闭")
        
        self._is_connected = False
    
    def __del__(self):
        """析构函数，确保资源释放"""
        self.close()


# ============================================================
# 主程序入口
# ============================================================

if __name__ == '__main__':
    """【@S 软件工程师】SG386控制使用示例"""
    
    print("=" * 60)
    print("SRS SG386微波源控制示例")
    print("=" * 60)
    
    # 使用上下文管理器自动管理资源
    try:
        with SG386Controller() as sg:
            # 自检
            print("\n[1] 设备自检...")
            ok, info = sg.self_test()
            print(f"    结果: {'通过' if ok else '失败'}")
            print(f"    信息: {info}")
            
            # 设置频率 (NV色心典型频率 ~2.87 GHz)
            print("\n[2] 设置频率...")
            freq = 2.87e9  # 2.87 GHz
            ok, resp = sg.set_frequency(freq)
            print(f"    设置值: {freq/1e9:.6f} GHz")
            print(f"    响应: {resp}")
            
            # 设置功率
            print("\n[3] 设置功率...")
            power = -10.0  # -10 dBm
            ok, resp = sg.set_power(power)
            print(f"    设置值: {power:.2f} dBm")
            print(f"    响应: {resp}")
            
            # 查询状态
            print("\n[4] 查询状态...")
            status = sg.get_status()
            for key, value in status.items():
                print(f"    {key}: {value}")
            
            # 开启输出
            print("\n[5] 开启输出...")
            sg.output_on()
            
            print("\n" + "=" * 60)
            print("SG386配置完成")
            print("=" * 60)
            
    except serial.SerialException as e:
        print(f"\n错误: 串口连接失败 - {e}")
    except ValueError as e:
        print(f"\n错误: 参数超出范围 - {e}")
    except KeyboardInterrupt:
        print("\n\n用户中断")
