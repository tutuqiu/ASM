;print2.asm

.model small
.stack 100h

.data
perline EQU 13
lines EQU 2

.code
start:
        mov ax,@data
        mov ds,ax

        mov dl,'a'
        mov bx,lines
outer:
        mov cx,perline
inner:
        mov ah,2
        int 21h
        inc dl
        dec cx
        jnz inner

        push dx

        mov ah,2
        mov dl,13
        int 21h
        mov dl,10
        int 21h

        pop dx

        dec bx
        jnz outer

        mov ax,4C00h
        int 21h
END start
