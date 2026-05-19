#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
正弦表ROM生成器
负责智能体：【@S 软件工程师】
用途：为DDS模块生成VHDL正弦表初始化数据
"""

import numpy as np


def generate_sin_table(table_depth=1024, data_width=8):
    """
    生成1/4周期正弦表
    
    Args:
        table_depth: 正弦表深度（点数）
        data_width: 数据位宽
    
    Returns:
        sin_table: 正弦表数组
    """
    angles = np.linspace(0, np.pi/2, table_depth)
    sin_values = np.round(127 * np.sin(angles)) + 128
    sin_values = np.clip(sin_values, 0, 255).astype(int)
    return sin_values


def generate_vhdl_rom(sin_table, table_depth=1024, data_width=8):
    """生成VHDL ROM初始化代码"""
    lines = []
    lines.append("--" + "="*70)
    lines.append("-- 正弦表ROM初始化文件")
    lines.append("-- 生成工具：generate_sin_table.py")
    lines.append("-- 负责智能体：【@S 软件工程师】")
    lines.append("-- 生成时间：2026-05-19")
    lines.append("-- 参数：深度={}, 位宽={}".format(table_depth, data_width))
    lines.append("--" + "="*70)
    lines.append("")
    lines.append("library IEEE;")
    lines.append("use IEEE.STD_LOGIC_1164.ALL;")
    lines.append("")
    lines.append("package sin_table_pkg is")
    lines.append("    constant TABLE_DEPTH : integer := {};".format(table_depth))
    lines.append("    constant DATA_WIDTH  : integer := {};".format(data_width))
    lines.append("    ")
    lines.append("    type sin_table_type is array (0 to TABLE_DEPTH-1) of")
    lines.append("        std_logic_vector(DATA_WIDTH-1 downto 0);")
    lines.append("    ")
    lines.append("    constant SIN_TABLE : sin_table_type := (")
    
    values_per_line = 8
    for i in range(0, len(sin_table), values_per_line):
        line_values = sin_table[i:i+values_per_line]
        hex_values = [f'X"{v:02X}"' for v in line_values]
        line = "        " + ", ".join(hex_values)
        if i + values_per_line < len(sin_table):
            line += ","
        line += "  -- {:4d} ~ {:4d}".format(i, i+len(line_values)-1)
        lines.append(line)
    
    lines.append("    );")
    lines.append("end package sin_table_pkg;")
    return "\n".join(lines)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='生成DDS正弦表ROM')
    parser.add_argument('-d', '--depth', type=int, default=1024, help='正弦表深度')
    parser.add_argument('-w', '--width', type=int, default=8, help='数据位宽')
    parser.add_argument('-o', '--output', type=str, default='sin_table_pkg.vhd', help='输出文件')
    args = parser.parse_args()
    
    print(f"【@S 软件工程师】生成正弦表...")
    sin_table = generate_sin_table(args.depth, args.width)
    vhdl_code = generate_vhdl_rom(sin_table, args.depth, args.width)
    
    with open(args.output, 'w') as f:
        f.write(vhdl_code)
    print(f"【@S 软件工程师】已保存到: {args.output}")
    print(f"统计: 最小值={sin_table.min()}, 最大值={sin_table.max()}")
