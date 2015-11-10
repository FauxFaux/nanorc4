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
        uint8_t key_index = ki % key_len;
        uint8_t key_part = key[key_index];
        uint8_t state_part = state[ki];

        kj += state_part + key_part;

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
    ++i;
    j += state[i];

    // swap
    uint8_t t = state[i];
    state[i] = state[j];
    state[j] = t;

    uint8_t next_index = state[i] + state[j];

    return state[next_index];
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

