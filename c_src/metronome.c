#include "erl_nif.h"
#include "metronome.h"
#include <string.h>
#include <stdio.h>

char keybuff[KEY_MAX_LEN];
int hash_n(const char * key){
    unsigned int hash=0;
    const char *p;
    for(p=key;*p;p++){
        hash = hash * 33 + *p;
    }
    return hash % BUCKET_SIZE;
}

metronome_item * new_item(char * key){
    metronome_item * item = enif_alloc(sizeof(metronome_item));
    bzero(item, sizeof(metronome_item));
    strcpy(item->key, key);
    //enif_fprintf(stderr, "new:: %s=%d\n", key, item );
    return item;
}

metronome_item * walk_hash(metronome_item ** start, int timestamp, char * key, int force_delete){
    metronome_item *item = *start, **prev=start, *next;
    
    while(item){
        if(key!=NULL && 0 == strcmp(item->key,key) ){
            return item;
        }
        
        //如果过期，删除！
        next = item->next;
        if(force_delete!=1 && item->timestamp + item->ttl > timestamp ){
            prev = &item->next;
        }else{
            *prev = next;
            enif_free(item);
            //enif_fprintf(stderr, "freed:: %d\n", item);
        }
        item = next;
    }
    
    if(key==NULL){
        return *start;
    }else{
        *prev = new_item(key);
        return *prev;    
    }
}

struct metronome_item * find_in_hash(char * key, int timestamp){
    int hash = hash_n(key);
    
    if(hashmap[hash]==0){
        hashmap[hash] = new_item(key);
        return hashmap[hash];
    }
    
    return walk_hash(&hashmap[hash], timestamp, key, 0);
}

//key, incr, ttl, timestamp
static ERL_NIF_TERM update(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    
    int ttl=0, timestamp=0, incr=0, next=0;
    CHECK(enif_get_string(env, argv[0], keybuff, KEY_MAX_LEN, ERL_NIF_LATIN1)); 
    CHECK(enif_get_int(env, argv[1], &incr));
    CHECK(enif_get_int(env, argv[2], &ttl));
    CHECK(enif_get_int(env, argv[3], &timestamp));
    
    metronome_item * item = find_in_hash(keybuff, timestamp);
    item->ttl = ttl;
    
    if(item->timestamp + ttl > timestamp){
        item->value += incr;
        next = item->timestamp + ttl - timestamp;
    }else{
        item->value = incr;
        item->timestamp = timestamp;
        next = ttl;
    }

    //
    return enif_make_tuple3(env,
        enif_make_atom(env, "ok"),
        enif_make_int(env, item->value),
        enif_make_int(env, next)
        );
}

static ERL_NIF_TERM lookup(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    
    int timestamp=0, next=0, value=0;
    CHECK(enif_get_string(env, argv[0], keybuff, KEY_MAX_LEN, ERL_NIF_LATIN1)); 
    CHECK(enif_get_int(env, argv[1], &timestamp));
    
    metronome_item * item = find_in_hash(keybuff, timestamp);
    
    if(item->timestamp + item->ttl > timestamp){
        next = item->timestamp + item->ttl - timestamp;
        value = item->value;
    }else{
        next = item->ttl;
        value = 0;
    }

    //
    return enif_make_tuple3(env,
        enif_make_atom(env, "ok"),
        enif_make_int(env, value),
        enif_make_int(env, next)
        );
}

static ERL_NIF_TERM gc(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    int i=0 , timestamp = 0;
    CHECK(enif_get_int(env, argv[0], &timestamp));
    for(i=0;i<BUCKET_SIZE;i++){
        if(hashmap[i]>0){
            walk_hash(&hashmap[i],timestamp,NULL, 0);
        }
    }
    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM clear(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    int i=0;
    for(i=0;i<BUCKET_SIZE;i++){
        if(hashmap[i]>0){
            walk_hash(&hashmap[i],0,NULL, 1);
        }
    }
    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM is_loaded(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    return enif_make_atom(env, "true");
}

static ErlNifFunc nif_funcs[] = {
    {"update", 4, update},
    {"lookup", 2, lookup},
    {"gc", 1, gc},
    {"clear", 0, clear},
    {"is_loaded", 0, is_loaded}
};

ERL_NIF_INIT(metronome_db, nif_funcs, NULL, NULL, NULL, NULL)
