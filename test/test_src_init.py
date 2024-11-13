# -*- coding: utf-8 -*-

import os

# 进行数据分割，并把大端存储格式变为小端存储格式
def insn_format_trans(infile, outfile):
    with open(infile, 'r') as bytefile:
        with open(outfile, 'w') as bytefile_mod:
            for line in bytefile:
                # 去掉某行的@语句
                if line.startswith('@'):
                    continue
                # 去掉行末的换行符与行中的空格
                line = line.strip()
                line = line.replace(' ', '')  
                # 将行的字符按照每8个字符一组分割
                for i in range(0, len(line), 8):
                    chunk = line[i:i+8]
                    byte1 = chunk[0:2]  
                    byte2 = chunk[2:4]
                    byte3 = chunk[4:6]
                    byte4 = chunk[6:8]
                    chunk_mod = byte4 + byte3 + byte2 + byte1
                    bytefile_mod.write(chunk_mod + '\n')  # 写入输出文件

def test_src_init():
    
    src_dir  = './generated'
    endtoken = 'verilog'
    des_dir  = './isa'

    if not os.path.exists(des_dir):
        os.makedirs(des_dir)
        print('%s directory created' % des_dir)

    # 遍历 src_dir 并处理 .verilog 文件
    for file_name in os.listdir(src_dir):
        if file_name.endswith('.verilog'):
            file_path = os.path.join(src_dir, file_name)
            base_name = file_name[:-len('.verilog')]
            outfile_path = os.path.join(des_dir, '%s.txt' % base_name)
            insn_format_trans(file_path, outfile_path)
            print('transform %s to %s' % (file_path, outfile_path))

    # 获取转换后目录下所有文件名
    file_names = os.listdir(des_dir)
    file_names_output_file = 'file_names.txt'
    with open(file_names_output_file, 'w') as f:
        for file_name in file_names:
            f.write(file_name + '\n')

if __name__ == "__main__":
    test_src_init()
