#include <dos.h>

/* 全局变量：用于记录参数与结果（不在 C 表达式里做可能溢出的运算） */
volatile signed char g_a = 0;
volatile signed char g_b = 0;
volatile signed char g_r = 0;
volatile unsigned int g_cnt = 0;

/* 保存原 INT 4 向量 */
void interrupt far (*old_int4)();

/* 重写 INT 4（INTO 触发的溢出中断） */
void interrupt far my_int4(void)
{
    static char msg1[] = "INT 4: Signed overflow detected!$";
    static char msg2[] = "\r\n$";

    g_cnt++;

    /* 保存现场 */
    asm push ax;
    asm push bx;
    asm push cx;
    asm push dx;
    asm push si;
    asm push di;
    asm push bp;
    asm push ds;
    asm push es;

    /* DOS 输出字符串：int 21h, ah=09h, ds:dx -> '$' 结尾 */
    asm mov ax, SEG msg1;
    asm mov ds, ax;
    asm mov dx, OFFSET msg1;
    asm mov ah, 9;
    asm int 21h;

    asm mov ax, SEG msg2;
    asm mov ds, ax;
    asm mov dx, OFFSET msg2;
    asm mov ah, 9;
    asm int 21h;

    /* 恢复现场 */
    asm pop es;
    asm pop ds;
    asm pop bp;
    asm pop di;
    asm pop si;
    asm pop dx;
    asm pop cx;
    asm pop bx;
    asm pop ax;

    /* interrupt 函数自动 IRET */
}

/* 用汇编 ADD 计算 + INTO 触发 INT 4（不使用 JO/JNO） */
void add8_with_into(signed char a, signed char b)
{
    g_a = a;
    g_b = b;

    asm mov al, a;
    asm add al, b;
    asm mov g_r, al;
    asm into;          /* OF=1 -> INT 4 */
}

int main(void)
{
    old_int4 = getvect(4);
    setvect(4, my_int4);

    add8_with_into(10, 20);    /* 不溢出 */
    add8_with_into(120, 10);   /* 溢出 */
    add8_with_into(127, 1);    /* 溢出 */

    setvect(4, old_int4);
    return 0;
}
