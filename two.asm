%define psp 0                           ; psp is at address 0

; static uint8_t key_len;
%define key_len (psp+80h)               ; 80h: command line length

; static uint8_t *key;
%define key (psp+81h+1)                 ; 81h: command line string, with a leading space

; static uint8_t state[256];

%define state 200h                      ; must end in 00 due to bl abuse

; static uint8_t i;
%define i cl

; static uint8_t j;
%define j ch


; void arcfour_key_setup(void) {
;     i = 0;
;mov bx, state                           ; start at the bottom of the state
mov bx, state

;     for (;;) {
key_setup_first:

;         state[i] = i;
mov [bx], bl                            ; fill this bit of state with the counter

;         ++i;
inc bl
;         if (0 == i) { // overflow
;             break;
jnz key_setup_first

;         }
;     }


;     j = 0;
;     i = 0;
; mov i, 0
; mov j, 0
xor cx,cx

;     for (;;) {
key_setup_second:

;         uint8_t key_index = i % key_len;
;         uint8_t key_part = key[key_index];
mov bh, 0
mov bl, i
and bl, 31
;add bl, key
add j, [bx+key]

;         uint8_t state_part = state[i];
mov bh, 2
mov bl, i
add j, [bx]

;         j += state_part + key_part;



call swap

;         ++i;
inc i

;         if (i == 0) { // overflow
;             break;
jnz key_setup_second
;         }
;     }
;     i = 0;
;     j = 0;
; mov i, 0
; mov j, 0
xor cx, cx

; }

; uint8_t next(void) {

; bh -> state masked
; bl destroyed
; dl destroyed
%macro next 0

%endmacro

; }


; void arcfour_generate_stream(void) {
;     for (;;) {
generate:
;         int got = getchar();
mov ah, 08h ; character input without echo
int 21h

;         if (EOF == got) {
;             return;
;         }

; ???

; next
    ;     ++i;
    inc i

    ;     j += state[i];
    mov bh, 2 ; state
    mov bl, i
    add j, [bx]

    call swap

    ;     uint8_t next_index = state[i] + state[j];
    mov bl, i
    mov dl, [bx]
    mov bl, j
    add dl, [bx]

    ;     return state[next_index];

    mov bl, dl
    mov dl, [bx]

; end next

;         putchar(got ^ next());
xor dl, al
mov ah, 02h
int 21h

; .. decide whether to loop down here instead;
; so we always prompt for at least one character (?)
mov ah, 0bh ; check stdin status
int 21h
test al,al ; check if it's zero: 0 = no character available -> eof
jne generate

; exit
int 20h
;     }
; }

swap:
    ; dl = state[i]
    ; dh = state[j]
    ; state[j] = dl
    ; state[i] = dh

    mov bh, 2 ; state
    mov bl, i

    mov dl, [bx]

    mov bl, j
    mov dh, [bx]

    mov [bx], dl

    mov bl, i
    mov [bx], dh

    ret

