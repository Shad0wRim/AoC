#include <stdio.h>
#include <stdlib.h>

void day01(const char *data, char **part1, char **part2) {
    int floor = 0, basement_pos = -1;
    for (const char* cur = data; *cur != '\0'; cur++) {
        // part1
        if      (*cur == '(') floor++;
        else if (*cur == ')') floor--;

        // part2
        if (basement_pos == -1 && floor < 0) 
            basement_pos = cur - data + 1;
    }

    sprintf((*part1 = malloc(64)), "%d", floor);
    sprintf((*part2 = malloc(64)), "%d", basement_pos);
}
