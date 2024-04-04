;
; f1 = 35 / (x + x*x*X) : 1 < x <= 3    x=2 -> f=3.5; x=3 -> f=1.16667
; f2 = x / (1 + x*x) : -1 < x <= 1      x=0 -> f=0; x=1 -> f=0.5  
; f3 = 2x : x <= -1                     
; f4 = x + y : else                     
;
STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ("?")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
StartMes db 10, 13, "[!!! This program will calculate specific function !!!] $"
inpMsg_x db 10, 13, "-> Enter the value for a [x] or 'Q' to exit: $"
inpMsg_y db 10, 13, "-> Enter the value for a [y] or 'Q' to exit: $"
oppMsg db " * 7 = $"
errMsg_overFlow db 10, 13, "*OVERFLOW detected* $"
errMsg_invInpError db 10, 13, "*INVALID input* $"

m_f1 db 10, 13, 10, 13, "*[F1 Execution]*$"
m_f2 db 10, 13, 10, 13, "*[F2 Execution]*$"
m_f3 db 10, 13, 10, 13, "*[F3 Execution]*$"
m_f4 db 10, 13, 10, 13, "*[F4 Execution]*$"

strInput db 7,?,7 DUP(?)
numBuf dw 0
x dw 0
y dw 0
divisor dw 0
divisible dw 0
digit dw 0

choice db 1h
DSEG ENDS  

CSEG SEGMENT PARA PUBLIC "CODE"

MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG

; -- Preparing ds
push DS
mov AX, 0  
mov AX, DSEG
mov DS, AX

Begining:
; Starting message
    lea dx, StartMes
    mov ah, 9
    int 21h

; Input X
input:
    lea dx, inpMsg_x
    mov ah, 9
    int 21h

    lea dx, strInput
    mov ah, 10
    int 21h
    
    call ExitCheck
    cmp dx, 1
    je endprog
    
    mov bx, 0
    mov bl, strInput[1]
    mov strInput[bx + 2], '$'

    call ConvertNum
    jc input
    mov ax, numBuf
    mov x, ax
    
; Input y
    lea dx, inpMsg_y
    mov ah, 9
    int 21h
    
    lea dx, strInput
    mov ah, 10
    int 21h
    
    call ExitCheck
    cmp dx, 1
    je endprog

    mov bx, 0
    mov bl, strInput[1]
    mov strInput[bx + 2], '$'

    call ConvertNum
    jc input
    mov ax, numBuf
    mov y, ax
    
    jnc continueMain
endprog:
    mov ah, 4Ch
    int 21h 
    ret
continueMain:
    mov ax, x
    ; 1 < x <= 3 
    cmp ax, 1
    jle not_f1
    cmp ax, 3
    jg not_f1
    ; f1
    lea dx, m_f1
    mov ah, 9
    int 21h
    ; f1 = 35 / (x + x*x*X) : 1 < x <= 3    x=2 -> f=3.5; x=3 -> f=1.16667
    mov ax, 35
    mov divisible, ax
    mov ax, x
    mov cx, ax
    imul cx
    mov cx, ax
    mov ax, x
    imul cx
    add ax, x
    mov divisor, ax
    
    call NewLine
    call NewLine
    call printDivision
    call NewLine

    jmp input
not_f1:
    ; -1 < x <= 1 
    cmp ax, -1
    jle not_f2
    cmp ax, 2
    jg not_f2
    ; f2
    lea dx, m_f2
    mov ah, 9
    int 21h
    ; f2 = x / (1 + x*x) : -1 < x <= 1      x=0 -> f=0; x=1 -> f=0.5  
    mov ax, x
    mov divisible, ax
    mov cx, ax
    imul cx
    inc ax
    mov divisor, ax
    
    call NewLine
    call NewLine
    call printDivision
    call NewLine
    
    jmp input
not_f2:
    ; x <= -1 
    cmp ax, -1
    jg not_f3
    ; f3
    lea dx, m_f3
    mov ah, 9
    int 21h
    ; f3 = 2x : x <= -1                     
    mov ax, x
    mov dx, 2
    imul dx
    jo mainOverflowError
    mov digit, ax
    
    call NewLine
    call NewLine
    call PrintDigit
    call NewLine
    
    jmp input
not_f3:
    ; f4 
    lea dx, m_f4
    mov ah, 9
    int 21h                
    ; f4 = x + y : else   
    mov ax, x
    add ax, y
    jo mainOverflowError
    mov digit, ax
    
    call NewLine
    call NewLine
    call PrintDigit
    call NewLine
    
    jmp input
    
mainOverflowError:
    lea dx, errMsg_overFlow
    mov ah, 9
    int 21h
    jmp input
MAIN ENDP

; Converting procedure
ConvertNum proc 
    mov cx, 0
    
    mov numBuf, 0 
    
    lea si, strInput + 2
        
    converting:
        mov ax, 0
        
        mov al, [si]
        cmp al, '$'
        je Finish
        
        cmp al, 13
        je inputError
        
        cmp al, '-'
        je TrigerMinus
                
        cmp al, '0'
        jl inputError
        cmp al, '9'
        jg inputError
 
        sub al, '0'
        push ax
        mov ax, numBuf
        mov bx, 10
        imul bx
        jo overflowError
        mov numBuf, 0 
     
        add numBuf, ax
        pop ax
        add numBuf, ax
        jo overflowError
        
        mov dh, 0
        add numBuf, dx
        jo overflowError
        
        inc si
        jmp converting

    TrigerMinus:
        inc cx 
        cmp cx, 1
        jg inputError       
        dec bl
        inc si
        jmp converting
    inputError:
        lea dx, errMsg_invInpError
        mov ah, 9
        int 21h
        stc 
        ret
    overflowError:
        lea dx, errMsg_overFlow
        mov ah, 9
        int 21h
        stc 
        ret
    Finish: 
        cmp cx, 1
        je MakeNegative
        clc
        ret
    MakeNegative:
        not numBuf
        inc numBuf
        mov cx, 0
        jmp Finish
ConvertNum endp

printDivision PROC
    mov ax, divisible
    or AX, AX
    jns positive
    mov AL, '-'
    int 29h
    mov AX, divisible
    neg AX
positive:
    mov dx, 0
    mov bx, divisor
    div bx
    mov digit, ax
    call PrintDigit
    cmp dx, 0
    je integer
    mov al, '.'
    int 29h
    mov cx, 6
looper:
    mov ax, dx
    mov bx, 10
    mul bx
    mov bx, divisor
    mov dx, 0
    div bx
    mov digit, ax
    call PrintDigit
    cmp dx, 0
    je integer
    loop looper
integer:
    ret
printDivision ENDP

PrintDigit PROC
    push dx   
    push cx
    mov bx, digit
    or bx, bx
    jns m1
    mov al, '-'
    int 29h
    neg bx
m1:
    mov ax, bx
    xor cx, cx
    mov bx, 10
m2:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz m2
m3:
    pop ax
    int 29h
    loop m3
    pop CX
    pop DX
    ret
PrintDigit ENDP

NewLine proc
    mov ah, 2
    mov dl, 13 
    int 21h

    mov dl, 10
    int 21h
    ret
NewLine endp

ExitCheck PROC
    mov dx, 0
    push si
    lea si, strInput + 2
    push ax
    mov al, [si]
    cmp al, 'Q'
    je isQ
    jne contp
isQ:
    inc si
    mov al, [si]
    cmp al, 13
    je trigend
    jne contp
trigend:
    mov DX, 1
contp:
    pop ax
    pop si
    ret
ExitCheck ENDP


CSEG ENDS

END MAIN