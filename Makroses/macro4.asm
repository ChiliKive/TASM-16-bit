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
; Macro for sum
calcculateSum macro arr, arr_size, sum_of_arr
    mov ch, 0
    mov cl, arr_size
    mov si, 0
    xor ax, ax
add_element:
    xor bh, bh
    mov bl, arr[si]
    or bl, bl
    jns pos
    neg bl
    neg bx
pos:
    add ax, bx
    inc si
    loop add_element
    mov sum_of_arr, ax
ENDM

STSEG SEGMENT PARA STACK "STACK"
    DB 64 DUP ("?")
STSEG ENDS


DSEG SEGMENT PARA PUBLIC "DATA"
    ; Data
    startMes DB "+----------+", 10, 13, "|", 4," ARRAYS ", 4,"|", 10, 13, "+----------+------------------------+", 10, 13,  "| Welcome to my program that will:  |", 10, 13, "+-----------------------------------+------+", 10, 13, "|> Read the SIZE and your ARRAY itself     |",  10, 13, "|> Print SUM of all elements               |", 10, 13, "|> Print MIN and MAX elements of array     |", 10, 13, "|> Print sorted array                      |", 10, 13, "| ! Numbers must be between -127 and 127 ! |", 10, 13,  "+------------------------------------------+", 10, 13, "$"
    inpSizeMes DB "+---------------------------------+",10, 13, "|   Enter size (2 <= size <= 99)  |",10, 13, "+----------['Q' to exit]----------+",10, 13,": $"
    separator DB "+-------------------------------------------------=$"
    smallSeparator DB "+----------------------=$"
    inpArrElMes DB "+-----------------------------+", 13, 10, "|Enter the elements of array: |", 13, 10, "+-----------------------------+", "$"
    inputArrLine DB "|[$"
    inpElemMes DB "]===> $"
    slash DB " / $"
    sumMes DB "|> Sum of array: $"
    minMes DB "|> Min element: $"
    maxMes DB "|> Max element: $"
    arrayMes DB "|> Array: $"
    sortedMes DB  "|> Sorted array: $"
    incorrectMes DB "+=============[ERROR]=============+", 13, 10, "|>   Incorrect input. Try again  <|", 13, 10, "+=================================+", 13, 10, "$"
    overflowMes DB  "+=============[ERROR]============+",13, 10, "|>      Overflow. Try again     <|", 13, 10, "+================================+",13, 10, "$"
    sizeErrMes DB "+==================[ERROR]================+", 13,10, "|>  Size should be in range from 2 to 99 <|", 13, 10,"+=========================================+", 13,10, "$"
    continueMsg db 13, 10, "+----------------------------------------+", 13, 10,"| Exit - 'Q' | Continue - something else |", 13, 10,"+------------+---------------------------+", 13, 10,": $"
    strInput DB 5, ?, 5 dup(?)

    MAX_SIZE EQU 99
    
    array db MAX_SIZE DUP ( 0 )
    numBuf db 0
    arrSize db 0
    sum dw 0
    i db 0
    j db 0
    
DSEG ENDS  

CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
    ASSUME CS: CSEG, DS: DSEG, SS: STSEG
    ; -- Preparing ds
    prepDs
    
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ah ;color
    mov ch, 3   
    mov cl, 76
    int 10h
    
    print startMes

    NewLine
    
Begining:
    ; Size input
    print inpSizeMes

    scan strInput
    
    call ExitCheck
    cmp dx, 1
    je endFlg           ; #####
    call ConvertNum
    cmp dx, 1
    je Begining
    mov al, numBuf
    cmp AL, 2
    jl sizeErr          ; #####
    
    cmp AL, MAX_SIZE
    jg sizeErr
    call cls
    mov arrSize, AL
    call fillArray
    call printSep
    call printArrPart
    call printSep
    call printStats
    call printSmSep
    NewLine
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0bh ;color
    mov ch, 1   
    mov cl, 28  
    int 10h
    ; Continue procedure
    print continueMsg
    scan strInput
    call ExitCheck
    cmp DX, 1
    je endFlg
    call cls
    jmp Begining
endFlg:
    jmp endprog
sizeErr:
    call cls
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ch ;color
    mov ch, 1   
    mov cl, 0   
    int 10h
    
    print sizeErrMes

    NewLine
    jmp Begining
endprog:
    call cls
    exit
    ret
MAIN ENDP
;-------------------------------
;-------------------------------
printArrMes proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    print arrayMes
 
    ret
printArrMes endp
;-------------------------------
;-------------------------------
printSortMes proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h

    print sortedMes

    ret
printSortMes endp
;-------------------------------
;-------------------------------
printSmSep proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0dh ;color
    mov cx, 29
    int 10h

    xor dx, dx
    print smallSeparator
    ret
printSmSep endp
;-------------------------------
;-------------------------------
printSep proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0dh ;color
    mov cx, 51
    int 10h
    
    xor dx, dx
    print separator
    ret
printSep endp
;-------------------------------

;-------------------------------
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
;-------------------------------
;-------------------------------
ConvertNum proc 
    push ax
    push cx
    push bp
    push di
    
    mov cx, 0
    lea di, strInput + 2
    
    mov al, [di]
    cmp al, 13
    je inputError
    cmp al, '-'
    jne chkDigit
    inc di
    mov cx, 1
    
chkDigit:
    mov [numBuf], 0 
    
