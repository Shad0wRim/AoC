#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

typedef struct {
    int cost;
    int damage;
    int armor;
} Item;

typedef struct {
    int hp;
    int damage;
    int armor;
} Stats;
typedef struct {
    int cost;
    bool win;
} FightOutcome;

Item weapons[] = {
    { .cost = 8,  .damage = 4 },
    { .cost = 10, .damage = 5 },
    { .cost = 25, .damage = 6 },
    { .cost = 40, .damage = 7 },
    { .cost = 74, .damage = 8 },
};
Item armors[] = {
    { .cost = 13,  .armor = 1 },
    { .cost = 31,  .armor = 2 },
    { .cost = 53,  .armor = 3 },
    { .cost = 75,  .armor = 4 },
    { .cost = 102, .armor = 5 },
};
Item rings[] = {
    { .cost = 25,  .damage = 1 },
    { .cost = 50,  .damage = 2 },
    { .cost = 100, .damage = 3 },
    { .cost = 20,  .armor  = 1 },
    { .cost = 40,  .armor  = 2 },
    { .cost = 80,  .armor  = 3 },
};

int min_cost_weapon(Stats boss);
int min_cost_armor(Stats boss, int w);
int min_cost_ring1(Stats boss, int w, int a);
int min_cost_ring2(Stats boss, int w, int a, int r1);
int max_cost_weapon(Stats boss);
int max_cost_armor(Stats boss, int w);
int max_cost_ring1(Stats boss, int w, int a);
int max_cost_ring2(Stats boss, int w, int a, int r1);

bool fight_boss(Stats player, Stats boss) {
    int player_hit = player.damage - boss.armor;
    player_hit = player_hit > 0 ? player_hit : 0;
    int boss_hit = boss.damage - player.armor;
    boss_hit = boss_hit > 0 ? boss_hit : 0;
    while (true) {
        boss.hp -= player_hit;
        if (boss.hp <= 0) break;

        player.hp -= boss_hit;
        if (player.hp <= 0) break;
    }
    return player.hp > 0;
}
FightOutcome calculate_cost(Stats boss, int w, int a, int r1, int r2) {
    int damage = weapons[w].damage;
    damage += r1 != -1 ? rings[r1].damage : 0;
    damage += r2 != -1 ? rings[r2].damage : 0;
    int armor = a  != -1 ? armors[a].armor  : 0;
    armor += r1 != -1 ? rings[r1].armor : 0;
    armor += r2 != -1 ? rings[r2].armor : 0;
    int cost = weapons[w].cost;
    cost += a  != -1 ? armors[a].cost  : 0;
    cost += r1 != -1 ? rings[r1].cost : 0;
    cost += r2 != -1 ? rings[r2].cost : 0;
    Stats player = {
       .hp = 100,
       .damage = damage,
       .armor = armor,
    };
    return (FightOutcome){
        .cost = cost,
        .win = fight_boss(player, boss)
    };
}

int min_cost_weapon(Stats boss) {
    int min_cost = INT_MAX;
    for (int w = 0; w < (int)(sizeof(weapons)/sizeof(*weapons)); w++) {
        int this_cost = min_cost_armor(boss, w);
        min_cost = this_cost < min_cost ? this_cost : min_cost;
    }
    return min_cost;
}
int min_cost_armor(Stats boss, int w) {
    int min_cost = INT_MAX;
    for (int a = -1; a < (int)(sizeof(armors)/sizeof(*armors)); a++) {
        int this_cost = min_cost_ring1(boss, w, a);
        min_cost = this_cost < min_cost ? this_cost : min_cost;
    }
    return min_cost;
}
int min_cost_ring1(Stats boss, int w, int a) {
    int min_cost = INT_MAX;
    for (int r1 = -1; r1 < (int)(sizeof(rings)/sizeof(*rings)); r1++) {
        int this_cost = min_cost_ring2(boss, w, a, r1);
        min_cost = this_cost < min_cost ? this_cost : min_cost;
    }
    return min_cost;
}
int min_cost_ring2(Stats boss, int w, int a, int r1) {
    int min_cost = INT_MAX;
    for (int r2 = -1; r2 < (int)(sizeof(rings)/sizeof(*rings)); r2++) {
        if ((r1 == -1 && r2 != -1) || (r1 != -1 && r2 == r1)) continue;
        FightOutcome outcome = calculate_cost(boss, w, a, r1, r2);
        if (outcome.win && outcome.cost < min_cost) {
            min_cost = outcome.cost;
        }
    }
    return min_cost;
}

int max_cost_weapon(Stats boss) {
    int max_cost = 0;
    for (int w = 0; w < (int)(sizeof(weapons)/sizeof(*weapons)); w++) {
        int this_cost = max_cost_armor(boss, w);
        max_cost = this_cost > max_cost ? this_cost : max_cost;
    }
    return max_cost;
}
int max_cost_armor(Stats boss, int w) {
    int max_cost = 0;
    for (int a = -1; a < (int)(sizeof(armors)/sizeof(*armors)); a++) {
        int this_cost = max_cost_ring1(boss, w, a);
        max_cost = this_cost > max_cost ? this_cost : max_cost;
    }
    return max_cost;
}
int max_cost_ring1(Stats boss, int w, int a) {
    int max_cost = 0;
    for (int r1 = -1; r1 < (int)(sizeof(rings)/sizeof(*rings)); r1++) {
        int this_cost = max_cost_ring2(boss, w, a, r1);
        max_cost = this_cost > max_cost ? this_cost : max_cost;
    }
    return max_cost;
}
int max_cost_ring2(Stats boss, int w, int a, int r1) {
    int max_cost = 0;
    for (int r2 = -1; r2 < (int)(sizeof(rings)/sizeof(*rings)); r2++) {
        if ((r1 == -1 && r2 != -1) || (r1 != -1 && r2 == r1)) continue;
        FightOutcome outcome = calculate_cost(boss, w, a, r1, r2);
        if (!outcome.win && outcome.cost > max_cost) {
            max_cost = outcome.cost;
        }
    }
    return max_cost;
}


void day21(const char *data, char **part1, char **part2) {
    Stats boss = {0};
    sscanf(data, "Hit Points: %d\nDamage: %d\nArmor: %d",
           &boss.hp, &boss.damage, &boss.armor);

    int min_cost = min_cost_weapon(boss); // part1
    int max_cost = max_cost_weapon(boss); // part2
    
    sprintf((*part1 = malloc(64)), "%d", min_cost);
    sprintf((*part2 = malloc(64)), "%d", max_cost);
}
