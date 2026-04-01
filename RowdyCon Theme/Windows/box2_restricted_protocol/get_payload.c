#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

#define PAYLOAD_PATH "/opt/.rcc_profile/.comms.dat"
#define KEY "Dec0deTh1s!"

int main(void) {
    FILE *f = fopen(PAYLOAD_PATH, "rb");
    if (!f) {
        fprintf(stderr, "Payload missing\n");
        return 1;
    }

    if (fseek(f, 0, SEEK_END) != 0) {
        fclose(f);
        return 1;
    }
    long len = ftell(f);
    if (len <= 0) {
        fclose(f);
        return 1;
    }
    if (fseek(f, 0, SEEK_SET) != 0) {
        fclose(f);
        return 1;
    }

    uint8_t *buf = malloc((size_t)len);
    if (!buf) {
        fclose(f);
        return 1;
    }

    size_t read = fread(buf, 1, (size_t)len, f);
    fclose(f);
    if (read != (size_t)len) {
        free(buf);
        return 1;
    }

    const char *key = KEY;
    size_t keylen = sizeof(KEY) - 1;
    for (long i = 0; i < len; i++) {
        uint8_t plain = buf[i] ^ (uint8_t)key[i % keylen];
        printf("%u\n", (unsigned int)plain);
    }

    free(buf);
    return 0;
}
