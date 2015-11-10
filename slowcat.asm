org 100h
start:
mov ah, 08h ; character input without echo
int 21h     ; exec
mov dl, al  ; al: read character, dl: 02h's input
inc dl      ; messin'
mov ah, 02h ; write character to stdout
int 21h     ; exec
jmp start
int 20h     ; exit

