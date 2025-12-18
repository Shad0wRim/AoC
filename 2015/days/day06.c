#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef enum {
    INVALID,
    TOGGLE,
    ON,
    OFF,
} Action;

void day06(const char *data, char **part1, char **part2) {
    char *data_ = strdup(data);
    bool *grid_bool = calloc(1000*1000, sizeof(bool));
    int *grid_int = calloc(1000*1000, sizeof(int));

    char *line, *lines, *word, *save_line, *save_word, *save_num;
    for (lines = data_; (line = strtok_r(lines, "\n", &save_line)); lines = NULL) {
        // parsing
        Action action = INVALID;
        word = strtok_r(line, " ", &save_word);
        if (strcmp(word, "turn") == 0) {
            word = strtok_r(NULL, " ", &save_word);
            if (strcmp(word, "on") == 0) {
                action = ON;
            } else if (strcmp(word, "off") == 0) {
                action = OFF;
            }
        } else if (strcmp(word, "toggle") == 0) {
            action = TOGGLE;
        }
        word = strtok_r(NULL, " ", &save_word);

        int i_loc[2];
        i_loc[0] = atoi(strtok_r(word, ",", &save_num));
        i_loc[1] = atoi(strtok_r(NULL, ",", &save_num));

        word = strtok_r(NULL, " ", &save_word); // skip "through"
        word = strtok_r(NULL, " ", &save_word);

        int f_loc[2];
        f_loc[0] = atoi(strtok_r(word, ",", &save_num));
        f_loc[1] = atoi(strtok_r(NULL, ",", &save_num));

        // assume that i_loc .<= f_loc, which is true for the dataset
        for (int x = i_loc[0]; x <= f_loc[0]; x++) {
            for (int y = i_loc[1]; y <= f_loc[1]; y++) {
                // part1
                switch (action) {
                    case TOGGLE: grid_bool[x*1000+y] ^= true;  break;
                    case ON:     grid_bool[x*1000+y]  = true;  break;
                    case OFF:    grid_bool[x*1000+y]  = false; break;
                    case INVALID: exit(1);
                }

                // part2
                switch (action) {
                    case TOGGLE: grid_int[x*1000+y] += 2; break;
                    case ON:     grid_int[x*1000+y] += 1; break;
                    case OFF:    grid_int[x*1000+y] -= grid_int[x*1000+y] != 0; break;
                    case INVALID: exit(1);
                }
            }
        }
    }

    int light_count = 0, brightness_count = 0;
    for (int i = 0; i < 1000*1000; i++) {
        if (grid_bool[i]) light_count++;
        brightness_count += grid_int[i];
    }

    free(data_);
    free(grid_bool);
    free(grid_int);

    sprintf((*part1 = malloc(64)), "%d", light_count);
    sprintf((*part2 = malloc(64)), "%d", brightness_count);
}
