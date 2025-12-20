#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[64];
    int capa;
    int dura;
    int flav;
    int text;
    int calo;
} Ingredients;

int score_cookie(Ingredients ingrs[], int distribution[], int len) {
    int tot_capa = 0, tot_dura = 0, tot_flav = 0, tot_text = 0;
    for (int i = 0; i < len; i++) {
        tot_capa += ingrs[i].capa * distribution[i];
        tot_dura += ingrs[i].dura * distribution[i];
        tot_flav += ingrs[i].flav * distribution[i];
        tot_text += ingrs[i].text * distribution[i];
    } 
    if (tot_capa < 0) tot_capa = 0;
    if (tot_dura < 0) tot_dura = 0;
    if (tot_flav < 0) tot_flav = 0;
    if (tot_text < 0) tot_text = 0;
    return tot_capa * tot_dura * tot_flav * tot_text;
}

int calorie_count(Ingredients ingrs[], int distribution[], int len) {
    int tot_calo = 0;
    for (int i = 0; i < len; i++) tot_calo += ingrs[i].calo * distribution[i];
    return tot_calo;
}

int find_max_cookie_score(int distribution[], int len, int idx, int amount_left, 
                          Ingredients *ingrs) {
    if (idx == len - 1) {
        distribution[idx] = amount_left;
        return score_cookie(ingrs, distribution, len);
    }
    int max_score = 0;
    for (int i = 0; i < amount_left; i++) {
        distribution[idx] = i;
        int score = find_max_cookie_score(distribution, len, idx+1, amount_left-i, ingrs);
        if (score > max_score) max_score = score;
    }
    return max_score;
}

int find_max_cookie_score_with_calories(int distribution[], int len, int idx, int amount_left, 
                          Ingredients *ingrs, int calories) {
    if (idx == len - 1) {
        distribution[idx] = amount_left;
        if (calorie_count(ingrs, distribution, len) != calories) return 0;
        return score_cookie(ingrs, distribution, len);
    }
    int max_score = 0;
    for (int i = 0; i < amount_left; i++) {
        distribution[idx] = i;
        int score = find_max_cookie_score_with_calories(
                distribution, len, idx+1, amount_left-i, ingrs, 500);
        if (score > max_score) max_score = score;
    }
    return max_score;
}

void day15(const char *data, char **part1, char **part2) {
    Ingredients ingrs[5] = {0};
    int ingrs_len = 0;
    // parsing
    for (const char *cur = data; *cur != '\0'; cur++) {
        const char *last = cur;
        while (*last != ':') last++;
        strncpy(ingrs[ingrs_len].name, cur, last - cur);

        cur = ++last;
        while (!isdigit(*cur) && *cur != '-') cur++;
        while (*last != ',') last++;
        ingrs[ingrs_len].capa = atoi(cur);

        cur = ++last;
        while (!isdigit(*cur) && *cur != '-') cur++;
        while (*last != ',') last++;
        ingrs[ingrs_len].dura = atoi(cur);

        cur = ++last;
        while (!isdigit(*cur) && *cur != '-') cur++;
        while (*last != ',') last++;
        ingrs[ingrs_len].flav = atoi(cur);

        cur = ++last;
        while (!isdigit(*cur) && *cur != '-') cur++;
        while (*last != ',') last++;
        ingrs[ingrs_len].text = atoi(cur);

        cur = ++last;
        while (!isdigit(*cur) && *cur != '-') cur++;
        while (*last != '\n') last++;
        ingrs[ingrs_len].calo = atoi(cur);

        ingrs_len++;
        cur = last;
    }
    int distribution[5] = {0};

    // part1
    int max_score = find_max_cookie_score(distribution, ingrs_len, 0, 100, ingrs);

    // part2
    int max_score_with_calories = find_max_cookie_score_with_calories(
            distribution, ingrs_len, 0, 100, ingrs, 500);

    sprintf((*part1 = malloc(64)), "%d", max_score);
    sprintf((*part2 = malloc(64)), "%d", max_score_with_calories);
}
