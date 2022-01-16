; Sapphire OS
; Ben Ratcliff 2022

; Entry-sector code. Launches the C kernel

[bits 32]                       ; target 32-bit code

section .entry                  ; .entry section in linker

_start:
    jmp init_protected_mode     ; skip headers, this *must* be the first line of code

%include "boot/printpm.inc"

ENTER_KERNEL    equ 0x8000      ; address of void enter_kernel()
PROTECTED_STACK equ 0x9000      ; start of the 32-bit stack (downward)
DATA_SEGMENT    equ 16          ; start of the data segment of the GDT
                                ; ^ this should not be hard coded, but I didn't want to include gdt.inc

loaded_msg db "[SUCCESS] Boot sector operations complete, entering kernel...", 0xA, 0xD, 0 ; 64 chars

init_protected_mode:

    ; We are in 32-bit protected mode now.

    ; Setup new segment registers:

    mov ax, DATA_SEGMENT        ; align all segments
    mov ds, ax                  ; to our new DATA_SEGMENT
    mov ss, ax                  ; memory partition
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Setup new stack for protected mode:

    mov ebp, PROTECTED_STACK 
    mov esp, ebp

    load_cursor_pos_pm          ; load the cursor position saved from boot-sector
    bios_print_pm loaded_msg    ; print load success and entering kernel (protected this time)

start_kernel:
    call ENTER_KERNEL           ; finally enter the 'C' kernel