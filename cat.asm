c:
resw 1
mov dx,c
mov cx,1
r:
mov ah,63
mov bx,0
int 33
cmp ax,0
je e
mov ah,64
mov bx,1
int 33
jmp r
e:
int 32
