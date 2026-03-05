OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = DEFINED(ROM_START) ? ROM_START : 0x00000000, LENGTH = 4K
    RAM (rwx) : ORIGIN = DEFINED(RAM_START) ? RAM_START : 0x00000000, LENGTH = 4K
}

SECTIONS
{
    /* 1. INSTRUCTIONS (Extracts to ins.mem) */
    .text : {
        *(.text.init) 
        *(.text*)
    } > ROM

    /* 2. DATA & CONSTANTS (Extracts to data.mem) */
    .data : {
        . = ALIGN(4);
        *(.rodata*) /* AES S-Box and Round Keys are forced here */
        *(.data*)
        *(.sdata*)
        . = ALIGN(4);
        PROVIDE( __global_pointer$ = . + 0x800 );
    } > RAM

    /* 3. UNINITIALIZED DATA (Zeroed out by crt0.s at runtime) */
    .bss : {
        . = ALIGN(4);
        PROVIDE( __bss_start = . ); 
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        PROVIDE( __bss_end = . );   
    } > RAM

    PROVIDE( __stack_top = ORIGIN(RAM) + LENGTH(RAM) );
}