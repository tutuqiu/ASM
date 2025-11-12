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

        mov cx,lines

outer_loop:
        push cx
        mov cx,perline
inner_loop:
        mov ah,2
        int 21h
        inc dl
        loop inner_loop

        mov bl,dl

        mov ah,2
        mov dl,13
        int 21h
        mov dl,10
        int 21h

        mov dl,bl

        pop cx
        loop outer_loop

        mov ax,4C00h
        int 21h
END start
                       
