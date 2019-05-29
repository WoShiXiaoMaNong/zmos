LEDS    EQU   0x0003fff1
VMODE   EQU   0x0003fff2
SCRNX   EQU   0x0003fff4
SCRNY   EQU   0x0003fff6
VRAM    EQU   0x0003fff8

[bits 32] 

    mov eax,0x20
    mov es,eax
    mov al,'F'
    mov [es:200],al
fin:
    hlt
    jmp fin
