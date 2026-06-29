#include <stdio.h>
#include <stdlib.h>

int sum_of_divisors(int num) {
    int sum = 0;
    for (int i = 1; i * i <= num; i++) {
        int mod = num % i;
        int div = num / i;
        if (mod == 0) sum += i + (div != i) * div;
    }
    return sum;
}

int lazy_sum(int num) {
    int sum = 0;
    for (int i = 1; i * i <= num; i++) {
        int mod = num % i;
        int div = num / i;
        if (mod == 0) {
            sum += i   * (i   * 50 >= num);
            sum += div * (div * 50 >= num);
        }
    }
    return sum;
    
}

void day20(const char *data, char **part1, char **part2) {
    int data_num = atoi(data);

    // part1
    int present_num = data_num / 10;
    int inf_house_num = 0;
    for (inf_house_num = 1; inf_house_num < 1000000; inf_house_num++) {
        int sum = sum_of_divisors(inf_house_num);
        if (sum >= present_num) break;
    }

    // part2
    int fin_house_num = 0;
    for (fin_house_num = 1; fin_house_num < 1000000; fin_house_num++) {
        int sum = lazy_sum(fin_house_num);
        if (sum * 11 >= data_num) break;
    }
    

    sprintf((*part1 = malloc(64)), "%d", inf_house_num);
    sprintf((*part2 = malloc(64)), "%d", fin_house_num);

}
