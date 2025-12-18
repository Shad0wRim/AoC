#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
    INVALID,
    AND,
    OR,
    NOT,
    LSHIFT,
    RSHIFT,
    SIGNAL,
} Action;

typedef struct {
    char name[2];
    unsigned short val;
} Wire;
typedef struct {
    Wire items[676];
    size_t len;
} Wires;

typedef struct {
        char *inputs[3];
        char *output;
        int ninputs;
} Connection;
typedef struct {
    Connection items[340];
    size_t len;
} Connections;

Action get_action(char *inputs[], int ninputs) {
    Action action = INVALID;
    switch (ninputs) {
        case 1: action = SIGNAL; break;
        case 2: action = NOT;    break;
        case 3:
            if (strcmp(inputs[1], "AND") == 0) {
                action = AND;
            } else if (strcmp(inputs[1], "OR")     == 0) {
                action = OR;
            } else if (strcmp(inputs[1], "LSHIFT") == 0) {
                action = LSHIFT;
            } else if (strcmp(inputs[1], "RSHIFT") == 0) {
                action = RSHIFT;
            }
            break;
    }
    return action;
}

void add_connection(Connections *conn, char *inputs[], int ninputs, char *output) {
    conn->items[conn->len++] = (Connection){ 
        .inputs = {inputs[0], inputs[1], inputs[2]},
        .output = output,
        .ninputs = ninputs,
    };
}
Connection *get_connection(Connections *conn, char wire[]) {
    for (size_t i = 0; i < conn->len; i++) {
        // printf("%s =?= %s\n", conn->items[i].output, wire);
        if (strcmp(wire, conn->items[i].output) == 0) {
            return &conn->items[i];
        }
    }
    return NULL;
}

Wire *get_wire(Wires *wires, char wire[]) {
    for (size_t i = 0; i < wires->len; i++) {
        if (wire[0] == wires->items[i].name[0] && wire[1] == wires->items[i].name[1]) {
            return &wires->items[i];
        }
    }
    return NULL;
}
unsigned short get_wire_val(Wires *wires, char wire[]) {
    Wire *i_wire = get_wire(wires, wire);
    return i_wire ? i_wire->val : 0;
}
void set_wire(Wires *wires, char wire[], unsigned short val) {
    Wire *i_wire = get_wire(wires, wire);
    if (i_wire) {
        i_wire->val = val;
    } else {
        wires->items[wires->len++] = (Wire){ .name = {wire[0], wire[1]}, .val = val };
    }
}
bool is_wire(char *str) {
    return !isdigit(*str);
}
unsigned short value(Wires *wires, char *str) {
    return is_wire(str) ? get_wire_val(wires, str) : atoi(str);
}
void connect_wire(Wires *wires, char *inputs[], char *output, Action action) {
    switch (action) {
        case SIGNAL:
            set_wire(wires, output, value(wires, inputs[0]));
            break;
        case NOT:
            set_wire(wires, output, ~value(wires, inputs[1]));
            break;
        case AND: {
            unsigned short a, b;
            a = value(wires, inputs[0]);
            b = value(wires, inputs[2]);
            set_wire(wires, output, a & b);
        } break;
        case OR: {
            unsigned short a, b;
            a = value(wires, inputs[0]);
            b = value(wires, inputs[2]);
            set_wire(wires, output, a | b);
        } break;
        case LSHIFT: {
            unsigned short a, b;
            a = value(wires, inputs[0]);
            b = value(wires, inputs[2]);
            set_wire(wires, output, a << b);
        } break;
        case RSHIFT: {
            unsigned short a, b;
            a = value(wires, inputs[0]);
            b = value(wires, inputs[2]);
            set_wire(wires, output, a >> b);
        } break;
        case INVALID: break;
    }
}
void connect_all(Connections *conns, Wires *wires, char wire[]) {
    Connection *conn = get_connection(conns, wire);
    if (!conn) return;

    char **inputs = conn->inputs;
    char *output = conn->output;
    Action action = get_action(conn->inputs, conn->ninputs);
    switch (action) {
        case SIGNAL:
            if (is_wire(inputs[0]) && !get_wire(wires, inputs[0])) connect_all(conns, wires, inputs[0]);
            break;
        case NOT:
            if (is_wire(inputs[1]) && !get_wire(wires, inputs[1])) connect_all(conns, wires, inputs[1]);
            break;
        case AND: 
        case OR: 
        case LSHIFT: 
        case RSHIFT: 
            if (is_wire(inputs[0]) && !get_wire(wires, inputs[0])) connect_all(conns, wires, inputs[0]);
            if (is_wire(inputs[2]) && !get_wire(wires, inputs[2])) connect_all(conns, wires, inputs[2]);
            break;
        case INVALID: break;
    }
    connect_wire(wires, inputs, output, action);
}

void day07(const char *data, char **part1, char **part2) {
    char *target = "a";

    char *data_ = strdup(data);
    Connections conns = {0};
    char *inputs[3];
    int ninputs;

    char *line, *lines, *word, *save_line, *save_word;
    for (lines = data_; (line = strtok_r(lines, "\n", &save_line)); lines = NULL) {
        ninputs = 0;
        // parsing
        word = strtok_r(line, " ", &save_word);
        while (word) {
            if (strcmp(word, "->") == 0) break;
            inputs[ninputs++] = word;
            word = strtok_r(NULL, " ", &save_word);
        }
        char *output = strtok_r(NULL, " ", &save_word);

        add_connection(&conns, inputs, ninputs, output);
    }

    // part1
    Wires wires = {0};
    connect_all(&conns, &wires, target);
    int value1 = get_wire_val(&wires, target);
    sprintf((*part1 = malloc(64)), "%d", value1);

    // part2
    wires = (Wires){0};
    get_connection(&conns, "b")->inputs[0] = *part1;
    connect_all(&conns, &wires, target);
    int value2 = get_wire_val(&wires, target);
    sprintf((*part2 = malloc(64)), "%d", value2);

    free(data_);
}

// debug functions, forward declare these to use them
void dump_wires(const Wires *wires) {
    for (size_t i = 0; i < wires->len; i++) {
        printf("%c%c: %d\n", wires->items[i].name[0], wires->items[i].name[1], wires->items[i].val);
    }
    if (wires->len == 0) printf("...\n");
}
void dump_conn(Connection *conn) {
    if (!conn) return;
    switch (conn->ninputs) {
        case 3: printf("%s ", conn->inputs[conn->ninputs - 3]); __attribute__ ((fallthrough));
        case 2: printf("%s ", conn->inputs[conn->ninputs - 2]); __attribute__ ((fallthrough));
        case 1: printf("%s ", conn->inputs[conn->ninputs - 1]); __attribute__ ((fallthrough));
        default: break;
    }
    printf("-> %s\n", conn->output);
}
void dump_conns(Connections *conns) {
    for (size_t i = 0; i < conns->len; i++) dump_conn(&conns->items[i]);
}
