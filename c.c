#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

static uint8_t key_len;
static uint8_t *key;

static uint8_t state[256];
static uint8_t i = 0, j = 0;


void arcfour_key_setup(void) {
    uint8_t k = 0;
    for (;;) {
        state[k] = k;
        ++k;
        if (0 == k) { // overflow
            break;
        }
    }

    uint8_t kj = 0;
    uint8_t ki = 0;
    for (;;) {
        kj = (kj + state[ki] + key[ki % key_len]) % 256;

        // swap
        uint8_t t = state[ki];
        state[ki] = state[kj];
        state[kj] = t;

        ++ki;
        if (ki == 0) { // overflow
            break;
        }
    }
}

uint8_t next(void) {
    i = (i + 1) % 256;
    j = (j + state[i]) % 256;

    // swap
    uint8_t t = state[i];
    state[i] = state[j];
    state[j] = t;

    return state[(state[i] + state[j]) % 256];
}

void drop(void) {
    for (int k = 0; k < 1024; ++k) {
        next();
    }
}

void arcfour_generate_stream(void) {
    for (;;) {
        int got = getchar();
        if (EOF == got) {
            return;
        }
        putchar(got ^ next());
    }
}

int main(int argc, char **argv) {
    if (2 != argc) {
        fprintf(stderr, "usage: %s 'key'", argv[0]);
        return 1;
    }
    key = argv[1];
    key_len = strlen(key);

    arcfour_key_setup();
    
    
    arcfour_generate_stream();
}

