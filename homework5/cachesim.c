#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>

void stringCopy(unsigned char* dest, unsigned char* src, int size) {
    for (int i = 0; i < size; i++) {
        dest[i] = src[i];
    }
}

int powerTwo(int n) {
    return (1 << n);
}

int ones(int n) {
    return (powerTwo(n) - 1);
}

int lowerBits(int x, int n) {
    int mask = ones(n);
    return (x & mask);
}

int replaceUpper(int x, int y, int n) {
    x = x << y;
    x = x | n;
    return x;
}

int logBaseTwo(int n) {
    int i = 0;
    while(n >>= 1) i++;
    return i;
}

int addressSize = 24;

int cacheSize;
int associativity;
int blockSize;
int frames;
int setCount;

int offsetBits;
int indexBits;
int tagBits;

// Create struct for storing tag/index pairs
typedef struct tagIndexPair{
    int tag;
    int index;
    unsigned char *dataStr;
} SetItem; 


// Create 16MB array for memory stores and loads
unsigned char memory[16777216];


int main(int argc, char* argv[]) {

    // Initialize memory to 0
    for(int i = 0; i < 16777216; i++) {
        memory[i] = 0;
    }

    // Read in file and set arguments to variables
    FILE *file = fopen(argv[1],"r");
    int cacheSize = atoi(argv[2]) * 1024;
    int associativity = atoi(argv[3]);
    int blockSize = atoi(argv[4]);

    // Calculate the number of frames and setCount in the cache
    frames = cacheSize / blockSize;
    setCount = frames / associativity;

    // Calculate the cache parameters for address mapping
    offsetBits = logBaseTwo(blockSize);
    indexBits = logBaseTwo(setCount);
    tagBits = addressSize - offsetBits - indexBits;

    // Create strings for store and load comparisons
    char store[64] = "store";
    char load[64] = "load";
    char action[64];

    // Create address, access size, and store data variables
    int addressInput;
    int accessSize;
    int tempData;

    int loadWay;
    int hitWay;

    // Create boolean for whether it was a hit or a miss
    bool hit;

    // Create array of structs for each instruction to hold index, set, data
    struct tagIndexPair cache [setCount][associativity];

    // Initialize cache values
    for(int i = 0; i < associativity; i++) {
        for(int j = 0; j < setCount; j++){
            cache[j][i].tag = -1;
            // cache[j][i].recent = -1;
            cache[j][i].dataStr = (unsigned char*) malloc(blockSize);
        }
    }

    // Read each line from the trace file
    while(fscanf(file, "%s", action) != EOF) {

        hit = false;


        fscanf(file, "%x", &addressInput);
        fscanf(file, "%d", &accessSize);

        // Calculate the block, index, and tag of the current store address
        int offsetVal = lowerBits(addressInput, offsetBits);
        int indexVal = lowerBits(addressInput>>offsetBits, indexBits);
        int tagVal = addressInput>>indexBits>>offsetBits;


        // Check whether or not the access is a hit
        for(int i = 0; i < associativity; i++) {
            hit = (cache[indexVal][i].tag == tagVal);
            if(hit){
                hitWay = i;
                break;
            }   
        }

        // Current line is a store instruction
        if(strcmp(store, action) == 0) {

            // Write data to memory
            for(int i = 0; i < accessSize; i++){
                fscanf(file, "%02hhx", &memory[addressInput + i]);
            }

            // Store hit
            if(hit) {


                int end = associativity - 2;

                // Move way to the right by one
                for(int i = 0; i < associativity - 1; i++) {
                    if(cache[indexVal][i].tag == tagVal) {
                        end = i-1;
                        break;
                    }
                }

                for(int i = end; i >= 0; i--) {
                    cache[indexVal][i + 1].tag = cache[indexVal][i].tag;
                }
                
                // Save newest data in way 0
                cache[indexVal][0].tag = tagVal;

                // Load the data stored in memory and bring to cache
                stringCopy((cache[indexVal][0].dataStr), &memory[addressInput], accessSize);

                printf("%s 0x%x hit\n", action, addressInput);
            }



            // Store miss
            else {

                printf("%s 0x%x miss\n", action, addressInput);
                

            }
        }



        // Current line is a load instruction
        else {


            // Load hit
            if(hit) {

                int end = associativity - 2;

                // Move way to the right by one
                for(int i = 0; i < associativity - 1; i++) {
                    if(cache[indexVal][i].tag == tagVal) {
                        end = i-1;
                        break;
                    }
                }

                for(int i = end; i >= 0; i--) {
                    cache[indexVal][i + 1].tag = cache[indexVal][i].tag;
                }

                // Save newest data in way 0
                cache[indexVal][0].tag = tagVal;

                // Load the data stored in memory and bring to cache
                stringCopy((cache[indexVal][0].dataStr), &memory[addressInput], accessSize);
                

                printf("%s 0x%x hit ", action, addressInput);
                
                // Print load value
                for(int i = 0; i < accessSize; i++){
                    printf("%02hhx", memory[addressInput + i]);
                }
                printf("\n");
            }



            // Load miss
            else {


                int end = associativity - 2;

                // Move way to the right by one
                for(int i = 0; i < associativity - 1; i++) {
                    if(cache[indexVal][i].tag == tagVal) {
                        end = i-1;
                        break;
                    }
                }

                for(int i = end; i >= 0; i--) {
                    cache[indexVal][i + 1].tag = cache[indexVal][i].tag;
                }

                // Save newest data in way 0
                cache[indexVal][0].tag = tagVal;

                // Load the data stored in memory and bring to cache
                stringCopy((cache[indexVal][0].dataStr), &memory[addressInput], accessSize);

                printf("%s 0x%x miss ", action, addressInput);

                for(int i = 0; i < accessSize; i++){
                    printf("%02hhx", memory[addressInput + i]);
                }
                printf("\n");
            }

        }

        
        // printf("Index: %d Tag: %d\n", indexVal, tagVal);
        // printf("\n");

        // printf("Memory at current address is: ");
        // for(int i = 0; i < 4; i++){

        //     printf("%02hhx", memory[addressInput + i]);
        // }
        // printf("\n");

        // printf("Cache[%d].data is: ", indexVal);
        // for(int i = 0; i < accessSize; i++){
        //     printf("%02hhx", cache[indexVal].dataStr[i]);
        // }
        // printf("\n");

    }

    fclose(file);

    // Free the malloc'd space
    for(int i = 0; i < associativity; i++) {
        for(int j = 0; j < setCount; j++){
            free(cache[j][i].dataStr);
        }
    }


    return EXIT_SUCCESS;
}