; sum_input.asm — 输入 1..100，输出 1..n 的和（公式 n*(n+1)/2）
.MODEL small
.STACK 100h

.DATA
CR    EQU 13
LF    EQU 10

msg   DB 'Input (1-100): $'
res   DB CR,LF,'Output: $'
nval  DW 0

.CODE

; ------------------ 十进制打印（AX 无符号） ------------------
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
    xor  dx, dx          ; 每轮 div 前清 DX，保证 (0:AX)/10
    div  bx              ; AX=商, DX=余
    push dx              ; 余数入栈
    inc  cx
    test ax, ax
    jne  pu16_d1         ; 商不为 0 继续除

pu16_out:
    pop  dx              ; 逆序弹出余数
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


; ------------------ 读取十进制到 nval ------------------
; 从键盘读入一行十进制数字（以回车结束），
; 忽略非 '0'..'9' 的字符，把结果存到 nval（0..65535）
read_dec PROC NEAR
    push ax
    push bx
    push cx
    push dx

    xor  cx, cx          ; CX = 累计值 value = 0
    mov  bx, 10          ; BX = 10

rd_next:
    mov  ah, 1
    int  21h             ; AL = 键（带回显）

    cmp  al, CR          ; 回车结束输入
    je   rd_done

    cmp  al, '0'
    jb   rd_next         ; 小于 '0'，忽略
    cmp  al, '9'
    ja   rd_next         ; 大于 '9'，忽略

    sub  al, '0'         ; AL = digit (0..9)
    mov  ah, 0           ; AX = digit
    push ax              ; 暂存 digit

    mov  ax, cx          ; AX = value
    mul  bx              ; DX:AX = value * 10
    pop  dx              ; DX = digit
    add  ax, dx          ; AX = value*10 + digit

    mov  cx, ax          ; 更新 value
    jmp  rd_next

rd_done:
    mov  ax, cx
    mov  nval, ax

    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
read_dec ENDP


; ------------------ 主程序 ------------------
start:
    mov  ax, @data
    mov  ds, ax

    ; 提示并读入 n
    mov  ah, 9
    mov  dx, OFFSET msg
    int  21h
    call read_dec

    ; 打印 "Output: "
    mov  ah, 9
    mov  dx, OFFSET res
    int  21h

    ; 计算 sum = n*(n+1)/2
    mov  ax, nval        ; AX = n
    mov  bx, ax
    inc  bx              ; BX = n+1
    mul  bx              ; DX:AX = n*(n+1)  （n<=100 → DX=0）
    shr  ax, 1           ; 除以 2，AX = sum

    ; 输出结果 + 换行
    call print_u16
    mov  ah, 2
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    mov  ax, 4C00h
    int  21h
END start
