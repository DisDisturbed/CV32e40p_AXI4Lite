// Combined Strobe Test and Bubble Sort for RISC-V 
// Updated to explicitly initialize global arrays for .data extraction

// ---------------------------------------------------------------------
// STROBE TEST ADDRESSES (Shifted to 0x800 to avoid .data overlap)
// ---------------------------------------------------------------------
volatile char* const REG1_BYTE  = (char*) 0x800; 
volatile short* const REG2_HALF = (short*)0x804; 
volatile char* const REG3_BYTE  = (char*) 0x808; 
volatile short* const REG4_HALF = (short*)0x80C; 

// ---------------------------------------------------------------------
// RESULT OUTPUT (Shifted to 0x820)
// ---------------------------------------------------------------------
volatile int* const RESULT_ADDR = (int*)0x820;
volatile int* const FLAG_ADDR   = (int*)0x0FFC; 

// ---------------------------------------------------------------------
// GLOBAL VARIABLES (.data section)
// Explicit initialization forces these into the data.mem file
// ---------------------------------------------------------------------
int n = 64; 

// This will generate 64 hex words in your data.mem file
int array[64] = {
    64, 63, 62, 61, 60, 59, 58, 57,
    56, 55, 54, 53, 52, 51, 50, 49,
    48, 47, 46, 45, 44, 43, 42, 41,
    40, 39, 38, 37, 36, 35, 34, 33,
    32, 31, 30, 29, 28, 27, 26, 25,
    24, 23, 22, 21, 20, 19, 18, 17,
    16, 15, 14, 13, 12, 11, 10,  9,
     8,  7,  6,  5,  4,  3,  2,  1
};

// Explicitly initializing to non-zero ensures they go to .data, not .bss
int i = 1; 
int j = 1; 
int temp = 1; 
int swapped = 1;

void main() {
    // =================================================================
    // 1. STROBE TESTS (Constructing 0xDEADBEEF in Little-Endian)
    // =================================================================
    REG1_BYTE[0] = 0xEF;  
    REG1_BYTE[1] = 0xBE;  
    REG1_BYTE[2] = 0xAD;  
    REG1_BYTE[3] = 0xDE;  

    REG2_HALF[0] = 0xBEEF; 
    REG2_HALF[1] = 0xDEAD; 

    REG3_BYTE[0] = 0xEF;  
    REG3_BYTE[1] = 0xBE;  
    REG3_BYTE[2] = 0xAD;  
    REG3_BYTE[3] = 0xDE;  

    REG4_HALF[0] = 0xBEEF; 
    REG4_HALF[1] = 0xDEAD; 

    // =================================================================
    // 2. BUBBLE SORT 
    // =================================================================
    
    // Bubble Sort execution (Array is already initialized in memory)
    for (i = 0; i < n - 1; i++) {
        swapped = 0;
        
        for (j = 0; j < n - i - 1; j++) {
            if (array[j] > array[j + 1]) {
                temp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = temp;
                swapped = 1;
            }
        }
        if (swapped == 0) {
            break;
        }
    }

    // Write the sorted array out to the absolute result address
    for (i = 0; i < n; i++) {
        RESULT_ADDR[i] = array[i];
    }

    // Signal completion
    *FLAG_ADDR = 0xDEADBEEF;
    
    // Halt
    while(1);
}