converting:
    MOV AL, [di]
    CMP AL, 13
    JE finish
    CMP AL, '0'
    JL inputError
    CMP AL, '9'
    JG inputError
    
    MOV BL, AL
    SUB BL, '0'
    MOV AL, numBuf
    MOV DL, 10
    IMUL DL
    JO overflowError
    MOV numBuf, AL
    ADD numBuf, BL
    JO overflowError
    INC di
    JMP converting

finish:
    CMP CX, 1
    JNE posNumber
    NEG [numBuf]

posNumber:
    pop di
    pop bp
    pop cx   
    pop ax
   
    mov dx, 0
    ret
    
inputError:
    call cls
    
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ch ;color
    mov ch, 0   ;| char num
    mov cl, 200 ;|
    int 10h
    
    print incorrectMes
    
    NewLine
    
    pop di
    pop bp
    pop cx   
    pop ax
 
    mov dx, 1
    ret
    
overflowError:
    call cls
    
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ch ;color
    mov ch, 1   ;| char num
    mov cl, 0   ;|
    int 10h
    
    print overflowMes
    
    NewLine
    
    pop di
    pop bp
    pop cx   
    pop ax
    
    mov dx, 1
    ret
ConvertNum endp
;-------------------------------
;-------------------------------
fillArray PROC
    print inpArrElMes

    mov ch, 0
    mov si, 0
    mov cl, arrSize
getElement:
    NewLine
    
    print inputArrLine
    
    push cx
    
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ah ;color
    mov cl, 2
    int 10h
    
    pop cx
    
    mov ax, si
    inc al
    mov numBuf, al
    call PrintDigit
    
    print slash
    
    mov ah, arrSize
    mov numBuf, ah
    call PrintDigit
    
    print inpElemMes

    lea dx, strInput
    mov ah, 10
    int 21h
    
    call ConvertNum
    cmp dx, 1
    je getElement
    
    mov al, numBuf
    mov array[si], al
    inc si
    loop getElement
    call cls
    ret
fillArray ENDP
;-------------------------------
;-------------------------------
printArray PROC  
    mov ch, 0
    mov cl, arrSize
    mov si, 0
showPrimary:
    mov dl, array[si]
    mov numBuf, dl
    call PrintDigit
    mov al, ' '
    int 29h
    inc si
    loop showPrimary
    ret
printArray ENDP
;-------------------------------
;-------------------------------
PrintDigit PROC  
    push cx
    
    mov bh, 0
    mov bl, numBuf
    or bl, bl
    jns m1
    mov al, '-'
    int 29h
    neg bl
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
    pop cx
    ret
PrintDigit ENDP
;-------------------------------
;-------------------------------
calcPrintSum PROC
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    print sumMes
 
    
    calcculateSum array, arrSize, sum

    call printSum
    ret
calcPrintSum ENDP
;-------------------------------
;-------------------------------
printSum proc
    mov bx, sum
    or bx, bx
    jns m1
    mov al, '-'
    int 29h
    neg bx
_m1:
    mov ax, bx
    xor cx, cx
    mov bx, 10
_m2:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz m2
_m3:
    pop ax
    int 29h
    loop m3
    ret
printSum endp
;-------------------------------
;-------------------------------
sortArray proc ; Bubble Sort
    mov i, 0
outer:
    mov al, i
    mov j, al
    inc j
inner:          
    xor bh, bh
    mov bl, i
    mov al, array[bx]
    mov bl, j
    cmp al, array[bx]
    jle less
    mov dl, array[bx]
    mov array[bx], al
    mov bl, i
    mov array[bx], dl
less:
    inc j
    mov al, j
    cmp al, arrSize
    jl inner
    inc i
    mov al, i
    mov bl, arrSize
    dec bl
    cmp al, bl
    jl outer
    ret
sortArray ENDP
;-------------------------------
;-------------------------------
printMin PROC
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    print minMes

    mov CH, 0
    mov CL, arrSize
    dec CL
    mov SI, 0
    xor AX, AX
    mov AL, array[SI]
    inc SI
minLoop:
    mov BL, array[SI]
    cmp BL, AL
    jge greaterFlg
    mov AL, BL
greaterFlg:
    inc SI
    loop minLoop
    mov numBuf, AL
    call PrintDigit
    ret
printMin ENDP
;-------------------------------
;-------------------------------
printMax PROC
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    print maxMes
    
    mov CH, 0
    mov CL, arrSize
    dec CL
    mov SI, 0
    xor AX, AX
    mov AL, array[SI]
    inc SI
maxLoop:
    mov BL, array[SI]
    cmp BL, AL
    jle lessFlg
    mov AL, BL
lessFlg:
    inc SI
    loop maxLoop
    mov numBuf, AL
    call PrintDigit
    ret
printMax ENDP
;-------------------------------
;-------------------------------
cls proc
    push ax
    mov ax,03
    int 10h
    pop ax
    ret
cls endp
;-------------------------------
;-------------------------------
printArrPart proc
    ; Print Array
    NewLine
    call printArrMes
    CALL printArray
    CALL sortArray
    ; Print Sorted Array
    NewLine
    call printSortMes
    call printArray
    NewLine
    ret
printArrPart endp
;-------------------------------
printStats proc
    ; Print Sum
    NewLine
    call calcPrintSum
    NewLine
    ; Print Min
    CALL printMin
    NewLine
    ; Print Max
    CALL printMax
    NewLine
    ret
printStats endp
;-------------------------------
CSEG ENDS
END MAIN