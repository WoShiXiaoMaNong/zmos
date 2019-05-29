        sys_base_addr equ 0x00040000
        sys_start_sector equ 0x00000001

	mov ax,cs
	mov ds,ax
	
	mov eax,[0x7c00 + pgdt + 2]
	mov ebx,0x10
	xor edx,edx
	div ebx
	
	mov ds,eax
	mov ebx,edx
	
    ;跳过0#号描述符的槽位 
    ;创建1#描述符，这是一个数据段，对应0~4GB的线性地址空间
    mov dword [ebx+0x08],0x0000ffff    ;基地址为0，段界限为0xFFFFF
    mov dword [ebx+0x0c],0x00cf9200    ;粒度为4KB，存储器段描述符 

    ;2#创建保护模式下初始代码段描述符
    mov dword [ebx+0x10],0x7c0001ff    ;基地址为0x00007c00，界限0x1FF 
    mov dword [ebx+0x14],0x00409800    ;粒度为1个字节，代码段描述符 

    ;3#建立保护模式下的堆栈段描述符      ;基地址为0x00007C00，界限0xFFFFE 
    mov dword [ebx+0x18],0x7c00fffe    ;粒度为4KB 
    mov dword [ebx+0x1c],0x00cf9600
    
    ;4#建立保护模式下的显示缓冲区描述符   
    mov dword [ebx+0x20],0x80007fff    ;基地址为0x000B8000，界限0x07FFF 
    mov dword [ebx+0x24],0x0040920b    ;粒度为字节	size

    mov word [cs:pgdt + 0x7c00],8 * 5 -1
	
    lgdt [cs:0x7c00 + pgdt]
    in al,0x92                         ;南桥芯片内的端口 
    or al,0000_0010B
    out 0x92,al                        ;打开A20
    cli
    mov eax,cr0
    or eax,0x01
    mov cr0,eax	
    jmp  dword 0x10:flush
[bits 32]
flush:
	mov eax,0x08
        mov ds,eax
        
        mov eax,0x0018
        mov ss,eax
        xor esp,esp
        
        mov edi,sys_base_addr
        mov eax,sys_start_sector
        mov ebx,edi
        call read_hard_disk_0
       
        jmp [edi]
    

;从硬盘读取一个扇区，eax=扇区号
;数据存放在ds:ebx
read_hard_disk_0:
         push eax 
         push ecx
         push edx
      
         push eax
         
         mov dx,0x1f2
         mov al,1
         out dx,al                       ;读取的扇区数

         inc dx                          ;0x1f3
         pop eax
         out dx,al                       ;LBA地址7~0

         inc dx                          ;0x1f4
         mov cl,8
         shr eax,cl
         out dx,al                       ;LBA地址15~8

         inc dx                          ;0x1f5
         shr eax,cl
         out dx,al                       ;LBA地址23~16

         inc dx                          ;0x1f6
         shr eax,cl
         or al,0xe0                      ;第一硬盘  LBA地址27~24
         out dx,al

         inc dx                          ;0x1f7
         mov al,0x20                     ;读命令
         out dx,al

  .waits:
         in al,dx
         and al,0x88
         cmp al,0x08
         jnz .waits                      ;不忙，且硬盘已准备好数据传输 

         mov ecx,256                     ;总共要读取的字数
         mov dx,0x1f0
  .readw:
         in ax,dx
         mov [ebx],ax
         add ebx,2
         loop .readw

         pop edx
         pop ecx
         pop eax
      
         ret
	
	
	
	
	pgdt:
		dw		0		;GDT size - 1
		dd 		0x00007e00      ;GDT的物理地址
		

	 times 510-($-$$) db 0
                      db 0x55,0xaa	
					  
