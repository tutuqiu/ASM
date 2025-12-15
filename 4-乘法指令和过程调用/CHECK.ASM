.MODEL small
.STACK 100h

.DATA
CR  EQU 13
LF  EQU 10

table  db 7,2,3,4,5,6,7,8,9             ; 第 1 行（1×1 开头，这里故意错成 7）
       db 2,4,7,8,10,12,14,16,18        ; 第 2 行（2×3 处错成 7）
       db 3,6,9,12,15,18,21,24,27
       db 4,8,12,16,7,24,28,32,36       ; 第 4 行（4×5 处错成 7）
       db 5,10,15,20,25,30,35,40,45
       db 6,12,18,24,30,7,42,48,54      ; 第 6 行（6×6 处错成 7）
       db 7,14,21,28,35,42,49,56,63
       db 8,16,24,32,40,48,56,7,72      ; 第 8 行（8×8 处错成 7）
       db 9,18,27,36,45,54,63,72,81

msgTitle db 'x y',CR,LF,'$'
msgErr   db ' error',CR,LF,'$'
msgOK    db 'accomplish!',CR,LF,'$'

.CODE
start:
    mov ax, @data
    mov ds, ax

    ; 打印标题
    mov dx, OFFSET msgTitle
    mov ah, 9
    int 21h

    mov si, OFFSET table      ; SI 指向表数据首地址
    mov bl, 1                 ; BL = 行号 1..9

row_loop:
    mov bh, 1                 ; BH = 列号 1..9

col_loop:
    ; 计算应有结果：AL = BL * BH (1..81)
    mov al, bl
    mul bh                    ; 8 位无符号乘法：AL * BH -> AX，结果在 AL

    mov dl, [si]              ; DL = 表中当前元素
    cmp al, dl
    jne wrong                 ; 不相等说明有错误

next_pos:
    inc si                    ; 指向下一个元素
    inc bh                    ; 列号 +1
    cmp bh, 9
    jbe col_loop              ; 列 1..9

    inc bl                    ; 下一行
    cmp bl, 9
    jbe row_loop              ; 行 1..9

    ; 全部检查结束，输出完成提示
    mov dx, OFFSET msgOK
    mov ah, 9
    int 21h

    mov ax, 4C00h
    int 21h

;--------------------------------------------------
; 过程：ShowError
; 功能：按“行 列 error”格式输出一行错误位置
; 入口：BL = 行号(1..9)，BH = 列号(1..9)
; 使用：AX, DX（内部自己保存和恢复）
;--------------------------------------------------
ShowError PROC NEAR
    push ax
    push dx

    ; 打印行号
    mov dl, bl
    add dl, '0'
    mov ah, 2
    int 21h

    ; 打印空格
    mov dl, ' '
    mov ah, 2
    int 21h

    ; 打印列号
    mov dl, bh
    add dl, '0'
    mov ah, 2
    int 21h

    ; 打印“ error”并换行
    mov dx, OFFSET msgErr
    mov ah, 9
    int 21h

    pop dx
    pop ax
    ret
ShowError ENDP

wrong:
    ; 发现错误：调用过程打印一行
    call ShowError
    jmp  next_pos            ; 继续检查下一个元素

END start