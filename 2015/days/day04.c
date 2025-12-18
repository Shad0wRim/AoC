#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void md5hash(const char *val, char *outhash) {
    char message[64] = {0}; strncpy(message, val, 63);
    unsigned long len = strlen(message); 
    if (len >= 32) return; // message is too big
    message[len] = (char)0x80;
    message[56] = (char)len*8;

    unsigned int s[64] = {
        7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
        5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
        4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
        6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,
    };
    unsigned int K[64] = {
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
    };
    unsigned int a0 = 0x67452301;
    unsigned int b0 = 0xefcdab89;
    unsigned int c0 = 0x98badcfe;
    unsigned int d0 = 0x10325476;
    unsigned int A = a0;
    unsigned int B = b0;
    unsigned int C = c0;
    unsigned int D = d0;
    unsigned int *M = (unsigned int*)message;

    for (unsigned int i = 0; i < 64; i++) {
        unsigned int F, g;
        if (i < 16) {
            F = (B & C) | (~B & D);
            g = i;
        } else if (i < 32) {
            F = (D & B) | (~D & C);
            g = (5*i + 1) % 16;
        } else if (i < 48) {
            F = B ^ C ^ D;
            g = (3*i + 5) % 16;
        } else {
            F = C ^ (B | ~D);
            g = (7*i) % 16;
        }

        F += A + K[i] + M[g];
        A = D;
        D = C;
        C = B;
        B += (F << s[i]) | (F >> (32 - s[i]));
    }

    a0 += A;
    b0 += B;
    c0 += C;
    d0 += D;
    unsigned int *outhash_convert = (unsigned int*)outhash;
    outhash_convert[0] = a0;
    outhash_convert[1] = b0;
    outhash_convert[2] = c0;
    outhash_convert[3] = d0;
}

void hashtostr(const char *hash, char *hashstr) {
    for (int i = 0; i < 16; i++) {
        sprintf(hashstr, "%02hhx", hash[i]);
        hashstr += 2;
    }
}

void day04(const char *data, char **part1, char **part2) {
    int len = strlen(data);

    int five_zeros = 0, six_zeros = 0;
    for (int i = 0; i < (1 << 24); i++) {
        char input[64] = {0};
        char outhash[16] = {0};
        char hashstr[33] = {0};
        sprintf(input, "%.*s%d", len-1, data, i);
        md5hash(input, outhash);
        hashtostr(outhash, hashstr);

        // part1
        if (five_zeros == 0 && strncmp(hashstr, "00000", 5) == 0) five_zeros = i;

        // part2
        if (six_zeros == 0 && strncmp(hashstr, "000000", 6) == 0) six_zeros = i;

        if (five_zeros && six_zeros) break;
    }

    sprintf((*part1 = malloc(64)), "%d", five_zeros);
    sprintf((*part2 = malloc(64)), "%d", six_zeros);
}
