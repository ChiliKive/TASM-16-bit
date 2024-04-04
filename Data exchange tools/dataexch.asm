STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ("?")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
StartMes db 10, 13, "Enter a number between -4681 and 4681: $"
strInput db 7,?,7 DUP(?)
num dw 0
oppMsg db " * 7 = $"
errMsg db 10, 13, "*Invalid input* $"

continueMessage db "Enter Y/N to continue/end: $"
choice db 1h

DSEG ENDS  

CSEG SEGMENT PARA PUBLIC "CODE"

MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG

; -- Preparing ds
PUSH DS
MOV AX, 0  
MOV AX, DSEG
MOV DS, AX

Begining:
mov num, 0
; -- Starting message
lea dx, StartMes
mov ah, 9
int 21h

; -- Getting string integer
lea dx, strInput
mov ah, 10
int 21h

mov bx, 0
mov bl, strInput[1]
mov strInput[bx + 2], '$'

; -- Enter
call NewLine

lea si, strInput + 2

; -- Make it digit
call ConvertNum

; -- Enter
call NewLine

call PrintDigit

lea dx, oppMsg
mov ah, 9
int 21h

; -- multiplication on 7
mov ax, num
mov bx, 7
mul bx
mov num, ax

; -- Print result
call PrintDigit
call NewLine

Looping:
; -- Looping
call NewLine
mov ah, 9
lea dx, continueMessage
int 21h

; Choice
mov ah, 1
int 21h

mov [choice], al

call NewLine

cmp [choice], 'Y'
je Begining

cmp [choice], 'N'
je endprog


mov ah, 9
lea dx, errMsg
int 21h
jmp Looping

; -- End of program
endprog:
mov ah, 4Ch
int 21h 
ret
MAIN ENDP

; Converting procedure
ConvertNum proc 
    mov cx, 0

    cmp bl, 5
    jg Error
    
    converting:
        mov ax, 0
        mov al, [si]
        cmp al, '$'
        je Finish
        
        cmp al, '-'
        je TrigerMinus
                
        cmp al, '0'
        jl Error
        cmp al, '9'
        jg Error
        
        sub al, '0'
        push ax
        mov ax, num
        mov bx, 10
        imul bx
        jo Error
        mov num, 0
                
        add num, ax
        pop ax
        add num, ax
        jc Error

        inc si
        jmp converting

    TrigerMinus:
        inc cx 
        cmp cx, 1
        jg Error       
        dec bl
        inc si
        jmp converting

    Error:
        lea dx, errMsg
        mov ah, 9
        int 21h
        
        jmp Begining
        
        mov ah, 4Ch
        int 21h
        ret
    Finish: 
        cmp cx, 1 
        je MakeNegative
        cmp num, 4681
        jg Error
        cmp num, -4681
        jl Error
        ret
    MakeNegative:
        not num
        inc num
        cmp num, -4681
        jl Error
        ret
ConvertNum endp

; -- Print munber procedure
PrintDigit proc
    mov bx, num
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
    dec cx
    jnz m3
    ret
PrintDigit endp

NewLine proc
    mov ah, 2
    mov dl, 13 
    int 21h

    mov dl, 10
    int 21h
    ret
NewLine endp

CSEG ENDS

END MAIN