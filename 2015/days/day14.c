#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

typedef struct {
    char *name;
    int speed;
    int fly_time;
    int rest_time;
} Stats;

int calc_reindeer_dist(Stats* reindeer, int seconds) {
    int cycle_time    = reindeer->fly_time + reindeer->rest_time;
    int full_cycles   = seconds / cycle_time;
    int curr_cyc_time = seconds % cycle_time;
    int full_time     = full_cycles * reindeer->fly_time;
    int partial_time  = curr_cyc_time < reindeer->fly_time ? curr_cyc_time : reindeer->fly_time;
    int time_flying   = full_time + partial_time;
    return time_flying * reindeer->speed;
}

void day14(const char *data, char **part1, char **part2) {
    char reindeer_names[10][50] = {0};
    Stats reindeer_stats[10] = {0};
    int reindeer_len = 0;

    const char *cur_l, *cur_r, *start, *end;
    char *name, buf[64] = {0};
    for (start = data; *start != '\0'; start = end + 1) {
        for (end = start; *end != '\n'; end++); // end of line

        for (cur_l = start, cur_r = cur_l; *cur_r != ' '; cur_r++); // name
        strncpy(reindeer_names[reindeer_len++], cur_l, cur_r - cur_l);
        name = reindeer_names[reindeer_len-1];

        for (cur_l = cur_r+1; !isdigit(*cur_l); cur_l++); // step until number
        for (cur_r = cur_l; *cur_r != ' '; cur_r++);
        strncpy(buf, cur_l, cur_r - cur_l);
        buf[cur_r-cur_l] = '\0';
        int speed = atoi(buf);

        for (cur_l = cur_r+1; !isdigit(*cur_l); cur_l++); // step until number
        for (cur_r = cur_l; *cur_r != ' '; cur_r++);
        strncpy(buf, cur_l, cur_r - cur_l);
        buf[cur_r-cur_l] = '\0';
        int fly_time = atoi(buf);

        for (cur_l = cur_r+1; !isdigit(*cur_l); cur_l++); // step until number
        for (cur_r = cur_l; *cur_r != ' '; cur_r++);
        strncpy(buf, cur_l, cur_r - cur_l);
        buf[cur_r-cur_l] = '\0';
        int rest_time = atoi(buf);

        reindeer_stats[reindeer_len-1] = (Stats){ 
            .name = name,
            .speed = speed,
            .fly_time = fly_time,
            .rest_time = rest_time
        };
    }

    // part1
    int max_distance = 0;
    for (int i = 0; i < reindeer_len; i++) {
        int dist = calc_reindeer_dist(&reindeer_stats[i], 2503);
        if (dist > max_distance) max_distance = dist;
    }

    // part2
    int points[30] = {0};
    for (int t = 1; t <= 2503; t++) {
        int dists[30] = {0}, max_dist = 0;
        for (int i = 0; i < reindeer_len; i++) {
            dists[i] = calc_reindeer_dist(&reindeer_stats[i], t);
            if (dists[i] > max_dist) max_dist = dists[i];
        }
        for (int i = 0; i < reindeer_len; i++) {
            if (dists[i] == max_dist) points[i]++;
        }
    }
    int max_points = 0;
    for (int i = 0; i < reindeer_len; i++) {
        if (points[i] > max_points) max_points = points[i];
    }

    sprintf((*part1 = malloc(64)), "%d", max_distance);
    sprintf((*part2 = malloc(64)), "%d", max_points);
}
