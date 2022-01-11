; Sapphire OS
; Ben Ratcliff 2022

; Boot-sector code (Bootstrap)

[org 0x7c00] ; offset local addresses by 0x7c00, as defined by the BIOS
[bits 16]    ; run in 16-bit 'real' mode

KERNEL_SECTOR   equ 0x1000
BOOT_STACK      equ 0x7cf0

; Beginning of boot-sector code
start:
    ;cli ; stop interrupts (if any)
    cld ; clear direction flag (0)

    ; setup boot stack
    mov bp, BOOT_STACK   ; set address for bottom of stack
    mov sp, bp           ; set current stack pointer

    ; enable 80-columns mode
    call bios_enable_80_25

    ; clear bios screen
    call bios_clear

    ; print title
    mov bx, title_msg
    call bios_print

    ; print entering kernel
    mov bx, loaded_msg
    call bios_print

    jmp $

%include "boot/bios_utils.inc"

title_msg   db " -- Sapphire OS v0.1 - Ben Ratcliff 2022 -- ", 0xA, 0xD, 0,     ; 46 chars
loaded_msg  db "[SUCCESS] Boot sector loaded, entering kernel...", 0xA, 0xD, 0  ; 40 chars

; Fill in boot-sector magic:

times 510 - ($-$$) db 0     ; padding
dw 0xaa55                   ; magic number