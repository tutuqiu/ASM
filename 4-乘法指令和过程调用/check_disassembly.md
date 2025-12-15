
check.exe:     file format pei-x86-64


Disassembly of section .text:

0000000140001450 <main>:

int main(){
   140001450: 55                    push   %rbp
        # 保存上一层函数的 rbp，给当前函数建立新的栈帧做准备

   140001451: 57                    push   %rdi
   140001452: 56                    push   %rsi
        # 保护 caller 可能在用的寄存器 rdi、rsi（被当作被调函数需要保存的寄存器）

   140001453: 48 81 ec 70 01 00 00  sub    $0x170,%rsp
        # rsp 向下移动 0x170 字节，为 main 的局部变量分配栈空间
        # 这 0x170 里包括：table[9][9] + x + y 等局部变量

   14000145a: 48 8d ac 24 80 00 00  lea    0x80(%rsp),%rbp
   140001461: 00 
        # 把 rbp 设置成 rsp+0x80（这个是编译器自己的布局方式）
        # 之后所有局部变量都通过 rbp+偏移来访问

   140001462: e8 c9 01 00 00        call   140001630 <__main>
        # 调用 MinGW 自带的 __main 做运行时初始化（全局构造函数等）
        # 和你的代码逻辑关系不大，相当于 C 运行库自动插的一段

    int table[9][9] = {
   140001467: 48 8d 45 a0           lea    -0x60(%rbp),%rax
        # rax = &table[0][0]，table 放在栈上，起始地址在 rbp-0x60 处
        # 说明：table 是局部变量，确实存在于当前函数的栈帧里

   14000146b: 48 8d 15 8e 1b 00 00  lea    0x1b8e(%rip),%rdx        # 140003000 <__data_start__>
        # rdx = 常量区里初始数据的地址（.rdata 或 .data 段中保存了那 81 个数字）
        # 编译器把初始化用的数据放到数据段，这里准备从那儿复制到栈上的 table

   140001472: b9 28 00 00 00        mov    $0x28,%ecx
        # ecx = 0x28 = 40
        # 接下来准备用 rep movsq 拷贝 40 个 8 字节 = 320 字节

   140001477: 48 89 c7              mov    %rax,%rdi
   14000147a: 48 89 d6              mov    %rdx,%rsi
        # rdi = 目的地址（栈上的 table）
        # rsi = 源地址（数据段里的初始乘法表数据）

   14000147d: f3 48 a5              rep movsq (%rsi),(%rdi)
        # 循环拷贝 ecx 次（40 次）8 字节，从 [rsi] 到 [rdi]
        # 一共拷贝 40 * 8 = 320 字节

   140001480: 48 89 f2              mov    %rsi,%rdx
   140001483: 48 89 f8              mov    %rdi,%rax
   140001486: 8b 0a                 mov    (%rdx),%ecx
   140001488: 89 08                 mov    %ecx,(%rax)
        # 上面这 4 条指令再额外拷贝 4 字节（一个 int）
        # 因为 table[9][9] 有 81 个 int，共 81*4 = 324 字节。
        # 前面的 rep movsq 拷了 320 字节，还剩下 4 字节，这里单独处理掉。
        # 到此，相当于 C 里的「int table[9][9] = {...};」完成初始化。

    printf("x y\n");
   14000148a: 48 8d 05 6f 2b 00 00  lea    0x2b6f(%rip),%rax        # 140004000 <.rdata>
        # rax = 字符串常量 "x y\n" 的地址

   140001491: 48 89 c1              mov    %rax,%rcx
        # Windows x64 调用约定：第 1 个参数放在 rcx
        # 此处把 "x y\n" 的地址放入 rcx，传给 puts

   140001494: e8 97 13 00 00        call   140002830 <puts>
        # 调用 puts("x y\n");
        # 对应 C 代码里的 printf("x y\n");（编译器这里用 puts 优化）

    for(int x=0;x<9;x++)
   140001499: c7 85 ec 00 00 00 00  movl   $0x0,0xec(%rbp)
   1400014a0: 00 00 00 
        # [rbp+0xec] = 0
        # 在当前栈帧中 0xec 位置保存的是局部变量 x，给 x 赋初值 0

   1400014a3: e9 83 00 00 00        jmp    14000152b <main+0xdb>
        # 跳到外层 for 的循环条件检查处（相当于 C 里的“先初始化，再检查条件”）

        for(int y=0;y<9;y++)
   1400014a8: c7 85 e8 00 00 00 00  movl   $0x0,0xe8(%rbp)
   1400014af: 00 00 00 
        # [rbp+0xe8] = 0
        # 局部变量 y 存在 [rbp+0xe8]，给 y 赋初值 0

   1400014b2: eb 67                 jmp    14000151b <main+0xcb>
        # 跳到内层 for 的条件检查处

            if(table[x][y]!=(x+1)*(y+1))
   1400014b4: 8b 85 e8 00 00 00     mov    0xe8(%rbp),%eax
        # eax = y

   1400014ba: 48 63 c8              movslq %eax,%rcx
        # 把 32 位的 y 符号扩展成 64 位放到 rcx 中（用于后面的下标计算）

   1400014bd: 8b 85 ec 00 00 00     mov    0xec(%rbp),%eax
        # eax = x

   1400014c3: 48 63 d0              movslq %eax,%rdx
        # rdx = x（扩展为 64 位）

   1400014c6: 48 89 d0              mov    %rdx,%rax
   1400014c9: 48 c1 e0 03           shl    $0x3,%rax
        # rax = x << 3 = x * 8

   1400014cd: 48 01 d0              add    %rdx,%rax
        # rax = x*8 + x = x * 9
        # 到这里 rax = x * 9，这是把二维下标 (x,y) 转成一维：x*9 + y

   1400014d0: 48 01 c8              add    %rcx,%rax
        # rax = x*9 + y

   1400014d3: 8b 54 85 a0           mov    -0x60(%rbp,%rax,4),%edx
        # -0x60(%rbp) 是 table[0][0] 的地址
        # 每个 int 占 4 字节，所以用 rax*4 作为偏移
        # edx = table[x][y]
        # -------------------------- 到这句为止就是 “取出 table[x][y]”

   1400014d7: 8b 85 ec 00 00 00     mov    0xec(%rbp),%eax
        # eax = x

   1400014dd: 8d 48 01              lea    0x1(%rax),%ecx
        # ecx = x + 1

   1400014e0: 8b 85 e8 00 00 00     mov    0xe8(%rbp),%eax
        # eax = y

   1400014e6: 83 c0 01              add    $0x1,%eax
        # eax = y + 1

   1400014e9: 0f af c1              imul   %ecx,%eax
        # eax = (x+1) * (y+1)
        # -------------------------- 到这句为止就是 “算出 (x+1)*(y+1)”

   1400014ec: 39 c2                 cmp    %eax,%edx
        # 比较 table[x][y] (在 edx) 与 (x+1)*(y+1) (在 eax)
        # 如果相等，说明这一项正确；否则说明有错误

   1400014ee: 74 24                 je     140001514 <main+0xc4>
        # 如果相等（Zero Flag=1），跳到 0x140001514，直接进入“y++”那一段
        # 对应 C 里的：if (...) { 不打印错误; }

                printf("%d %d    error\n",x+1,y+1);
   1400014f0: 8b 85 e8 00 00 00     mov    0xe8(%rbp),%eax
   1400014f6: 8d 48 01              lea    0x1(%rax),%ecx
        # ecx = y + 1（printf 的第 3 个参数）

   1400014f9: 8b 85 ec 00 00 00     mov    0xec(%rbp),%eax
   1400014ff: 8d 50 01              lea    0x1(%rax),%edx
        # edx = x + 1（printf 的第 2 个参数）

   140001502: 48 8d 05 fb 2a 00 00  lea    0x2afb(%rip),%rax        # 140004004 <.rdata+0x4>
        # rax = 字符串 "%d %d    error\n" 的地址

   140001509: 41 89 c8              mov    %ecx,%r8d
        # r8d = y+1（第 3 个参数）

   14000150c: 48 89 c1              mov    %rax,%rcx
        # rcx = 格式串首地址（第 1 个参数）

   14000150f: e8 8c 11 00 00        call   1400026a0 <printf>
        # 调用 printf("%d %d    error\n", x+1, y+1);
        # 对应 if 条件不满足时的分支

        for(int y=0;y<9;y++)
   140001514: 83 85 e8 00 00 00 01  addl   $0x1,0xe8(%rbp)
        # y = y + 1

   14000151b: 83 bd e8 00 00 00 08  cmpl   $0x
