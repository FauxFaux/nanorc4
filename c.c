#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

void arcfour_key_setup(uint8_t state[], const uint8_t key[], int len) {
    for (int i = 0; i < 256; ++i) {
        state[i] = i;
    }

    uint8_t j = 0;
    uint8_t t;
    for (int i = 0; i < 256; ++i) {
        j = (j + state[i] + key[i % len]) % 256;
        t = state[i];
        state[i] = state[j];
        state[j] = t;
    }
}

void arcfour_generate_stream(uint8_t state[]) {
    uint8_t i = 0, j = 0;
    uint8_t t;

    for (;;) {
        i = (i + 1) % 256;
        j = (j + state[i]) % 256;
        t = state[i];
        state[i] = state[j];
        state[j] = t;
        int got = getchar();
        if (EOF == got) {
            return;
        }
        putchar(got ^ state[(state[i] + state[j]) % 256]);
    }
}

int main(int argc, char **argv) {
    if (2 != argc) {
        fprintf(stderr, "usage: %s 'key'", argv[0]);
        return 1;
    }
    uint8_t state[256];
    arcfour_key_setup(state, argv[1], strlen(argv[1]));
    arcfour_generate_stream(state);
}

