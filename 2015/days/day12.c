#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char delims[] = "[]{}\":\n,abcdefghijklmnopqrstuvwxyz ";

void day12(const char *data, char **part1, char **part2) {
    char *data_ = strdup(data);

    // part1
    int num_sum = 0;
    for (char *tok = strtok(data_, delims); tok; tok = strtok(NULL, delims)) {
        num_sum += atoi(tok);
    }

    // part2
    strcpy(data_, data);
    for (char *cur = data_; *cur != '\0'; cur++) {
        if (strncmp(cur, ":\"red\"", 6) == 0) {
            int brace_counter = 1;
            for (char *start = cur; brace_counter != 0; start--) {
                if (*start == '{') brace_counter--;
                else if (*start == '}') brace_counter++;
                *start = ' ';
            }

            brace_counter = -1;
            for (char *end = cur; brace_counter != 0; end++) {
                if (*end == '{')      brace_counter--;
                else if (*end == '}') brace_counter++;
                *end = ' ';
            }
        }
    }
    int no_red_sum = 0;
    for (char *tok = strtok(data_, delims); tok; tok = strtok(NULL, delims)) {
        no_red_sum += atoi(tok);
    }
    free(data_);

    sprintf((*part1 = malloc(64)), "%d", num_sum);
    sprintf((*part2 = malloc(64)), "%d", no_red_sum);
}
