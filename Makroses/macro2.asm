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

; Macro that cleans screan
cls macro
    mov ax,03
    int 10h
endm

; Macro for space
space macro
    mov al, ' '
    int 29h
    int 29h
endm

; lightAqua
aqua macro length
    mov cx, length
    mov bl, 03h
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

STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ("?")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"

mainMsg db "Welcome! This program will multipy your number by 7! $"
separator db "-------------------- $"
askMes db 10, 13, "Enter a number between -4681 and 4681 [Q - to Exit]: $"
oppMsg db " * 7 = $"
errMsg db "[ *** INVALID input *** ] $"
errMsg_imits db "[ *** Number only between -4681 and 4681*** ] $"
errMsg_overFlow db  "[ *** OVERFLOW detected*** ] $"

strInput db 7,?,7 DUP(?)
num dw 0

DSEG ENDS  

CSEG SEGMENT PARA PUBLIC "CODE"

MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG
; -- Preparing ds
prepDs

call printSeparator
call printSeparator
call printSeparator
NewLine
space
space
print mainMsg
NewLine
call printSeparator
call printSeparator
call printSeparator

Begining:
    mov num, 0
    
    ; -- Starting message
    print askMes

    ; -- Getting string integer
    scan strInput
    call ExitCheck
    cmp dx, 1
    je endprog
    ; -- Make it digit
    call ConvertNum
    jc Begining
    
    mov ax, num
    cmp ax, -4681
    jl error_main
    cmp ax, 4681
    jg error_main
    
    ; -- Enter
    NewLine

    cls
    
    call printSeparator
    NewLine
    space
    lightWhite 21
    call PrintDigit

    ; -- multiplication on 7
    mov ax, num
    mov bx, 7
    imul bx
    jo overFlow_main
    mov num, ax
    
    print oppMsg

    ; -- Print result
    call PrintDigit
    NewLine
    call printSeparator
    NewLine
    jmp Begining
    
endprog: ; -- End of program
    exit
    ret
error_main:
    cls
    red 47
    print errMsg_imits
    NewLine
    jmp Begining
overFlow_main:
    jmp Begining
MAIN ENDP

; Converting procedure
ConvertNum proc 
    push bp    
    mov cx, 0
    lea di, strInput + 2
    
    mov al, [di]
    cmp al, 13
    je invInput
    cmp al, '-'
    jne checking
    inc di
    mov cx, 1

checking:
    mov [num], 0
looper:
    mov al, [di]
    cmp al, 13
    je finish
    cmp al, '0'
    jl invInput
    cmp al, '9'
    jg invInput
    mov bl, al
    sub bl, '0'
    mov ax, num
    mov dx, 10
    imul dx
    mov [num], ax
    jo overflowDet
    mov bh, 0
    add [num], bx
    jo overflowDet
    inc di
    jmp looper
finish:
    cmp cx, 1
    jne positive
    neg [num]
    
positive:
    pop bp
    clc
    ret
 
invInput:
    cls
    red 25
    print errMsg
    NewLine
    pop bp
    stc
    ret
    
overflowDet:
    cls
    red 29
    print errMsg_overFlow
    NewLine
    pop bp
    stc
    ret
ConvertNum endp

; -- Print number procedure
PrintDigit proc
    push dx   
    push cx
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
    pop CX
    pop DX
    ret
PrintDigit endp

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

printSeparator proc
    aqua 21
    print separator
    ret
printSeparator endp

CSEG ENDS

END MAIN