/* linksc.ld */
OUTPUT_ARCH(riscv)
ENTRY(_start) /* Ensure this matches the entry label in your crt0.s */

MEMORY
{
    /* Use the addresses passed from the Makefile, default to 0x0 if missing */
    ROM (rx)  : ORIGIN = DEFINED(ROM_START) ? ROM_START : 0x00000000, LENGTH = 4K
    RAM (rwx) : ORIGIN = DEFINED(RAM_START) ? RAM_START : 0x00000000, LENGTH = 4K
}

SECTIONS
{
    .text : {
        /* Force the startup code to be at the absolute beginning of ROM */
        *(.text.init) 
        *(.text*)
        *(.rodata*)
    } > ROM

    .data : {
        . = ALIGN(4);
        *(.data*)
        *(.sdata*)
        . = ALIGN(4);
        
        /* The Global Pointer allows 12-bit relative addressing. 
           Offsetting by 0x800 maximizes its forward/backward reach. */
        PROVIDE( __global_pointer$ = . + 0x800 );
    } > RAM

    .bss : {
        . = ALIGN(4);
        /* Mark the start of uninitialized variables */
        PROVIDE( __bss_start = . ); 
        
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        
        . = ALIGN(4);
        /* Mark the end of uninitialized variables */
        PROVIDE( __bss_end = . );   
    } > RAM

    /* Set the stack to start at the very top of your 4KB RAM block and grow down */
    PROVIDE( __stack_top = ORIGIN(RAM) + LENGTH(RAM) );
}