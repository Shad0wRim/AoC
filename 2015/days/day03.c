#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int x;
    int y;
} Point;
typedef struct {
    Point *items;
    size_t len;
    size_t cap;
} FoundPoints;
void add_point(FoundPoints *arr, Point new_p) {
    for (size_t i = 0; i < arr->len; i++) {
        Point p = arr->items[i];
        if (p.x == new_p.x && p.y == new_p.y) return;
    }

    if (arr->cap == arr->len) {
        if (arr->cap == 0) arr->cap = 128;
        arr->cap *= 2;
        arr->items = realloc(arr->items, arr->cap * sizeof(Point));
    }
    arr->items[arr->len] = new_p;
    arr->len++;
}

void day03(const char *data, char **part1, char **part2) {
    FoundPoints houses_visited = {0};
    Point santa_loc, robo_santa_loc;

    // part1
    santa_loc = (Point){0};
    add_point(&houses_visited, santa_loc);
    for (const char *cur = data; *cur != '\0'; cur++) {
        switch (*cur) {
            case '^': santa_loc.y++; break;
            case 'v': santa_loc.y--; break;
            case '>': santa_loc.x++; break;
            case '<': santa_loc.x--; break;
            default: break;
        }
        add_point(&houses_visited, santa_loc);
    }
    int solo_santa_visisted = houses_visited.len;
    houses_visited.len = 0;

    // part2
    santa_loc      = (Point){0};
    robo_santa_loc = (Point){0};
    add_point(&houses_visited, santa_loc);
    int santas_turn = 1;
    for (const char *cur = data; *cur != '\0'; cur++, santas_turn = !santas_turn) {
        switch (*cur) {
            case '^':
                if (santas_turn) santa_loc.y++; 
                else robo_santa_loc.y++; 
                break;
            case 'v':
                if (santas_turn) santa_loc.y--; 
                else robo_santa_loc.y--; 
                break;
            case '>':
                if (santas_turn) santa_loc.x++; 
                else robo_santa_loc.x++; 
                break;
            case '<':
                if (santas_turn) santa_loc.x--; 
                else robo_santa_loc.x--; 
                break;
            default: break;
        }
        add_point(&houses_visited, santas_turn ? santa_loc : robo_santa_loc);
    }
    int duo_santa_visited = houses_visited.len;
    free(houses_visited.items);

    sprintf((*part1 = malloc(64)), "%d", solo_santa_visisted);
    sprintf((*part2 = malloc(64)), "%d", duo_santa_visited);
}
