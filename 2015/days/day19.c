#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

typedef struct {
    const char *str;
    size_t len;
} s_view;

typedef struct {
    s_view initial;
    s_view replacement;
} Replacement;

typedef struct {
    Replacement *items;
    size_t len;
    size_t cap;
} Replacements;

typedef struct {
    char **items;
    size_t len;
    size_t cap;
} Strings;

#define append(arr, item)                                                             \
    do {                                                                              \
        if ((arr)->len >= (arr)->cap) {                                               \
            (arr)->cap = (arr)->cap ? (arr)->cap * 2 : 128;                           \
            (arr)->items = realloc((arr)->items, (arr)->cap * sizeof(*(arr)->items)); \
        }                                                                             \
        (arr)->items[(arr)->len++] = (item);                                          \
    } while(0)


bool append_strs_unique(Strings *strs, char *str) {
    for (size_t i = 0; i < strs->len; i++) {
        if (strcmp(str, strs->items[i]) == 0) return false;
    }
    append(strs, str);
    return true;
}

void apply_all_replacements(Strings *strs, Replacement rep, s_view str) {
    char buf[1024] = {0};
    for (size_t i = 0; i < str.len; i++) {
        if (strncmp(str.str+i, rep.initial.str, rep.initial.len) == 0) {
            strncpy(buf, str.str, i);
            buf[i] = '\0';
            strncat(buf, rep.replacement.str, rep.replacement.len);

            const char *tail = str.str + i + rep.initial.len;
            size_t tail_len = str.len - i - rep.initial.len;
            strncat(buf, tail, tail_len);
            char *replaced_str = strdup(buf);

            if (!append_strs_unique(strs, replaced_str)) free(replaced_str);
        }
    }
}

// hashmap is not done yet
typedef struct {
    size_t hash;
    char *key;
    int value;
} HashEntry;
typedef struct {
    HashEntry *items;
    size_t *indices;
    size_t len;
    size_t cap;
} HashMap;
// djb2 hash function
size_t hash(char *buf) {
    size_t hash = 5381;
    int c;
    while ((c = *buf++)) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash;
}
void hashmap_insert(HashMap *map, char *key, int value) {
    if (map->len * 2 >= map->cap) {
        // resize
        map->cap = map->cap ? map->cap * 2 : 128;
        map->items = realloc(map->items, map->cap * sizeof(*map->items));

        // rehash
        free(map->indices);
        map->indices = malloc(map->cap * sizeof(*map->indices));
        memset(map->indices, 0xff, map->cap * sizeof(*map->indices));
        for (size_t i = 0; i < map->len; i++) {
            HashEntry *entry = &map->items[i];
            entry->hash = hash(entry->key);
            size_t idx = entry->hash % map->cap;
            while (map->indices[idx] != SIZE_MAX) idx = (idx + 1) % map->cap;
            map->indices[idx] = i;
        }
    }
    HashEntry entry = {
        .hash = hash(key),
        .key = key,
        .value = value,
    };
    map->items[map->len] = entry;
    size_t h_idx = entry.hash % map->cap;
    while (map->indices[h_idx] != SIZE_MAX) h_idx = (h_idx + 1) % map->cap;
    map->indices[h_idx] = map->len;
    map->len += 1;
}
HashEntry *hashmap_get_entry(HashMap *map, char *key) {
    if (map->len == 0) return NULL;
    size_t h = hash(key);
    size_t h_idx = h % map->cap;
    HashEntry *entry = NULL;
    while (true) {
        if (map->indices[h_idx] == SIZE_MAX) return NULL;
        size_t idx = map->indices[h_idx];
        entry = &map->items[idx];
        if (entry->hash == h && strcmp(entry->key, key) == 0) {
            return entry;
        } else {
            h_idx += 1;
        }
    }
}
int hashmap_get(HashMap *map, char *key) {
    HashEntry *entry = hashmap_get_entry(map, key);
    if (!entry) return -1;
    return entry->value;
}
void hashmap_free(HashMap map) {
    free(map.items);
    free(map.indices);
}

typedef struct {
    size_t depth;
    char *str;
} QueueItem;
typedef struct {
    QueueItem *items;
    size_t front;
    size_t len;
    size_t cap;
} Queue;
QueueItem queue_pop_front(Queue *q) {
    QueueItem ret = q->items[q->front];
    q->front = (q->front + 1) % q->cap;
    q->len--;
    return ret;
}
void queue_push_back(Queue *q, QueueItem item) {
    if (q->len >= q->cap) {
        size_t new_cap = q->cap ? q->cap * 2 : 128;
        QueueItem *new_items = malloc(new_cap * sizeof(*q->items));
        memcpy(&new_items[0], &q->items[q->front], (q->cap - q->front) * sizeof(*q->items));
        memcpy(&new_items[q->cap - q->front], &q->items[0], q->front * sizeof(*q->items));
        free(q->items);
        q->front = 0;
        q->items = new_items;
        q->cap = new_cap;
    }
    q->items[(q->front + q->len++) % q->cap] = item;
}
void queue_free(Queue q) {
    for (size_t i = 0; i < q.len; i++) {
        free(q.items[(q.front+i) % q.cap].str);
    }
    free(q.items);
}

