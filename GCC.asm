%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif
;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 
    
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start 
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret
;-------------------------------------------

section .data
        newline db 10

section .bss
        num1: resb 4
        num2: resb 4
section .text
        global _start

_start:

        call readNum
        ; the first number is stored in rax
        mov [num1], rax
        ; r9 also contians the first number
        mov r9,[num1]
        ;call writeNum
        call readNum
        mov [num2], rax
        ; storing the second number in rbx
        mov rbx, [num2]
        ; r10 also contians the second number
        mov r10, [num2]
        ; storing the first number in rax
        mov rax, r9
        ; r12 also contians the first number
        mov r12, r9
        xor r11, r11
        cmp r9, r11
        ; if the first number is zero then jump to 'ex'
        je ex
        cmp r10, r11
        ; if the second number is zero then jump to 'ex'
        je ex
        ;call writeNum
        ;cmp rax,rbx
        ;xor r8, r8
        jmp loop
        jmp Exit

loop:
        
        mov rax,r10
        xor rdx, rdx
        ; checking if the second number is divisible by number1-counter
        div r12
        xor r11, r11
        cmp rdx, r11
        ; if the second number is divisible by number1-counter jump to 'check'
        je check
        ; decreasing the first number 
        dec r12
        jmp loop
check:
        ; here we check if the first number is divisible by number1-counter
        mov rax,r9
        xor rdx, rdx
        div r12
        xor r11, r11
        cmp rdx, r11
        ; if it is --> jump to 'printLCM' to print number1-counter
        je printLCM
        ; if not, decrease (the already c times decreased) number1 and 
        ; go back to 'loop' to find another number that is divisible by number2
        dec r12
        jmp loop
        
printLCM:   
        
        ;storing the answer (LCM) in rdx
        mov rdx, r12
        mov rax, r12
        call writeNum
        ;print newline character
        mov eax, 4 
        mov ebx, 1
        mov ecx, newline ;address of newline character
        mov edx, 1 ;#bytes to write
        int 0x80 
        jmp Exit
ex:
        ;storing the answer (LCM) in rdx
        xor rdx, rdx
        xor rax, rax
        call writeNum
        ;print newline character
        mov eax, 4 
        mov ebx, 1
        mov ecx, newline ;address of newline character
        mov edx, 1 ;#bytes to write
        int 0x80
Exit:
        mov rax, 1
        mov rbx, 0
        int 0x80
