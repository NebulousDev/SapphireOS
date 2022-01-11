; Sapphire OS
; Ben Ratcliff 2022

; BIOS 'real' mode utilities

[org 0x7c00] ; offset local addresses by 0x7c00, as defined by the BIOS
[bits 16]   ; run in 16-bit 'real' mode

; Switch bios video mode to 80x25 color mode
; WARNING: This function modifies ax registers
bios_enable_80_25:
    mov ah, 0       ; BIOS Video Services - video mode (0x0)
    mov al, 3       ; 80x25 color text mode
    int 0x10

    ret

; Clears the BIOS 'console' using TTY
; WARNING: This function modifies ax, bx, cx, and dx registers
bios_clear:
    mov ah, 0x07    ; BIOS Video Services - scroll window (0x7)
    mov al, 0x00    ; 0 - clear window
    mov cx, 0x0000  ; 0,0 - upper-left pos
    mov dx, 0x1950  ; 25, 80 - lower-right pos
    mov bh, 0x00    ; black - color
    int 0x10        ; call BIOS Video Services interrupt (0x10)

    ret

; Prints a string loaded in bx to the BIOS 'console' using TTY
; WARNING: This function modifies ax and bx registers
bios_print:
    mov al, [bx]    ; Load character into ax low-bit

    cmp al, 0       ; check for null terminator
    jz bios_print_ret

    mov ah, 0x0e    ; BIOS Video Services - TTY code (0x0e)
    int 0x10        ; call BIOS Video Services interrupt (0x10)

    add bx, 1       ; increment string

    jmp bios_print  ; loop

bios_print_ret:
    ret