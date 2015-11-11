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
mov bx, state                           ; start at the bottom of the state

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
mov i, 0
mov j, 0

;     for (;;) {
key_setup_second:

;         uint8_t key_index = i % key_len;
mov ah, 0
mov al, i                               ; dividee
mov bx, [key_len]
dec bx                                  ; key_len includes the leading space
div bl

%define key_index ah

;         uint8_t key_part = key[key_index];
mov bx, 0
mov bl, ah
add bx, key
mov al, [bx]

%define key_part al

;         uint8_t state_part = state[i];
mov bx, state
add bl, i

mov ah, [bx]

;         j += state_part + key_part;
add al, ah
add j, al


%macro swap 0
    ; dl = state[i]
    ; dh = state[j]
    ; state[j] = dl
    ; state[i] = dh

    mov bx, state

    mov bl, i
    mov dl, [bx]

    mov bl, j
    mov dh, [bx]

    mov [bx], dl

    mov bl, i
    mov [bx], dh

%endmacro

swap

;         ++i;
inc i

;         if (i == 0) { // overflow
;             break;
jnz key_setup_second
;         }
;     }
;     i = 0;
;     j = 0;
mov i, 0
mov j, 0

; }

; uint8_t next(void) {

; bh -> state masked
; bl destroyed
; dl destroyed
%macro next 0

    ;     ++i;
    inc i

    ;     j += state[i];
    mov bx, state
    mov bl, i
    add j, [bx]

    swap

    ;     uint8_t next_index = state[i] + state[j];
    mov bl, i
    mov dl, [bx]
    mov bl, j
    add dl, [bx]

    ;     return state[next_index];

    mov bl, dl
    mov dl, [bx]

%endmacro

; }

; void drop(void) {
;     for (int k = 0; k < 1024; ++k) {
;         next();
;     }
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

next

xor dl, al
mov ah, 02h
int 21h

jmp generate
;         putchar(got ^ next());
;     }
; }

; int main(int argc, char **argv) {
;     if (2 != argc) {
;         fprintf(stderr, "usage: %s 'key'", argv[0]);
;         return 1;
;     }
;     key = argv[1];
;     key_len = strlen(key);

;     arcfour_key_setup();
;     arcfour_generate_stream();
; }

