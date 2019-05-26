        
        mov eax,es
        mov ss,eax
        mov sp,0x7c00
        
        mov eax,[es:pgdt + 0x7c00 + 2]
        mov ebx,0x10
        xor edx,edx
        div ebx

    

pgdt    dw 0x00
        dd 0x00007e00
times 510 - ($ - $$) db 0
                     db 0x55   
                     db 0xaa