int apply_until_found_recurse(char *start, char *end, const Replacements *reps, HashMap *cache) {
    HashEntry *entry = hashmap_get_entry(cache, start);
    if (entry != NULL) return entry->value;

    if (strcmp(start, end) == 0) return 0;
    if (strlen(start) > strlen(end)) return INT_MAX;

    Strings strs = {0};
    for (size_t i = 0; i < reps->len; i++) {
        apply_all_replacements(&strs, reps->items[i],
                (s_view){.str = start, .len = strlen(start)});
    }

    int min = INT_MAX;
    for (size_t i = 0; i < strs.len; i++) {
        int child_depth = apply_until_found_recurse(strs.items[i], end, reps, cache);
        if (child_depth < min) min = child_depth;
    }
    if (min != INT_MAX) min = min + 1;

    // for (size_t i = 0; i < strs.len; i++) free(strs.items[i]);
    // free(strs.items);

    hashmap_insert(cache, start, min);
    return min;
}

int apply_until_found(const Replacements *reps, s_view final, s_view start) {
    HashMap cache = {0};
    Queue queue = {0};
    QueueItem start_item = {
        .depth = 0,
        .str = strndup(start.str, start.len),
    };

    queue_push_back(&queue, start_item);
    while (queue.len > 0) {
        Strings strs = {0};
        QueueItem cur_item = queue_pop_front(&queue);
        size_t cur_depth = cur_item.depth;
        char *cur_str = cur_item.str;

        if (strncmp(cur_str, final.str, final.len) == 0) {
            queue_free(queue);
            free(cur_str);
            return cur_depth;
        }

        for (size_t i = 0; i < reps->len; i++) {
            apply_all_replacements(&strs, reps->items[i], (s_view){.str = cur_str, .len = strlen(cur_str)});
        }
        for (size_t i = 0; i < strs.len; i++) {
            HashEntry *entry = hashmap_get_entry(&cache, strs.items[i]);
            if (!entry) {
                printf("%s\n", strs.items[i]);
                hashmap_insert(&cache, strdup(strs.items[i]), cur_depth + 1);
            } else {
                free(strs.items[i]);
                continue;
            }

            queue_push_back(&queue, (QueueItem){.str = strs.items[i], .depth = cur_depth + 1});
        }
        free(cur_str);
        free(strs.items);
    }
    queue_free(queue);
    return -1;
}

void day19(const char *data, char **part1, char **part2) {
    Replacements reps = {0};
    s_view medicine_molecule = {0};
    { // parsing
        const char *final = data;
        for (const char *cur = data; *cur != 0; cur++) {
            if (*cur == '\n') { // break at double new_line
                final = cur + 1;
                break;
            }

            const char *start = cur;
            while (*cur != ' ') cur++;
            s_view initial = {
                .str = start,
                .len = cur - start,
            };

            cur++;
            while (*cur != ' ') cur++;
            cur++;

            start = cur;
            while (*cur != '\n') cur++;
            s_view replacement = {
                .str = start,
                .len = cur - start,
            };

            Replacement rep = {
                .initial = initial,
                .replacement = replacement,
            };

            append(&reps, rep);
        }

        const char *str = final;
        while (*final != '\n') final++;
        medicine_molecule = (s_view){
            .str = str,
            .len = final - str,
        };
    }

    // for (size_t i = 0; i < reps.len; i++) {
    //     s_view init = reps.items[i].initial;
    //     s_view repl = reps.items[i].replacement;
    //     printf("%.*s => %.*s\n", (int)init.len, init.str, (int)repl.len, repl.str);
    // }
    // printf("%.*s\n", (int)medicine_molecule.len, medicine_molecule.str);

    // part1
    Strings all_unique = {0};
    for (size_t i = 0; i < reps.len; i++) {
        apply_all_replacements(&all_unique, reps.items[i], medicine_molecule);
    }
    int num_distinct = all_unique.len;
    for (size_t i = 0; i < all_unique.len; i++) free(all_unique.items[i]);
    free(all_unique.items);

    // part2

    // int min_steps = apply_until_found(&reps, medicine_molecule, (s_view){.str = "e", .len = 1});
    HashMap cache = {0};
    int min_steps = apply_until_found_recurse(
        "e", 
        strndup(medicine_molecule.str, medicine_molecule.len),
        &reps,
        &cache);
    if (min_steps == -1) assert(0 && "Failed");

    sprintf((*part1 = malloc(64)), "%d", num_distinct);
    sprintf((*part2 = malloc(64)), "%d", min_steps);
    free(reps.items);
}
