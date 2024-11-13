# rv32 isa 指令测试设计文档

## const

### rv32_lui.txt

1<<12=4096

lui x3 1;

### rv32_auipc.txt

1<<12 + 4=4100

addi x1 x0 1;（没用）

auipc x3 4096;

## jump

### rv32_jal.txt

 rd=8 jump=44（2C） flush信号

addi x1 x0 1;（没用）

jal x3 20;

### rv32_jalr.txt

 rd=8 jump=20（14） flush信号

addi x1 x0 1;（最低位的1被消掉了）

jal x3 x1 20;

## br

### rv32_beq.txt

成立 jump=48（30） flush信号

addi x1 x0 3;

addi x2 x0 3;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 3;

beq x1 x2 20;

### rv32_bne.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 3;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 3;

addi x2 x0 3;

beq x1 x2 20;

## rv32_blt.txt

成立 jump=48（30） flush信号

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

### rv32_bge.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

### rv32_bltu.txt

成立 jump=48（30） flush信号

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

### rv32_bgeu.txt

成立 jump=48（30） flush信号

addi x1 x0 全1;

addi x2 x0 1;

beq x1 x2 20;

不成立  pc=14

addi x1 x0 1;

addi x2 x0 全1;

beq x1 x2 20;

## load

### rv32_lb.txt

mem(4)=全1[7:0]   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lb x3 x1 3

### rv32_lh.txt

mem(4)=全1[15:0]   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lh x3 x1 3

### rv32_lw.txt

mem(4)=全1   x3=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lw x3 x1 3

### rv32_lbu.txt

mem(4)=全1[7:0]   x3=全1[7:0]

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lbu x3 x1 3

### rv32_lhu.txt

mem(4)=全1[7:0]   x3=全1[15:0]

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

lhu x3 x1 3

## store

### rv32_sb.txt

mem(4)=全1[7:0]

addi x1 x0 1;

addi x2 x0 全1;

sb x2 3(x1);

### rv32_sh.txt

mem(4)=全1[15:0]

addi x1 x0 1;

addi x2 x0 全1;

sh x2 3(x1);

### rv32_sw.txt

mem(4)=全1

addi x1 x0 1;

addi x2 x0 全1;

sw x2 3(x1);

## op_i

### rv32_addi.txt

1+3=4

addi x1 x0 1;

addi x3 x1 3;

### rv32_slti.txt

全1<1=1

addi x1 x0 全1;

slti x3 x1 1;

### rv32_sltiu.txt

全1<1=0

addi x1 x0 全1;

sltiu x3 x1 1;

### rv32_xori.txt

b11^b01=b10

addi x1 x0 b11;

xori   x3 x1 b01;

### rv32_ori.txt

b11^b01=b11

addi x1 x0 b11;

ori   x3 x1 b01;

### rv32_andi.txt

b11^b01=b01

addi x1 x0 b11;

andi x3 x1 b01;

### rv32_slli.txt

1<<2=4

addi x1 x0 1;

slli x3 x1 2;

### rv32_srli.txt

全1>>1=01111……

addi x1 x0 全1;

srli x2 x1 1;

### rv32_srai.txt

全1>>1=全1

addi x1 x0 全1;

srai   x3 x1 1;

## op

### rv32_add.txt

1+3=4

addi x1 x0 1;

addi x2 x0 3;

add  x3 x1 x2;

### rv32_sub.txt

4-1=3

addi x1 x0 4;

addi x2 x0 1;

sub  x3 x1 x2;

### rv32_sll.txt

1<<2=4

addi x1 x0 1;

addi x2 x0 2;

sll     x3 x1 x2;

### rv32_slt.txt

全1<1=1

addi x1 x0 全1;

addi x2 x0 1;

slt    x3 x1 x2;

### rv32_sltu.txt

全1<1=0

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### rv32_xor.txt

b11^b01=b10

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

### rv32_srl.txt

全1>>1=01111……

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### rv32_sra.txt

