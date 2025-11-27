; MUL99.ASM  — 作业题目4：乘法指令和过程调用（输出 9×9 乘法表）

.MODEL small
.STACK 100h

.DATA
CR      EQU 13
LF      EQU 10

MsgTitle DB 'The 9mul9 table:',CR,LF,'$'

.CODE

;
print_u16 PROC NEAR
    push ax
    push bx
    push cx
    push dx

    mov  bx, 10
    xor  cx, cx
    cmp  ax, 0
    jne  pu16_div
    ; ax == 0，直接输出 '0'
    mov  dl, '0'
    mov  ah, 2
    int  21h
    jmp  pu16_done

pu16_div:
pu16_d1:
    xor  dx, dx          ; (DX:AX)/10
    div  bx              ; AX=商, DX=余数
    push dx              ; 余数入栈
    inc  cx
    test ax, ax
    jne  pu16_d1

pu16_out:
    pop  dx
    add  dl, '0'
    mov  ah, 2
    int  21h
    loop pu16_out

pu16_done:
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
print_u16 ENDP


;
print_digit PROC NEAR
    push ax
    push dx

    add  al, '0'
    mov  dl, al
    mov  ah, 2
    int  21h

    pop  dx
    pop  ax
    ret
print_digit ENDP

print_cell PROC NEAR
    push ax
    push bx
    push cx
    push dx

    ; 打印左操作数 BL
    mov  al, bl
    call print_digit

    ; 打印 'x'
    mov  dl, 'x'
    mov  ah, 2
    int  21h

    ; 打印右操作数 CL
    mov  al, cl
    call print_digit

    ; 打印 '='
    mov  dl, '='
    mov  ah, 2
    int  21h

    ; 计算 BL * CL, 结果 AX
    mov  al, bl
    mov  ah, 0
    mul  cl             ; AL*CL -> AX (无符号 8 位乘法)

    ; 打印积
    call print_u16

    ; 单元之间打印空格
    mov  dl, ' '
    mov  ah, 2
    int  21h

    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
print_cell ENDP


;
start:
    mov  ax, @data
    mov  ds, ax

    ; 标题行
    mov  ah, 9
    mov  dx, OFFSET MsgTitle
    int  21h

    ; 外循环：BL = 9..1 （行）
    mov  bl, 9

row_loop:
    mov  cl, 1          ; 内循环：CL = 1..9 （列）

col_loop:
    call print_cell     ; 调用过程，使用 CALL/RET
    inc  cl
    cmp  cl, bl
    jbe  col_loop

    ; 换行
    mov  ah, 2
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    dec  bl
    jnz  row_loop       ; BL = 9..1

    ; 退出 DOS
    mov  ax, 4C00h
    int  21h

END start
