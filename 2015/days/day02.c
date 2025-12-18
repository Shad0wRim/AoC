#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int min(int a, int b, int c) {
    return a <= b && a <= c ? a 
         : b <= a && b <= c ? b 
         : c;
}

void day02(const char *data, char **part1, char **part2) {
    char *data_ = strdup(data);
    int tot_surf_area = 0, tot_ribbon_len = 0;

    char *tok1, *tok2, *tok3;
    tok1 = strtok(data_, "x\n");
    tok2 = strtok(NULL, "x\n");
    tok3 = strtok(NULL, "x\n");
    while (tok1 && tok2 && tok3) {
        int l = atoi(tok1), w = atoi(tok2), h = atoi(tok3);

        // part1
        int side1 = l*w;
        int side2 = w*h;
        int side3 = h*l;
        int min_side = min(side1, side2, side3);
        tot_surf_area += 2*side1 + 2*side2 + 2*side3 + min_side;

        // part2
        int around = min(2*(l+w), 2*(w+h), 2*(h+l));
        tot_ribbon_len += l*w*h + around;

        tok1 = strtok(NULL, "x\n");
        tok2 = strtok(NULL, "x\n");
        tok3 = strtok(NULL, "x\n");
    }
    free(data_);

    sprintf((*part1 = malloc(64)), "%d", tot_surf_area);
    sprintf((*part2 = malloc(64)), "%d", tot_ribbon_len);
}
