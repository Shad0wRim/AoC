#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

void simulate_step(bool grid[], size_t size) {
    bool *new_grid = calloc(size*size, sizeof(bool));
    for (size_t r = 0; r < size; r++) {
        for (size_t c = 0; c < size; c++) {
            size_t count = 0;
            count += r-1 < size && c-1 < size && grid[(r-1)*size+(c-1)];
            count += r-1 < size && c   < size && grid[(r-1)*size+(c)];
            count += r-1 < size && c+1 < size && grid[(r-1)*size+(c+1)];
            count += r   < size && c-1 < size && grid[(r)*size+(c-1)];
            count += r   < size && c+1 < size && grid[(r)*size+(c+1)];
            count += r+1 < size && c-1 < size && grid[(r+1)*size+(c-1)];
            count += r+1 < size && c   < size && grid[(r+1)*size+(c)];
            count += r+1 < size && c+1 < size && grid[(r+1)*size+(c+1)];
            
            if (grid[r*size+c]) { // alive
                new_grid[r*size+c] = count >= 2 && count <= 3;
            } else {              // dead
                new_grid[r*size+c] = count == 3;
            }
        }
    }

    for (size_t r = 0; r < size; r++) {
        for (size_t c = 0; c < size; c++) {
            grid[r*size+c] = new_grid[r*size+c];
        }
    }
    free(new_grid);
}

void simulate_step_broken(bool grid[], size_t size) {
    simulate_step(grid, size);
    grid[(0)*size+(0)] = true;
    grid[(0)*size+(size-1)] = true;
    grid[(size-1)*size+(0)] = true;
    grid[(size-1)*size+(size-1)] = true;
}


void day18(const char *data, char **part1, char **part2) {
    bool *grid  = calloc(strlen(data), sizeof(bool));
    bool *grid2 = calloc(strlen(data), sizeof(bool));

    // parsing
    size_t line = 0, col = 0, size = 0;
    for (const char *cur = data; *cur != '\0'; cur++) {
        if (*cur != '\n') {
            grid[line*size+col]  = *cur == '#';
            grid2[line*size+col] = *cur == '#';
            col++;
        } else {
            size = size != 0 ? size : col;
            line++;
            col = 0;
        }
    }

    // part1
    for (size_t i = 0; i < 100; i++) simulate_step(grid, size);
    size_t num_lights_on = 0;
    for (size_t r = 0; r < size; r++) {
        for (size_t c = 0; c < size; c++) {
            num_lights_on += grid[r*size+c];
        }
    }

    // part2
    grid2[(0)*size+(0)] = true;
    grid2[(0)*size+(size-1)] = true;
    grid2[(size-1)*size+(0)] = true;
    grid2[(size-1)*size+(size-1)] = true;
    for (size_t i = 0; i < 100; i++) simulate_step_broken(grid2, size);
    size_t num_lights_on_with_broken = 0;
    for (size_t r = 0; r < size; r++) {
        for (size_t c = 0; c < size; c++) {
            num_lights_on_with_broken += grid2[r*size+c];
        }
    }

    sprintf((*part1 = malloc(64)), "%zu", num_lights_on);
    sprintf((*part2 = malloc(64)), "%zu", num_lights_on_with_broken);
    free(grid);
    free(grid2);
}


void print_grid(bool grid[], size_t size) {
    for (size_t r = 0; r < size; r++) {
        for (size_t c = 0; c < size; c++) {
            printf("%c", grid[r*size+c] ? '#' : '.');
        }
        printf("\n");
    }
}
