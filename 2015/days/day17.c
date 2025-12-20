#include <stdio.h>
#include <stdlib.h>

int distribute_eggnog(const int sizes[], int len, int idx, int amount) {
    if (idx == len) return amount == 0;
    int ways_with = distribute_eggnog(sizes, len, idx+1, amount-sizes[idx]);
    int ways_without = distribute_eggnog(sizes, len, idx+1, amount);
    return ways_with + ways_without;
}

int find_min_containers(const int sizes[], int len, int idx, int amount, int cont_used) {
    if (idx == len) return amount == 0 ? cont_used : 0x7fffffff;
    int min_with = find_min_containers(sizes, len, idx+1, amount-sizes[idx], cont_used+1);
    int min_without = find_min_containers(sizes, len, idx+1, amount, cont_used);
    return min_with < min_without ? min_with : min_without;
}

int use_min_containers(const int sizes[], int len, int idx, int amount, int cont_used, int cont_min
    ) {
    if (idx == len) return cont_used == cont_min && amount == 0;
    int ways_with = 
        use_min_containers(sizes, len, idx+1, amount-sizes[idx], cont_used+1, cont_min);
    int ways_without =
        use_min_containers(sizes, len, idx+1, amount, cont_used, cont_min);
    return ways_with + ways_without;
}

void day17(const char *data, char **part1, char **part2) {
    // parsing
    int sizes[20] = {0};
    const char *cur = data;
    for (int i = 0; i < 20; i++) {
        sizes[i] = atoi(cur);
        while (*cur != '\n') cur++;
        cur++;
    }

    // part1
    int container_combinations = distribute_eggnog(sizes, 20, 0, 150);

    // part2
    int cont_min = find_min_containers(sizes, 20, 0, 150, 0);
    printf("%d\n", cont_min);
    int min_container_combinations = use_min_containers(sizes, 20, 0, 150, 0, cont_min);

    sprintf((*part1 = malloc(64)), "%d", container_combinations); 
    sprintf((*part2 = malloc(64)), "%d", min_container_combinations); 
}
