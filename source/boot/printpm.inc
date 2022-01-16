; Sapphire OS
; Ben Ratcliff 2022

; BIOS print interaction utilities for protected mode

[bits 32]   ; 32-bit functions:

%define pm_funcs    1   ; For disabling 32-bit functions when errors (inevitably) occur
                        ; ^ (legacy) added when debugging a missing '[bits 16]' macro

%define stack_ops   1   ; Enable/disable bios functions pushing/restoring registers
                        ; ^ Added because the boot-sector (currently) doesn't need to push/pop 
                        ;   registers. (also reduces boot-sector size)

VIDEO_MEMORY_BUFFER_PM  equ 0xb8000 ; Location of the start of BIOS video memory (protected mode)

cursor_x db 0           ; X position of cursor
cursor_y db 0           ; Y position of cursor

%if pm_funcs

global _bios_print_pm

; Prints a string loaded in ESI to the BIOS 'console' from protected mode
; WARNING: this function does not check for end of video buffer!
;          (nor if video buffer is correct address)
_bios_print_pm:
%if stack_ops
    push eax
    push ecx
    push edi
    push esi
%endif
_bios_print_pm_start:

    ; Calculate position with [x + y * width]

    movzx eax, byte [cursor_y]  ; move and zero-extend cursor_x into AX
    mov ecx, (80 * 2)           ; multiply by video width (80) * bytes (2)
    mul ecx

    movzx ebx, byte [cursor_x]  ; move and zero-extend cursor_y into BX
    shl ebx, 1                  ; shift BX left by one, effectively multiplying by 2

    mov edi, VIDEO_MEMORY_BUFFER_PM     ; Move memory buffer address into DI (offset by ES register, thus zero here)
    add edi, eax                        ; add x-offset
    add edi, ebx                        ; add y-offset

_bios_print_pm_loop:

    mov eax, [esi]              ; loads one byte from ESI into AL
    mov ah, 0x07                ; fill (high-bits) attributes in AH

    cmp al, 0                   ; check for null terminator
    jz _bios_print_pm_ret

    cmp al, 0xA                 ; check for newline
    jz _bios_print_pm_nl

    cmp al, 0xD                 ; check for carriage return
    jz _bios_print_pm_cont      ; ignore

    mov word [ds:edi], ax       ; write char & attribute to EDI

_bios_print_pm_cont:

    add byte [cursor_x], 1      ; advance cursor x
    lea esi, [esi + 1]          ; advance ESI
    lea edi, [edi + 2]          ; advance EDI

    jmp _bios_print_pm_loop

_bios_print_pm_nl:
    mov byte [cursor_x], 0      ; reset x to zero
    add byte [cursor_y], 1      ; increment y by one
    lea esi, [esi + 1]          ; advance ESI
    lea edi, [edi + 2]          ; advance EDI

    jmp _bios_print_pm_start

_bios_print_pm_ret:
%if stack_ops
    pop esi
    pop edi
    pop ecx
    pop eax
%endif

    ret

; Save the cursor's position into DX (protected mode)
_save_cursor_pos_pm:
    mov dh, [cursor_x]
    mov dl, [cursor_y]
    ret 

; Load the cursor's position from DX (protected mode)
_load_cursor_pos_pm:
    mov [cursor_x], dh
    mov [cursor_y], dl
    ret

%macro bios_print_pm 1
%if 1
    push esi
%endif
    mov esi, %1
    call _bios_print_pm
%if 1
    pop esi
%endif
%endmacro

%macro save_cursor_pos_pm 0
    call _save_cursor_pos_pm
%endmacro

%macro load_cursor_pos_pm 0
    call _load_cursor_pos_pm
%endmacro

%endif