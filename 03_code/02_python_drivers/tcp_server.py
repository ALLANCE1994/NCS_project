#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ODMR TCP服务器
负责智能体：【@S 软件工程师】
功能：接收计算机命令，控制PL端扫描，返回ODMR数据
运行环境：PYNQ Linux (ZYNQ7020)

【知识来源】：NV项目PL端设计文档 + PYNQ框架手册 + TCP协议设计规范
"""

import socket
import json
import threading
import queue
import time
import logging
from datetime import datetime
from typing import Dict, Any, Optional

try:
    from pynq import Overlay, MMIO
    PYNQ_AVAILABLE = True
except ImportError:
    PYNQ_AVAILABLE = False
    print("【@S 软件工程师】警告：PYNQ环境不可用，使用模拟模式")

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('ODMR_Server')


class AXIController:
    """【@S 软件工程师】AXI-Lite接口控制器"""
    
    REG_FREQ_START = 0x00
    REG_FREQ_STOP = 0x04
    REG_FREQ_STEP = 0x08
    REG_INTEG_TIME = 0x0C
    REG_WAIT_TIME = 0x10
    REG_CONTROL = 0x14
    REG_STATUS = 0x18
    REG_CURR_FREQ = 0x1C
    REG_POINT_CNT = 0x20
    REG_DATA_FIFO = 0x24  # 数据FIFO读取寄存器
    REG_FIFO_CNT = 0x28   # FIFO数据计数
    
    def __init__(self, overlay_path: str = 'odmr.bit'):
        self.overlay = None
        self.mmio = None
        if PYNQ_AVAILABLE:
            try:
                logger.info(f"【@S 软件工程师】加载FPGA比特流: {overlay_path}")
                self.overlay = Overlay(overlay_path)
                self.overlay.download()
                self.mmio = MMIO(0x43C00000, 0x1000)
                logger.info("【@S 软件工程师】AXI接口初始化成功")
            except Exception as e:
                logger.error(f"【@S 软件工程师】AXI初始化失败: {e}")
                self.mmio = None
        else:
            logger.warning("【@S 软件工程师】模拟模式：AXI操作将被忽略")
            self.mmio = None
    
    def write_reg(self, offset: int, value: int) -> bool:
        if self.mmio:
            self.mmio.write(offset, value)
            return True
        else:
            logger.debug(f"【@S 软件工程师】模拟写入: offset=0x{offset:02X}, value={value}")
            return True
    
    def read_reg(self, offset: int) -> int:
        if self.mmio:
            return self.mmio.read(offset)
        else:
            logger.debug(f"【@S 软件工程师】模拟读取: offset=0x{offset:02X}")
            return 0
    
    def set_scan_params(self, freq_start: int, freq_stop: int, freq_step: int, integ_time: int, wait_time: int) -> bool:
        try:
            self.write_reg(self.REG_FREQ_START, freq_start)
            self.write_reg(self.REG_FREQ_STOP, freq_stop)
            self.write_reg(self.REG_FREQ_STEP, freq_step)
            self.write_reg(self.REG_INTEG_TIME, integ_time)
            self.write_reg(self.REG_WAIT_TIME, wait_time)
            logger.info(f"【@S 软件工程师】扫描参数设置成功: {freq_start/1e9:.3f}GHz ~ {freq_stop/1e9:.3f}GHz")
            return True
        except Exception as e:
            logger.error(f"【@S 软件工程师】设置扫描参数失败: {e}")
            return False
    
    def start_scan(self) -> bool:
        try:
            self.write_reg(self.REG_CONTROL, 0x1)
            logger.info("【@S 软件工程师】扫描启动")
            return True
        except Exception as e:
            logger.error(f"【@S 软件工程师】启动扫描失败: {e}")
            return False
    
    def stop_scan(self) -> bool:
        try:
            self.write_reg(self.REG_CONTROL, 0x2)
            logger.info("【@S 软件工程师】扫描停止")
            return True
        except Exception as e:
            logger.error(f"【@S 软件工程师】停止扫描失败: {e}")
            return False
    
    def get_status(self) -> Dict[str, Any]:
        """【@S 软件工程师】获取扫描状态"""
        try:
            status = self.read_reg(self.REG_STATUS)
            curr_freq = self.read_reg(self.REG_CURR_FREQ)
            point_cnt = self.read_reg(self.REG_POINT_CNT)
            fifo_cnt = self.read_reg(self.REG_FIFO_CNT)
            return {
                'scan_busy': bool(status & 0x1),
                'scan_done': bool(status & 0x2),
                'current_freq': curr_freq,
                'point_cnt': point_cnt,
                'fifo_count': fifo_cnt
            }
        except Exception as e:
            logger.error(f"【@S 软件工程师】获取状态失败: {e}")
            return {'scan_busy': False, 'scan_done': False, 'current_freq': 0, 'point_cnt': 0, 'fifo_count': 0}
    
    def read_data_point(self) -> Optional[Dict[str, Any]]:
        """【@S 软件工程师】读取单个数据点（频率+光强）"""
        try:
            # 从FIFO读取数据：高16位频率，低16位光强计数
            data = self.read_reg(self.REG_DATA_FIFO)
            freq = (data >> 16) & 0xFFFF
            intensity = data & 0xFFFF
            return {'frequency': freq, 'intensity': intensity}
        except Exception as e:
            logger.error(f"【@S 软件工程师】读取数据点失败: {e}")
            return None
    
    def read_all_data(self, max_points: int = 1024) -> list:
        """【@S 软件工程师】读取所有可用数据"""
        data_points = []
        try:
            fifo_cnt = self.read_reg(self.REG_FIFO_CNT)
            read_cnt = min(fifo_cnt, max_points)
            for _ in range(read_cnt):
                point = self.read_data_point()
                if point:
                    data_points.append(point)
            logger.debug(f"【@S 软件工程师】读取 {len(data_points)} 个数据点")
        except Exception as e:
            logger.error(f"【@S 软件工程师】批量读取数据失败: {e}")
        return data_points


class ODMRServer:
    """【@S 软件工程师】ODMR TCP服务器"""
    
    def __init__(self, host: str = '192.168.1.10', port: int = 5000):
        self.host = host
        self.port = port
        self.server_socket = None
        self.client_socket = None
        self.data_queue = queue.Queue()
        self.running = False
        self.axi = AXIController()
        self.data_thread = None          # 数据推送线程
        self.streaming = False           # 实时流状态
        self.scan_data_buffer = []       # 扫描数据缓冲区
        
    def start(self):
        """【@S 软件工程师】启动TCP服务器"""
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(1)
        logger.info(f"【@S 软件工程师】服务器监听 {self.host}:{self.port}")
        
        self.running = True
        while self.running:
            try:
                self.client_socket, addr = self.server_socket.accept()
                logger.info(f"【@S 软件工程师】客户端连接: {addr}")
                self.handle_client()
            except Exception as e:
                logger.error(f"【@S 软件工程师】接受连接错误: {e}")
                
    def handle_client(self):
        """【@S 软件工程师】处理客户端连接"""
        while self.running:
            try:
                data = self.client_socket.recv(1024)
                if not data:
                    break
                cmd = json.loads(data.decode())
                response = self.process_command(cmd)
                self.client_socket.send(json.dumps(response).encode())
            except json.JSONDecodeError as e:
                logger.error(f"【@S 软件工程师】JSON解析错误: {e}")
                self.client_socket.send(json.dumps({'status': 'ERROR', 'message': 'Invalid JSON'}).encode())
            except Exception as e:
                logger.error(f"【@S 软件工程师】处理客户端错误: {e}")
                break
        self.client_socket.close()
        logger.info("【@S 软件工程师】客户端断开连接")
        
    def start_data_stream(self):
        """【@S 软件工程师】启动数据流推送线程"""
        if not self.streaming:
            self.streaming = True
            self.data_thread = threading.Thread(target=self._data_stream_loop)
            self.data_thread.daemon = True
            self.data_thread.start()
            logger.info("【@S 软件工程师】数据流推送启动")
    
    def stop_data_stream(self):
        """【@S 软件工程师】停止数据流推送"""
        self.streaming = False
        if self.data_thread:
            self.data_thread.join(timeout=1.0)
            logger.info("【@S 软件工程师】数据流推送停止")
    
    def _data_stream_loop(self):
        """【@S 软件工程师】数据流推送循环"""
        while self.streaming and self.running:
            try:
                # 读取PL端数据
                status = self.axi.get_status()
                if status['fifo_count'] > 0:
                    data_points = self.axi.read_all_data(max_points=32)
                    if data_points:
                        self.scan_data_buffer.extend(data_points)
                        # 实时推送给客户端
                        if self.client_socket:
                            stream_msg = {
                                'type': 'DATA_STREAM',
                                'points': data_points,
                                'buffer_size': len(self.scan_data_buffer)
                            }
                            try:
                                self.client_socket.send(json.dumps(stream_msg).encode())
                            except Exception as e:
                                logger.warning(f"【@S 软件工程师】数据推送失败: {e}")
                                break
                time.sleep(0.01)  # 10ms轮询
            except Exception as e:
                logger.error(f"【@S 软件工程师】数据流循环错误: {e}")
                break
    
    def process_command(self, cmd: Dict[str, Any]) -> Dict[str, Any]:
        """【@S 软件工程师】处理命令"""
        cmd_type = cmd.get('cmd', '')
        
        if cmd_type == 'SET_SCAN':
            params = cmd.get('params', {})
            success = self.axi.set_scan_params(
                params.get('freq_start', 2820000000),
                params.get('freq_stop', 2920000000),
                params.get('freq_step', 500000),
                params.get('integ_time', 10000),
                params.get('wait_time', 125000)
            )
            return {'status': 'OK' if success else 'ERROR', 'cmd': 'SET_SCAN'}
            
        elif cmd_type == 'START_SCAN':
            self.scan_data_buffer = []  # 清空缓冲区
            success = self.axi.start_scan()
            if success:
                self.start_data_stream()  # 启动数据流
            return {'status': 'OK' if success else 'ERROR', 'cmd': 'START_SCAN'}
            
        elif cmd_type == 'STOP_SCAN':
            self.stop_data_stream()  # 停止数据流
            success = self.axi.stop_scan()
            return {'status': 'OK' if success else 'ERROR', 'cmd': 'STOP_SCAN'}
            
        elif cmd_type == 'GET_STATUS':
            status = self.axi.get_status()
            return {'status': 'OK', 'type': 'status', **status}
            
        elif cmd_type == 'GET_DATA':
            """【@S 软件工程师】获取当前缓冲区数据"""
            count = cmd.get('count', len(self.scan_data_buffer))
            data = self.scan_data_buffer[:count]
            return {
                'status': 'OK',
                'type': 'data',
                'count': len(data),
                'points': data
            }
            
        elif cmd_type == 'GET_FULL_DATA':
            """【@S 软件工程师】获取完整扫描数据"""
            return {
                'status': 'OK',
                'type': 'full_data',
                'count': len(self.scan_data_buffer),
                'points': self.scan_data_buffer.copy()
            }
            
        elif cmd_type == 'SUBSCRIBE_DATA':
            """【@S 软件工程师】订阅实时数据流"""
            enable = cmd.get('enable', True)
            if enable and not self.streaming:
                self.start_data_stream()
            elif not enable and self.streaming:
                self.stop_data_stream()
            return {
                'status': 'OK',
                'cmd': 'SUBSCRIBE_DATA',
                'streaming': self.streaming
            }
            
        else:
            return {'status': 'ERROR', 'message': f'Unknown command: {cmd_type}'}


if __name__ == '__main__':
    server = ODMRServer()
    try:
        server.start()
    except KeyboardInterrupt:
        logger.info("【@S 软件工程师】服务器停止")
        server.running = False
