## 测试步骤说明

### 1 处理指令文件并创建isa目录

```python
python test_src_init.py
```

该步骤是将指令文件从混合的程序文件、汇编文件中分离出来

并修改二进制文件按每行32位格式表示，便于读入指令存储器

### 2 按照说明配置top_tb.v文件

1、修改测试对象为：内核测试/JTAG测试/Progbuf测试

2、修改测试程序（riscv-test标准指令集测试）

3、修改仿真周期数

4、修改打印信息

### 3 执行编译与仿真

1、清除工作区

```shell
make clean
```

2、vcs仿真文件生成

```shell
make run_vcs
```

3、执行vvp仿真

```shell
make run_vvp
```