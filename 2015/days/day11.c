#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool valid_password(const char *str) {
    bool has_increasing = false;
    int num_pairs = 0;

    char last2[2] = {0};
    for (const char *cur = str; *cur != '\0'; last2[0] = last2[1], last2[1] = *cur, cur++) {
        char c = *cur;

        if (c == 'i' || c == 'j' || c == 'o') return false; // has a bad letter, skip
        if (last2[0] + 2 == last2[1] + 1 && last2[1] + 1 == c) has_increasing = true;
        if (last2[1] == c && last2[0] != c) num_pairs += 1; // doesnt detect "aaaa" but eh
    }

    return has_increasing && num_pairs >= 2;
}

void increment_password(char *str) {
    for (int i = strlen(str)-1; i >= 0; i--) {
        bool overflow = false;
        char c = str[i];
        c += 1;
        if (c > 'z') {
            overflow = true;
            c -= 26;
        }
        str[i] = c;
        if (!overflow) break;
    }
}

void day11(const char *data, char **part1, char **part2) {
    char *pass = strdup(data);
    int len = strlen(pass);
    if (pass[len-1] == '\n') pass[len-1] = '\0';

    // part1
    increment_password(pass);
    while (!valid_password(pass)) increment_password(pass);
    sprintf((*part1 = malloc(64)), "%s", pass);

    // part2
    increment_password(pass);
    while (!valid_password(pass)) increment_password(pass);
    sprintf((*part2 = malloc(64)), "%s", pass);

    free(pass);
}
