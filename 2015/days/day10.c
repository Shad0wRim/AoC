#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *rle(const char *str) {
    char *out = calloc(strlen(str) * 2, 1); // most it can increase is by double
    char *out_end = out;
    const char *cur = str;
    char c;

    while ((c = *cur) != '\0') {
        int run_count = 1;
        while (*(++cur) == c) run_count++;

        int written = sprintf(out_end, "%d%c", run_count, c);
        out_end += written;
    }
    return out;
}

void day10(const char *data, char **part1, char **part2) {
    char *out = strdup(data);
    int len = strlen(out);
    if (out[len-1] == '\n') out[len-1] = '\0';

    // part1
    for (int i = 0; i < 40; i++) {
        char *new_out = rle(out);
        free(out);
        out = new_out;
    }
    int forty_iters = strlen(out);

    // part2
    for (int i = 0; i < 10; i++) {
        char *new_out = rle(out);
        free(out);
        out = new_out;
    }
    int fifty_iters = strlen(out);
    free(out);

    sprintf((*part1 = malloc(64)), "%d", forty_iters);
    sprintf((*part2 = malloc(64)), "%d", fifty_iters);
}
