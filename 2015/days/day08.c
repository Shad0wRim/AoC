#include <stdio.h>
#include <stdlib.h>

void day08(const char *data, char **part1, char **part2) {
    const char *start, *end;
    int tot_string_chars = 0, tot_code_chars = 0, tot_encode_chars = 0;

    // part1
    end = data - 1;
    while (*(start = end + 1) != '\0') {
        int curr_code_chars = 0;
        for (end = start; *end != '\n'; end++) {
            if (*end == '\\') {
                end++; // skip the backslash
                if (*end == 'x') end+=2; // skip the hex digits
            }
            curr_code_chars++;
        }
        tot_string_chars += end - start;
        tot_code_chars += curr_code_chars - 2;
    }

    // part2
    end = data - 1;
    while (*(start = end + 1) != '\0') {
        int curr_encode_chars = 0;
        for (end = start; *end != '\n'; end++) {
            if (*end == '"' || *end == '\\') {
                curr_encode_chars+=2;
            } else {
                curr_encode_chars++;
            }
        }
        tot_encode_chars += curr_encode_chars + 2;
    }

    sprintf((*part1 = malloc(64)), "%d", tot_string_chars - tot_code_chars);
    sprintf((*part2 = malloc(64)), "%d", tot_encode_chars - tot_string_chars);
}
