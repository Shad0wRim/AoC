#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char people[32][50] = {0};
int people_len = 0;

typedef struct {
    char *here;
    char *next;
    int hap;
} Relation;

Relation rels[128] = {0};
int rels_len = 0;

char *get_person_ptr(const char *name, int len) {
    for (int i = 0; i < people_len; i++) {
        if (strncmp(people[i], name, len) == 0) {
            return people[i];
        }
    }
    return NULL;
}

void max_happiness(int *arr, int len, int *max_hap) {
    int hap = 0;
    for (int i = 0; i < len; i++) {
        char *here  = people[arr[i]];
        char *right = people[(arr[(i+1)%len])];
        char *left  = people[arr[(i+len-1)%len]];
        int left_hap = 0, right_hap = 0;
        for (int i = 0; i < rels_len; i++) {
            if (here == rels[i].here) {
                if (left == rels[i].next) {
                    left_hap = rels[i].hap;
                } else if (right == rels[i].next) {
                    right_hap = rels[i].hap;
                }
            }
        }
        hap += left_hap;
        hap += right_hap;
    }

    if (hap > *max_hap) *max_hap = hap;
}

// reuse function from day 9
extern void permutations(int arr[], int len, int idx, int *output, void (*callback)(int*, int, int*));

void day13(const char *data, char **part1, char **part2) {
    const char *cur_l, *cur_r, *start, *end;
    char *here, *next;
    for (start = data; *start != '\0'; start = end + 1) {
        for (end = start; *end != '\n'; end++); // end of line

        for (cur_l = start, cur_r = cur_l; *cur_r != ' '; cur_r++); // name
        if ((here = get_person_ptr(cur_l, cur_r - cur_l)) == NULL) {
            strncpy(people[people_len++], cur_l, cur_r - cur_l);
            here = people[people_len-1];
        }

        for (cur_l = cur_r+1, cur_r = cur_l; *cur_r != ' '; cur_r++); // would

        for (cur_l = cur_r+1, cur_r = cur_l; *cur_r != ' '; cur_r++); // gain/lose
        int factor = 1;
        if (strncmp(cur_l, "lose", 4) == 0) factor = -1;

        for (cur_l = cur_r + 1, cur_r = cur_l; *cur_r != ' '; cur_r++); // num
        char buf[64] = {0};
        strncpy(buf, cur_l, cur_r - cur_l);
        int num = atoi(buf) * factor;

        for (cur_r = end-1, cur_l = cur_r; *cur_l != ' '; cur_l--); // name
        cur_l++;
        if ((next = get_person_ptr(cur_l, cur_r - cur_l)) == NULL) {
            strncpy(people[people_len++], cur_l, cur_r - cur_l);
            next = people[people_len-1];
        }

        rels[rels_len++] = (Relation){ .here = here, .next = next, .hap = num };
    }

    // part1
    int indices[32] = {0};
    for (int i = 0; i < people_len; i++) indices[i] = i;
    int max_hap = 0x80000000;
    permutations(indices, people_len, 0, &max_hap, max_happiness);

    // part2
    strcpy(people[people_len++], "me");
    for (int i = 0; i < people_len; i++) indices[i] = i;
    int max_hap_with_me = 0x80000000;
    permutations(indices, people_len, 0, &max_hap_with_me, max_happiness);

    sprintf((*part1 = malloc(64)), "%d", max_hap);
    sprintf((*part2 = malloc(64)), "%d", max_hap_with_me);
}
