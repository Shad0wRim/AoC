#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

bool isnice1(const char *str) {
    int vowel_count = 0;
    bool at_least_1_repeat = false;
    bool no_banned_strings = true;
    char last_char = '\0';

    for (const char *cur = str; *cur != '\0'; last_char = *cur, cur++) {
        // vowel count
        if (*cur == 'a' || *cur == 'e' || *cur == 'i' || *cur == 'o' || *cur == 'u') {
            vowel_count++;
        }
        // double letter
        if (*cur == last_char) at_least_1_repeat = true;
        // banned strings
        if ((last_char == 'a' && *cur == 'b') ||
            (last_char == 'c' && *cur == 'd') ||
            (last_char == 'p' && *cur == 'q') ||
            (last_char == 'x' && *cur == 'y')
        ) {
            no_banned_strings = false;
            break;
        }
    }
    return vowel_count >= 3 && at_least_1_repeat && no_banned_strings;
}

bool isnice2(const char *str) {
    int len = strlen(str);
    char last2[2] = {0};

    bool found_sandwich = false;
    for (const char *cur = str; *cur != '\0'; last2[0] = last2[1], last2[1] = *cur, cur++) {
        if (last2[0] == *cur) {
            found_sandwich = true;
            break;
        }
    }
    if (!found_sandwich) return false;

    // strings are short, so just compare each possible pair
    for (const char *cur = str; cur - str < len - 3; cur++) {
        for (const char *fut = cur+2; fut - str < len - 1; fut+=1) {
            if (cur[0] == fut[0] && cur[1] == fut[1]) {
                return true;
            }
        }
    }
    return false;
}

void day05(const char *data, char **part1, char **part2) {
    char *data_ = strdup(data);
    char *tok = strtok(data_, "\n");

    int tot_nice1 = 0, tot_nice2 = 0;
    while (tok) {
        if (isnice1(tok)) tot_nice1++;
        if (isnice2(tok)) tot_nice2++;

        tok = strtok(NULL, "\n");
    }
    free(data_);

    sprintf((*part1 = malloc(64)), "%d", tot_nice1);
    sprintf((*part2 = malloc(64)), "%d", tot_nice2);
}
