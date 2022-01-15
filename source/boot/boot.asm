; Sapphire OS
; Ben Ratcliff 2022

; Boot-sector code (Bootstrap)
; https://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf
; https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html

[org 0x7c00] ; offset local addresses by 0x7c00, as defined by the BIOS spec
[bits 16]    ; target 16-bit code

_start:
    jmp start  ; skip headers, this *must* be the first line

; Note: I need to include the header files at the top,
;       otherwise NASM wont resolve the macros...

%include "boot/print.inc"
%include "boot/disk.inc"
%include "boot/gdt.inc"

KERNEL_START    equ 0x9000  ; address to place the start of the kernel
KERNEL_COUNT    equ 5       ; number of sectors to load for the kernel
BOOT_STACK      equ 0x8000  ; start of the temp boot stack (downward) ; 0x7cf0

title_msg       db "     -- Sapphire OS v0.1 - Ben Ratcliff 2022 --",                       0xA, 0xD, 0     ; 50 chars
loading_msg     db "[SUCCESS] Boot sector loaded, entering 'protected' (32-bit) mode...",   0xA, 0xD, 0     ; 70 chars

drive_id        db 0        ; current (boot) drive id

; Beginning of boot-sector code
start:

    sti     ; ensure interrupts are enabled for BIOS functions
    cld     ; clear direction flags (for ESI/EDI etc)

    ; Clear segment registers

    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Hack A20 line
    ; https://wiki.osdev.org/A20_Line
    ; Note: This should be temporary until a proper method can be used

    in al, 0x92
    or al, 2
    out 0x92, al

    ; Store drive index (provided by the BIOS in dl) :

    mov [drive_id], dl

    ; Setup a temporary boot stack:

    mov bp, BOOT_STACK      ; set address for bottom of stack
    mov sp, bp              ; set current stack pointer

    ; Print title:

    bios_set_80_25_mode     ; enable 80-columns mode
    ; bios_clear            ; clear bios screen (*not needed anymore)
    bios_print title_msg    ; print title
    bios_print loading_msg  ; print loading message

    ; Load kernel memory:

    mov bx, KERNEL_START
    mov dl, [drive_id]
    mov ah, 0x02
    mov al, 5
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02

    int 0x13

    ; Enable 32-bit protected mode:
    
enable_protected_mode:

    enable_flat_gdt                 ; enable a temporary flat-model gdt until the kernel builds a proper one

    save_cursor_pos                 ; save the cursor position for use in the kernel segment

    jmp CODE_SEGMENT:KERNEL_START   ; 'far-jump' to 32-bit code segment (also flushes pipeline)
                                    ; Note 'CODE_SEGMENT' is the byte offset into the GDT

; Fill in boot-sector magic:

times 510 - ($-$$) db 0     ; padding
dw 0xaa55                   ; magic number