#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <curl/curl.h>

#include "days.h"

int (*days[25])(char*, char*, char*) = {
    day01, day02, day03, day04, day05,
    day06, day07, day08, day09, day10,
    day11, day12, day13, day14, day15,
    day16, day17, day18, day19, day20,
    day21, day22, day23, day24, day25,
};
char buf[1024]; // global buffer for various IO

int parse_args(int argc, char **argv, char *datapath);
char *read_data(const char *datapath);
int download_aoc_input(int day, char *datapath);

int main(int argc, char **argv) {
    char datapath[32];
    int day = parse_args(argc, argv, datapath);
    if (day == 0) return 1;

    if (access("res/", F_OK) != 0) system("mkdir res");
    if (access(datapath, F_OK) != 0) {
        printf("fetching puzzle data\n");
        int res = download_aoc_input(day, datapath);
        if (res != 0) printf("Failed to fetch puzzle data\n");
    }

    char *data = read_data(datapath);
    if (!data) return 2;

    printf("---------------<< Day %02d >>---------------\n", day);
    char *part1 = NULL, *part2 = NULL;
    days[day-1](data, part1, part2);

    if (!part1 && !part2) printf("Day is unimplemented\n");
    if (part1) printf("Part 1: %s\n", part1);
    if (part2) printf("Part 2: %s\n", part2);
    return 0;
}

int parse_args(int argc, char **argv, char *datapath) {
    if (argc <= 1) {
        printf("Day argument was not provided\n");
        return 0;
    }

    int day = atoi(argv[1]);
    if (day < 1 || day > 25) {
        printf("Day %02d is invalid", day);
        return 0;
    }

    if (argc == 3 && *argv[2] == 'p') {
        sprintf(datapath, "res/example.txt");
    } else {
        sprintf(datapath, "res/day%02d.txt", day);
    }

    return day;
}

char *read_data(const char *datapath) {
    FILE* datafile = fopen(datapath, "r");
    if (!datafile) {
        perror("fopen");
        return NULL;
    }

    char *data = NULL;
    size_t cap = 0;
    ssize_t nread = getdelim(&data, &cap, '\0', datafile);
    if (nread == -1) {
        perror("getdelim");
    } else if (fread(buf, 1, 1, datafile) != 0) {
        printf("Failed to read all of input data in %s", datapath);
    }

    fclose(datafile);
    return data;
}

int download_aoc_input(int day, char* datapath) {
    char url[64];
    sprintf(url, "https://adventofcode.com/2015/day/%d/input", day);

    char cookie_header[256];
    {
        FILE* cookie_file = fopen("../.aoc-cookie", "r");
        if (!cookie_file) { perror("fopen"); return 1; }
        fgets(buf, 1024, cookie_file);
        fclose(cookie_file);
        int len = strlen(buf);
        if (buf[len-1] == '\n') buf[len-1] = '\0';
        sprintf(cookie_header, "cookie: session=%s", buf);
    }

    CURL *curl = curl_easy_init();
    CURLcode res;
    if (curl) {
        FILE *fp = fopen(datapath, "w");

        struct curl_slist *headers = NULL;
        headers = curl_slist_append(headers, "Content-Type: text/plain");
        headers = curl_slist_append(headers, cookie_header);

        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, fwrite);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

        res = curl_easy_perform(curl);

        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
        fclose(fp);
    }
    if (res != CURLE_OK) {
        printf("Failed to download input\n");
        return 1;
    }

    return 0;
}
