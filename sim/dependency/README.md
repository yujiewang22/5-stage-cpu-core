# 处理器控制测试设计文档

## bypassing test

### R-R TYPE

#### m-x bypassing rs1

cycle 8 检测 1+3=4

addi x2 x0 3;

NOP

NOP

NOP

NOP

addi x1 x0 1;

add x3 x1x2;

#### m-x bypassing rs2

cycle 8 检测 1+3=4

addi x1 x0 1;

NOP

NOP

NOP

NOP

addi x2 x0 3;

add x3 x1x2;

#### w-x bypassing rs1

cycle 9 检测 1+3=4

addi x2 x0 3;

NOP

NOP

NOP

NOP

addi x1 x0 1;

NOP

add x3 x1x2;

#### w-x bypassing rs2

cycle 9 检测 1+3=4

addi x1 x0 1;

NOP

NOP

NOP

NOP

addi x2 x0 3;

NOP

add x3 x1x2;

#### w-d bypassing rs1

cycle 9 检测 1+3=4

addi x2 x0 3;

NOP

NOP

NOP

NOP

addi x1 x0 1;

NOP

NOP

add x3 x1x2;

#### w-d bypassing rs2

cycle 9 检测 1+3=4

addi x1 x0 1;

NOP

NOP

NOP

NOP

addi x2 x0 3;

NOP

NOP

add x3 x1x2;

## stall-flush test

#### branch指令（br、jal、jalr）

已在isa中测试

#### load-use-stall

实际上对于mem组合逻辑读出的情况不存在load-use-stall

且也无需对load-store情况额外判断

##### load-use情况

mem(1)=3 x4=3+3=6 会停顿一拍，接着WX-bypassing

00 addi x1 x0 1;（基地址）

04 addi x2 x0 3;（数据）

08 sw x2 3(x1);

0C lw x3 3(x1)

10 addi x4 x3 3

##### load-store情况

mem(1)=3 mem(2)=3  不会停顿一拍，接着WM-bypassing

00 addi x1 x0 1;

04 addi x2 x0 3;

08 sw x2 3(x1);

0C lw x3 3(x1)

10 sw x3 7(x1)

## 存储器RAW隐式相关性

普通流水顺序处理器，访存指令顺序完成，前面的修改在后续均可感知，因此不存在此相关性























