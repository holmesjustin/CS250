#include <stdio.h>
#include <stdlib.h>

int PA;
int VA;
int physicalPageNum;
int badPhysicalPageNum;
int virtualPageNum;
int addressBits;
int pageSize;
int shiftedBits;
int offsetBits;


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

int main(int argc, char* argv[]) {

    FILE *file = fopen(argv[1],"r");
    fscanf(file, "%d", &addressBits);
    fscanf(file, "%d", &pageSize);

    // printf("%d \n", addressBits);
    // printf("%d \n", pageSize);

    // Set the virtual address
    VA = strtol(argv[2], NULL, 16);
    // printf("%x \n", VA);


    // Calculate number of bits for page size
    // shiftedBits = powerTwo(pageSize);
    shiftedBits = logBaseTwo(pageSize);
    // printf("%d\n", shiftedBits);

    // Calculate offset
    offsetBits = lowerBits(VA, shiftedBits);
    // printf("%d\n", offsetBits);


    // Mask to use only the needed page bits
    VA = VA>>shiftedBits;
    // printf("%d\n", VA);


    // Iterate through page table to get the PPN for the VPN
    int i = 0;
    physicalPageNum = -1;

    while(i < VA) {
        fscanf(file, "%d", &badPhysicalPageNum);
        // printf("%d\n", badPhysicalPageNum);
        // printf("%d\n", i);
        i++;
    }
        
    // When we get to the correct index, read in the value to physicalPageNum
    if (i == VA) {
        // printf("%d", i);
        // printf(" is the correct page\n");
        fscanf(file,"%d", &physicalPageNum);
    }

    // printf("This is the frame number: \n");
    // printf("%d\n", physicalPageNum);


    // Close the file as we no longer need it
    fclose(file);

    // If the physical page number is -1, we have a page fault
    if(physicalPageNum == -1) {
        printf("PAGEFAULT\n");
        return EXIT_SUCCESS;
    }

    // printf("Here is what is going to be used: \n");
    // printf("Frame number: %d ", physicalPageNum);
    // printf("Shifted bits amount: %d ", shiftedBits);
    // printf("Offset bits amount: %d \n", offsetBits);

    // Otherwise, get the physical address for the virtual address
    PA = replaceUpper(physicalPageNum, shiftedBits, offsetBits);


    // Print out the physical address
    printf("%x \n", PA);
    return EXIT_SUCCESS;
}

