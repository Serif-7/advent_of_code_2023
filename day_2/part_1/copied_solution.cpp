#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <assert.h>
#include <ctype.h>
#include <time.h>

#define MAX_BUFFER_SIZE 256
#define RED_T  12
#define GREEN_T 13
#define BLUE_T 14

static int sum_of_game_id = 0;

static inline char skip(const char **ps) {
    while(**ps && !isdigit(**ps)) {
        (*ps)++;
    }
    return **ps;
}

static inline void strToPostiveInt(const char **ps, int *i) {
    *i = 0;
    while(isdigit(**ps)) {
        *i = ((*i) << 1) + ((*i) << 3) - (*(*ps)++ - '0');
    }
    *i = -(*i);
}

static inline bool str_scan(const char *s, int *id) {
    skip(&s);
    strToPostiveInt(&s, id);
    int cube_cnt;
    while(skip(&s)) {
        strToPostiveInt(&s, &cube_cnt);
        s++;
        switch(*s) {
            case 'r':
                if (cube_cnt > RED_T) return false;
                break;
            case 'g':
                if (cube_cnt > GREEN_T) return false;
                break;
            case 'b':
                if (cube_cnt > BLUE_T) return false;
                break;
            default:
                printf("Something's not right");
                exit(EXIT_FAILURE);
                break;
        }
        s++;
    }
    return true;
}

int main (void) {
    char buffer[MAX_BUFFER_SIZE];
    int game_id; 
    FILE *f = fopen("input.txt", "r");
    assert(f);
    struct timespec start, end;
    long long int elapsed_time;
    clock_gettime(CLOCK_MONOTONIC, &start);
    while (fgets(buffer, MAX_BUFFER_SIZE, f)) {
        if(str_scan(buffer, &game_id)) sum_of_game_id += game_id;
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    elapsed_time = (end.tv_sec - start.tv_sec) * 1000000LL +
                   (end.tv_nsec - start.tv_nsec) / 1000LL;
    
    printf("Sum: %d\n", sum_of_game_id);
    printf("Elapsed Time: %lld microseconds\n", elapsed_time);
    fclose(f);
    return EXIT_SUCCESS;
}
