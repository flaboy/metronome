#include "erl_nif.h"
#include "metronome.h"
#include <string.h>
#include <stdio.h>

char keybuff[KEY_MAX_LEN];
int hash_n(char * key){
    int i, hash=0;
    for(i=0;i<KEY_MAX_LEN;i++){
        if(key[i] == 0) break;
        hash = key[i] + (hash << 5);
    }
    return hash % BUCKET_SIZE;
}

metronome_item * new_item(char * key){
    metronome_item * item = enif_alloc(sizeof(metronome_item));
    bzero(item, sizeof(metronome_item));
    strcpy(item->key, key);
    return item;
}

metronome_item * walk_hash(metronome_item * start, int timestamp, char * key, int * result){
    metronome_item * item = start, *prev=start;
    while(item){
        if(key!=NULL && 0 == strcmp(item->key,key) ){
            *result = 1;
            return item;
        }
        
        //如果过期，删除！
        if( item->timestamp + item->ttl > timestamp ){
            prev = item;
        }else{
            prev->next = item->next;
            enif_free(item);
        }
        item = item->next;
    }
    
    *result = 0;
    return prev;
}

struct metronome_item * find_in_hash(char * key, int timestamp){
    int hash = hash_n(key);
    
    if(hashmap[hash]==0){
        hashmap[hash] = new_item(key);
        return hashmap[hash];
    }
    
    int succ = 0;
    metronome_item * item = walk_hash(hashmap[hash], timestamp, key, &succ);
    if(succ==1){
        return item;
    }else{
        item->next = new_item(key);
        return item->next;
    }
}

//key, incr, ttl, timestamp
static ERL_NIF_TERM update(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    
    int ttl=0, timestamp=0, incr=0;
    CHECK(enif_get_string(env, argv[0], keybuff, KEY_MAX_LEN, ERL_NIF_LATIN1)); 
    CHECK(enif_get_int(env, argv[1], &incr));
    CHECK(enif_get_int(env, argv[2], &ttl));
    CHECK(enif_get_int(env, argv[3], &timestamp));
    
    metronome_item * item = find_in_hash(keybuff, timestamp);
    item->ttl = ttl;
    
    if(item->timestamp + ttl > timestamp){
        item->value += incr;
    }else{
        item->value = 1;
        item->timestamp = timestamp;
    }

    //enif_fprintf(stderr, "point:: addr:%d, value:%d, time:%d\r\n", p, p->value, p->timestamp );
    return enif_make_int(env, item->value);
}

static ERL_NIF_TERM gc(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    int i=0 , rt=0 , timestamp = 0;
    CHECK(enif_get_int(env, argv[0], &timestamp));
    for(i=0;i<BUCKET_SIZE;i++){
        if(hashmap[i]>0){
            walk_hash(hashmap[i],timestamp,NULL,&rt);
        }
    }
    return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] = {
    {"update", 4, update},
    {"gc", 1, gc}
};

ERL_NIF_INIT(metronome_db, nif_funcs, NULL, NULL, NULL, NULL)
