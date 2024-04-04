; Use it to prepare dseg for work
prepDs macro
    push ds
    mov ax, 0
    push ax
    mov ax, dseg
    mov ds, ax
endm

; Macros that prints str: string 
print macro str
    lea dx, str
    mov ah, 9
    int 21h
endm

; Macro that gets string into buffer
scan macro buffer
    lea dx, buffer
    mov ah, 10
    int 21h
endm

; Macro that move output to the new line
NewLine macro
    mov ah, 2
    mov dl, 13 
    int 21h

    mov dl, 10
    int 21h
endm

; Macro that just ends program
exit macro
    mov ah, 4Ch
    int 21h 
endm 

; Macros for painting:
; Aqua
aqua macro length
    mov cx, length
    mov bl, 03h
    mov ah, 09h
    mov al, 0  
    int 10h
endm
; Green
green macro length
    mov cx, length
    mov bl, 0ah
    mov ah, 09h
    mov al, 0  
    int 10h
endm
; lightAqua
lightAqua macro length
    mov cx, length
    mov bl, 0bh
    mov ah, 09h
    mov al, 0  
    int 10h
endm

; light white
lightWhite macro length
    mov cx, length
    mov bl, 0Fh
    mov ah, 09h
    mov al, 0  
    int 10h
endm

; red
red macro length
    mov cx, length
    mov bl, 0Ch
    mov ah, 09h
    mov al, 0  
    int 10h
endm

heart macro
    mov al, '['  
    int 29h  
    red 1
    mov al, 3  
    int 29h        
    mov al, ']'  
    int 29h     
endm


; Makes main logic in choosing 
switch macro x 
    mov dx, x
    cmp dx, 3
    jg _f4
    cmp dx, -1
    jle _f3
    cmp dx, 1
    jg _f1
    jmp _f2
_f1:
    mov ax, 1
    jmp end_switch
_f2:
    mov ax, 2
    jmp end_switch
_f3:
    mov ax, 3
    jmp end_switch
_f4:
    mov ax, 4
    jmp end_switch
end_switch:
endm
    
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
errMsg_overFlow db 10, 13, "| *OVERFLOW detected* |$"
errMsg_invInpError db 10, 13, "| *INVALID input* |$"
showX_Mes db "[X]: $"
showY_Mes db " [Y]: $" 
m_f1 db "*[F1 Execution]*$"
f1_exp db "=| 35 / (x + x^3) = $"
m_f2 db "*[F2 Execution]*$"
f2_exp db "=| x / (1 + x^2) = $"
m_f3 db "*[F3 Execution]*$"
f3_exp db "=| 2x = $"
m_f4 db "*[F4 Execution]*$"
f4_exp db "=| x + y = $"

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
prepDs

Begining:
; Starting message
    print StartMes

; Input X
input:
    print inpMsg_x
    
    scan strInput
    
    call ExitCheck
    cmp dx, 1
    je endprog
    
    call ConvertNum
    jc input
    mov ax, numBuf
    mov x, ax
    
; Input y
    print inpMsg_y
    
    scan strInput
    
    call ExitCheck
    cmp dx, 1
    je endprog
    
    call ConvertNum
    jc input
    mov ax, numBuf
    mov y, ax
    
    jnc continueMain
endprog:    
    call cls
    heart

    exit
    ret
continueMain:
    switch x
    cmp ax, 1
    je f1
    cmp ax, 2
    je f2_
    cmp ax, 3
    je f3_
    cmp ax, 4
    je f4_
f1_: 
    jmp f1
f2_:
    jmp f2
f3_:
    jmp f3
f4_:
    jmp f4
f1:
    call cls
    lightAqua 16
    print m_f1
    NewLine
    call showXY
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
    NewLine
    NewLine
    lightWhite 20
    print f1_exp
    green 12
    call printDivision
    NewLine
    jmp input
f2:
    call cls
    lightAqua 16
    print m_f2
    NewLine
    call showXY  
    mov ax, x
    mov divisible, ax
    mov cx, ax
    imul cx
    inc ax
    mov divisor, ax 
    NewLine
    NewLine
    lightWhite 19
    print f2_exp
    green 4
    call printDivision
    NewLine   
    jmp input
f3:
    call cls
    lightAqua 16
    print m_f3
    NewLine
    call showXY                   
    mov ax, x
    mov dx, 2
    imul dx
    jo mainOverflowError_f3
    mov digit, ax
    NewLine
    NewLine
    lightWhite 7
    print f3_exp
    green 7
    call PrintDigit
    NewLine   
    jmp input
mainOverflowError_f3:
    jmp mainOverflowError
f4:
    call cls
    lightAqua 16
    print m_f4    
    NewLine
    call showXY 
    mov ax, x
    add ax, y
    jo mainOverflowError
    mov digit, ax    
    NewLine
    NewLine
    lightWhite 11
    print f4_exp
    green 7
    call PrintDigit
    NewLine    
    jmp input
mainOverflowError:
    print errMsg_overFlow
    jmp input
MAIN ENDP

; Converting procedure
ConvertNum proc 
    mov bx, 0
    mov bl, strInput[1]
    mov strInput[bx + 2], '$'
    
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

cls proc
    push ax
    mov ax,03
    int 10h
    pop ax
    ret
cls endp

showXY proc
    push ax
    aqua 17
    print showX_Mes 
    mov ax, x
    mov digit, ax
    call PrintDigit
    
    aqua 17
    print showY_Mes
    mov ax, y
    mov digit, ax
    call PrintDigit
    
    pop ax
    ret
showXY endp

CSEG ENDS

END MAIN