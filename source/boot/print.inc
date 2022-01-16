; Sapphire OS
; Ben Ratcliff 2022

; BIOS print interaction utilities

[bits 16]               ; target 16-bit code

%define stack_ops   0   ; Enable/disable bios functions pushing/restoring registers
                        ; ^ Added because the boot-sector (currently) doesn't need to push/pop 
                        ;   registers. (also reduces boot-sector size)

cursor_x db 0           ; X position of cursor
cursor_y db 0           ; Y position of cursor

; Switch bios video mode to 80x25 color mode
_bios_set_80_25_mode:
%if stack_ops
    push ax
    push dx
%endif

    mov ah, 0x0     ; BIOS Video Services - video mode (0x0)
    mov al, 0x3     ; 80x25 color text mode

    int 0x10        ; call BIOS Video Services interrupt (0x10)

    mov ah, 0x1     ; BIOS Video Services - cursor (0x1)
    mov cx, 0x2607  ; Hidden attribute

    int 0x10        ; call BIOS Video Services interrupt (0x10)

    call _bios_get_cursor   ; retrieve and store the cursor x,y

%if stack_ops
    pop dx
    pop ax
%endif

    ret

; Get the cursor's position and stores the resulting x,y in DL and DH respectively
_bios_get_cursor:
%if stack_ops
    push ax
    push bx
%endif

    mov ah, 0x3     ; BIOS Video Services - cursor position (0x3)
    mov bx, 0x0     ; Clear BX

    int 0x10        ; call BIOS Video Services interrupt (0x10)

    mov [cursor_x], dl
    mov [cursor_y], dh

%if stack_ops
    pop bx
    pop ax
%endif

    ret

; Clears the BIOS 'console' video buffer
_bios_clear:
%if stack_ops
    push ax
    push bx
    push cx
    push dx
%endif

    mov ah, 0x07    ; BIOS Video Services - scroll window (0x7)
    mov al, 0x00    ; 0 - clear window
    mov cx, 0x0000  ; 0,0 - upper-left pos
    mov dx, 0x1950  ; 25, 80 - lower-right pos
    mov bh, 0x00    ; black - color

    int 0x10        ; call BIOS Video Services interrupt (0x10)

%if stack_ops
    pop dx
    pop cx
    pop bx
    pop ax
%endif

    ret

; Prints a string loaded in bx to the BIOS 'console'
_bios_print:
%if stack_ops
    push ax
%endif

_bios_print_loop:
    mov al, [bx]    ; Load character into ax low-bit

    cmp al, 0       ; check for null terminator
    jz _bios_print_ret

    mov ah, 0x0e    ; BIOS Video Services - TTY code (0x0e)
    int 0x10        ; call BIOS Video Services interrupt (0x10)

    add bx, 1       ; increment string

    jmp _bios_print_loop  ; loop

_bios_print_ret:
%if stack_ops
    pop ax
%endif

    call _bios_get_cursor   ; update cursor pos

    ret

; Save the cursor's position into DX
_save_cursor_pos:
    mov dh, [cursor_x]
    mov dl, [cursor_y]
    ret 

; Load the cursor's position from DX
_load_cursor_pos:
    mov [cursor_x], dh
    mov [cursor_y], dl
    ret

%macro bios_set_80_25_mode 0
    call _bios_set_80_25_mode
%endmacro

%macro bios_get_cursor_80_25 0
    call _bios_get_cursor_80_25
%endmacro

%macro bios_clear 0
    call _bios_clear
%endmacro

%macro bios_print 1
%if stack_ops
    push bx
%endif
    mov bx, %1
    call _bios_print
%if stack_ops
    pop bx
%endif
%endmacro

%macro save_cursor_pos 0
    call _save_cursor_pos
%endmacro

%macro load_cursor_pos 0
    call _load_cursor_pos
%endmacro