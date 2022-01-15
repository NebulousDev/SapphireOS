; Sapphire OS
; Ben Ratcliff 2022

; Segment discriptor structure found here: https://en.wikipedia.org/wiki/Segment_descriptor

[org 0x7c00]
[bits 16]

; Basic 'flat-model' Global Descriptor Table:

_gdt_null:          ; required null descriptor
    dd 0x0
    dd 0x0

_gdt_code:          ; code segment descriptor
    dw 0xffff       ; Limit
    dw 0x0000       ; Base [0-15]
    db 0x00         ; Base [16-23]
    db 0b10011010   ; Flags 1:  present=1, privilege=00, descriptor type=1,
                    ;       code=1, conforming=0, readable=1, accessed=0
    db 0b11001111   ; Flags 2: granularity=1, 32-bit=1, 64-bit=0, AVL=0
    db 0x00         ; Base [24-31]

_gdt_data:          ; data segment descriptor
    dw 0xffff       ; Limit
    dw 0x0000       ; Base [0-15]
    db 0x00         ; Base [16-23]
    db 0b10010010   ; Flags 1:  present=1, privilege=00, descriptor type=1,
                    ;       code=0, expanded down=0, writable=1, accessed=0
    db 0b11001111   ; Flags 2: granularity=1, 32-bit=1, 64-bit=0, AVL=0
    db 0x00         ; Base [24-31]

_gdt_end:

; TODO: Align GDT to 8-byte boundry? (Intel 3A p101)
_gdt:
    dw _gdt_end - _gdt_null - 1     ; (one less than) the size of the GDT
    dd _gdt_null                    ; start address of the GDT

; Enables a 'flat-model' GDT
; WARNING: modifies eax and cr0 registers
_enable_flat_gdt:
    cli             ; disable interrupts

    lgdt [_gdt]     ; write gdt descriptor register

    mov eax, cr0    ; copy current control register flags
    or eax, 0x1     ; set the first bit (protected mode)
    mov cr0, eax    ; write back the updated control register flags

    ;sti             ; enable interrupts

    ret

; Code and data segments offsets:

CODE_SEGMENT equ _gdt_code - _gdt_null
DATA_SEGMENT equ _gdt_data - _gdt_null

%macro enable_flat_gdt 0
    call _enable_flat_gdt
%endmacro