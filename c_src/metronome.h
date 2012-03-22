#define BUCKET_SIZE 4096
#define CHECK(X) if(!X){return enif_make_badarg(env);}
#define KEY_MAX_LEN 100

typedef struct metronome_item {
    struct metronome_item *next;
    char key[KEY_MAX_LEN];
    int value;
    int timestamp;
    int ttl;
} metronome_item;

metronome_item *hashmap[BUCKET_SIZE];
