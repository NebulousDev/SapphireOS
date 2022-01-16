SECTIONS
{
    /* Boot-sectors */
    . = 0x7c00;
    .boot         : { *(.boot) }
    . = 0x7e00;
    .entry        : { *(.entry) }

    /* Kernel-sectors */
    . = 0x8000;
    .kernel_start : { *(.kernel_start) }
    .text         : { *(.text) }
    .data         : { *(.data) }
    .bss          : { *(.bss) }
}