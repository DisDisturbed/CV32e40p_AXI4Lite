.section .text.init
.global _start

_start:
    nop                     /* Reset vector alignment/catch */

    /* ------------------------------------------------- */
    /* 1. Initialize Global Pointer (Crucial for relaxation) */
    /* ------------------------------------------------- */
    nop
    nop
    nop
    nop
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    /* ------------------------------------------------- */
    /* 2. Initialize Stack Pointer                       */
    /* ------------------------------------------------- */
    
    la sp, __stack_top      
    add s0, sp, zero        /* Set frame pointer */

    /* ------------------------------------------------- */
    /* 3. Clear .bss Section (Zero out uninitialized data)*/
    /* ------------------------------------------------- */
    la a0, __bss_start
    la a1, __bss_end
    bgeu a0, a1, 2f         /* Skip if start >= end (empty bss) */
1:
    sw zero, 0(a0)          /* Store zero */
    addi a0, a0, 4          /* Move to next word */
    bltu a0, a1, 1b         /* Loop until we hit the end */
2:

    /* ------------------------------------------------- */
    /* 4. Jump to C Code                                 */
    /* ------------------------------------------------- */
    
    jal ra, main

    /* ------------------------------------------------- */
    /* 5. Trap Loop (Safety)                             */
    /* ------------------------------------------------- */
1:  j 1b