全1>>1=全1

addi x1 x0 全1;

addi x2 x0 1;

sltu   x3 x1 x2;

### rv32_or.txt

b11^b01=b11

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

### rv32_and.txt

b11^b01=b01

addi x1 x0 b11;

addi x2 x0 b01;

sltu   x3 x1 x2;

## fence

### rv32_fence.txt

### rv32_fence_i.txt

## system

### rv32_ecall.txt

检查stall情况、csr更新情况、CSR_ADDR_MEPC = 14、CSR_MCAUSE=11

x6-x9永远不会被执行

csrrwi x1 4 12'h305; （001100000101）

addi x2 x0 2;

addi x3 x0 3;

addi x4 x0 4;

addi x5 x0 5;

ecall

addi x6 x0 6;

addi x7 x0 7;

addi x8 x0 8;

addi x9 x0 9;

### rv32_ebreak.txt

和ecall测试一致，检查stall情况、csr更新情况、CSR_ADDR_MEPC = 14、CSR_MCAUSE=3

x6-x9永远不会被执行

csrrwi x1 4 12'h305; （001100000101）

addi x2 x0 2;

addi x3 x0 3;

addi x4 x0 4;

addi x5 x0 5;

ecall

addi x6 x0 6;

addi x7 x0 7;

addi x8 x0 8;

addi x9 x0 9;

### rv32_mret.txt

检查stall情况、csr更新情况、CSR_ADDR_MEPC = 14、CSR_MCAUSE=11

永远不会执行x7

00 csrrwi x1 28 12'h305; （001100000101）1C

04 addi x2 x0 2;

08 addi x3 x0 3;

0C addi x4 x0 4;

10 addi x5 x0 5;

14 ecall

18 addi x6 x0 6;

1C addi x7 x0 7;

20 addi x8 x0 8;

24 addi x9 x0 9;

28 mret 回到ecall指令

## csr

### rv32_csrrw.txt

x1=4 x3=xxx CSR_MTVEC=b0100（4）

addi x1 x0 4

csrrw x3 x1 12'h305; （001100000101）

### rv32_csrrs.txt

x1=8 x3=4 CSR_MTVEC=b1100（12）

addi x1 x0 8

csrrwi x3 0100 12'h305; （001100000101）

csrrs  x3 x1 12'h305; （001100000101）

### rv32_csrrc.txt

x1=8 x3=12 CSR_MTVEC=b0100（4）

addi x1 x0 8

csrrwi x3 1100 12'h305; （001100000101）

csrrci  x3 x1 12'h305; （001100000101）

### rv32_csrrwi.txt

x3=xxx CSR_MTVEC=b0100（4）

csrrwi x3 4 12'h305; （001100000101）

### rv32_csrrsi.txt

x3=4 CSR_MTVEC=b1100（12）

csrrwi x3 0100 12'h305; （001100000101）

csrrsi  x3 1000 12'h305; （001100000101）

### rv32_csrrci.txt

x3=12 CSR_MTVEC=b0100（4）

csrrwi x3 1100 12'h305; （001100000101）

csrrci  x3 1000 12'h305; （001100000101）

## mul

### rv32_mul.txt

32'b1x32'b1-->-1x-1=1(00……01) 输出1

addi x1 x0 11111;

addi x2 x1 11111;

mul x3 x1 x2

### rv32_mulh.txt

32'b1x32'b1-->-1x-1=1(00……01) 输出0

addi x1 x0 11111;

addi x2 x1 11111;

mulh x3 x1 x2

### rv32_mulhsu.txt

32'b1x32'b1-->-1x(2^32-1)=(11111_00001) 输出11111_

addi x1 x0 11111;

addi x2 x1 11111;

mulhsu x3 x1 x2

### rv32_mulhu.txt

32'b1x32'b1-->(2^32^-1)x(2^32^-1)=(11110_11111) 输出11110_

addi x1 x0 11111;

addi x2 x1 11111;

mulhu x3 x1 x2
