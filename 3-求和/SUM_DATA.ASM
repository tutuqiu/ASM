.MODEL small
.STACK 100h

.DATA
CR   EQU 13
LF   EQU 10
sum  DW 0

.CODE
print_u16 PROC NEAR
    push ax
    push bx
    push cx
    push dx
    mov  bx, 10
    xor  cx, cx
    cmp  ax, 0
    jne  pu16_d1
    mov  dl, '0'
    mov  ah, 2
    int  21h
    jmp  pu16_done
pu16_d1:
    xor  dx, dx
    div  bx
    push dx
    inc  cx
    cmp  ax, 0
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

start:
    mov  ax, @data
    mov  ds, ax

    mov  sum, 0
    mov  cx, 100
    mov  bx, 1
sloop:
    add  sum, bx
    inc  bx
    loop sloop         ; sum=5050

    mov  ax, sum
    call print_u16
    mov  ah, 2
    mov  dl, CR
    int  21h
    mov  dl, LF
    int  21h

    mov  ax, 4C00h
    int  21h
END start
