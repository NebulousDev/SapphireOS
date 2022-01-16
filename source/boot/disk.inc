; Sapphire OS
; Ben Ratcliff 2022

[bits 16]               ; target 16-bit code

%define stack_ops   0   ; Enable/disable bios functions pushing/restoring registers
                        ; ^ Added because the boot-sector (currently) doesn't need to push/pop 
                        ;   registers. (also reduces boot-sector size)

; Reads and stores AL number of sectors from drive DL to memory address BX
; Returns 0 or 1 on DX for success or failure respectively.
_load_sectors:
%if stack_ops
    push es
%endif

    ;al                 ; sector count
    ;mov ah, 0x2         ; BIOS Disk Services - read sector (0x2)
    ;dl                 ; drive ID
    ;mov dh, 0           ; select side of floppy (?)
    ;mov ch, 0           ; cylinder 0
    ;mov cl, 2           ; sector 2
    ;bx                 ; memory address 
    ;xor es, es         ; ensure es segment register is zero

    ;int 0x13            ; call BIOS Disk Services interrupt (0x13)

    ;jc _load_sectors_error      ; check error

_load_sectors_return:
%if stack_ops
    pop es
%endif

    ;mov dx, 0

    ;ret

_load_sectors_error:
    ;mov dx, 12
    ;jmp $
    ;jmp _load_sectors_return

%macro load_sectors 3
%if stack_ops
    push ax
    push bx
%endif
    mov dl, $1
    mov bx, $2
    mov al, $3
    call _load_sectors
%if stack_ops
    pop bx
    pop ax
%endif
%endmacro