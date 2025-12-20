#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int children;
    int cats;
    int samoyeds;
    int pomeranians;
    int akitas;
    int vizslas;
    int goldfish;
    int trees;
    int cars;
    int perfumes;
} MFCSAM;

int *match_MFCSAM_field(MFCSAM *a, const char *start, const char *end) {
    if (strncmp(start, "children",    end-start) == 0) return &a->children;
    if (strncmp(start, "cats",        end-start) == 0) return &a->cats;
    if (strncmp(start, "samoyeds",    end-start) == 0) return &a->samoyeds;
    if (strncmp(start, "pomeranians", end-start) == 0) return &a->pomeranians;
    if (strncmp(start, "akitas",      end-start) == 0) return &a->akitas;
    if (strncmp(start, "vizslas",     end-start) == 0) return &a->vizslas;
    if (strncmp(start, "goldfish",    end-start) == 0) return &a->goldfish;
    if (strncmp(start, "trees",       end-start) == 0) return &a->trees;
    if (strncmp(start, "cars",        end-start) == 0) return &a->cars;
    if (strncmp(start, "perfumes",    end-start) == 0) return &a->perfumes;
    return NULL;
}

void day16(const char *data, char **part1, char **part2) {
    MFCSAM sues[500] = {0};
    const char *word, *cur = data;
    for (int sue = 0; sue < 500; sue++) {
        sues[sue] = (MFCSAM){-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
        while (1) {
            while (*cur != ':') cur++;
            word = cur-1;
            if (isdigit(*word)) {
                cur++;
                continue;
            }
            while (isalpha(*word)) word--;
            int *field = match_MFCSAM_field(&sues[sue], word+1, cur);
            *field = atoi(cur+2);

            while (*cur != ',' && *cur != '\n') cur++;
            if (*cur == ',') continue;
            else break;
        }
    }
    MFCSAM true_sue_stats = {
        .children = 3,
        .cats = 7,
        .samoyeds = 2,
        .pomeranians = 3,
        .akitas = 0,
        .vizslas = 0,
        .goldfish = 5,
        .trees = 3,
        .cars = 2,
        .perfumes = 1,
    };

    // part1
    int true_sue = -1;
    for (int sue = 0; sue < 500; sue++) {
        if((sues[sue].children    == -1 || sues[sue].children    == true_sue_stats.children)
        && (sues[sue].cats        == -1 || sues[sue].cats        == true_sue_stats.cats)
        && (sues[sue].samoyeds    == -1 || sues[sue].samoyeds    == true_sue_stats.samoyeds)
        && (sues[sue].pomeranians == -1 || sues[sue].pomeranians == true_sue_stats.pomeranians)
        && (sues[sue].akitas      == -1 || sues[sue].akitas      == true_sue_stats.akitas)
        && (sues[sue].vizslas     == -1 || sues[sue].vizslas     == true_sue_stats.vizslas)
        && (sues[sue].goldfish    == -1 || sues[sue].goldfish    == true_sue_stats.goldfish)
        && (sues[sue].trees       == -1 || sues[sue].trees       == true_sue_stats.trees)
        && (sues[sue].cars        == -1 || sues[sue].cars        == true_sue_stats.cars)
        && (sues[sue].perfumes    == -1 || sues[sue].perfumes    == true_sue_stats.perfumes)) {
            true_sue = sue+1;
        }
    }

    // part2
    int real_true_sue = -1;
    for (int sue = 0; sue < 500; sue++) {
        if((sues[sue].children    == -1 || sues[sue].children    == true_sue_stats.children)
        && (sues[sue].cats        == -1 || sues[sue].cats        >  true_sue_stats.cats)
        && (sues[sue].samoyeds    == -1 || sues[sue].samoyeds    == true_sue_stats.samoyeds)
        && (sues[sue].pomeranians == -1 || sues[sue].pomeranians <  true_sue_stats.pomeranians)
        && (sues[sue].akitas      == -1 || sues[sue].akitas      == true_sue_stats.akitas)
        && (sues[sue].vizslas     == -1 || sues[sue].vizslas     == true_sue_stats.vizslas)
        && (sues[sue].goldfish    == -1 || sues[sue].goldfish    <  true_sue_stats.goldfish)
        && (sues[sue].trees       == -1 || sues[sue].trees       >  true_sue_stats.trees)
        && (sues[sue].cars        == -1 || sues[sue].cars        == true_sue_stats.cars)
        && (sues[sue].perfumes    == -1 || sues[sue].perfumes    == true_sue_stats.perfumes)) {
            real_true_sue = sue+1;
        }
    }

    sprintf((*part1 = malloc(64)), "%d", true_sue);
    sprintf((*part2 = malloc(64)), "%d", real_true_sue);
}

// debug function
void dump_mfcsam(const MFCSAM* s) {
    printf("children: %d\n", s->children);
    printf("cats: %d\n", s->cats);
    printf("samoyeds: %d\n", s->samoyeds);
    printf("pomeranians: %d\n", s->pomeranians);
    printf("akitas: %d\n", s->akitas);
    printf("vizslas: %d\n", s->vizslas);
    printf("goldfish: %d\n", s->goldfish);
    printf("trees: %d\n", s->trees);
    printf("cars: %d\n", s->cars);
    printf("perfumes: %d\n", s->perfumes);
}
