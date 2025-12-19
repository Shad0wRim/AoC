#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct {
    char *start;
    char *end;
    int dist;
} Path;

char locs[10][30] = {0}; int locs_len  = 0;
Path paths[50]    = {0}; int paths_len = 0;

int get_dist(char *start, char *end) {
    for (int i = 0; i < paths_len; i++) {
        char *pstart = paths[i].start, *pend = paths[i].end;
        if ((pstart == start && pend == end) || (pstart == end && pend == start)) {
            return paths[i].dist;
        }
    }
    return -1;
}

void minimum_distance(int *arr, int len, int *min_dist) {
    int tot_dist = 0;
    for (int i = 0; i < len - 1; i++) {
        char *start = locs[arr[i]];
        char *end = locs[arr[i+1]];
        int dist = get_dist(start, end);
        tot_dist += dist;
    }
    if (tot_dist < *min_dist) {
        *min_dist = tot_dist;
    }
}

void maximum_distance(int *arr, int len, int *max_dist) {
    int tot_dist = 0;
    for (int i = 0; i < len - 1; i++) {
        char *start = locs[arr[i]];
        char *end = locs[arr[i+1]];
        int dist = get_dist(start, end);
        tot_dist += dist;
    }
    if (tot_dist > *max_dist) {
        *max_dist = tot_dist;
    }
}

void permutations(int arr[], int len, int idx, int *output, void (*callback)(int*, int, int*)) {
    if (idx == len) {
        callback(arr, len, output);
        return;
    }

    for (int i = idx; i < len; i++) {
        int tmp = arr[i];
        arr[i] = arr[idx];
        arr[idx] = tmp;

        permutations(arr, len, idx+1, output, callback);

        arr[idx] = arr[i];
        arr[i] = tmp;
    }
}

void day09(const char *data, char **part1, char **part2) {
    const char *start, *end;

    for (end = data; *end != ' '; end++);
    strncpy(locs[0], data, end - data);
    locs_len = 1;

    for (start = data; *start != '\0'; start = end + 1) {
        for (end = start; *end != ' '; end++); // start loc
        char *start_loc = NULL;
        for (int i = 0; i < locs_len; i++) {
            if (strncmp(locs[i], start, end - start) == 0) {
                start_loc = locs[i];
                break;
            }
        }

        for (start = end + 1, end = start; *end != ' '; end++); // "to"
        for (start = end + 1, end = start; *end != ' '; end++); // end loc
        for (int i = 0; i < locs_len; i++) {
            if (strncmp(locs[i], start, end - start) == 0) goto found;
        }
        strncpy(locs[locs_len++], start, end - start);
found:;

        char *end_loc = NULL;
        for (int i = 0; i < locs_len; i++) {
            if (strncmp(locs[i], start, end - start) == 0) {
                end_loc = locs[i];
                break;
            }
        }

        for (start = end + 1, end = start; *end != ' '; end++); // "="
        for (start = end + 1, end = start; *end != '\n'; end++); // num
        char buf[10] = {0};
        strncpy(buf, start, end - start);
        int dist = atoi(buf);

        Path path = { .start = start_loc, .end = end_loc, .dist = dist };
        paths[paths_len++] = path;
    }
    int indices[10] = {0};

    // part1
    for (int i = 0; i < locs_len; i++) indices[i] = i;
    int min_dist = 0x7fffffff;
    permutations(indices, locs_len, 0, &min_dist, minimum_distance);

    // part2
    for (int i = 0; i < locs_len; i++) indices[i] = i;
    int max_dist = 0;
    permutations(indices, locs_len, 0, &max_dist, maximum_distance);

    sprintf((*part1 = malloc(64)), "%d", min_dist);
    sprintf((*part2 = malloc(64)), "%d", max_dist);
}
