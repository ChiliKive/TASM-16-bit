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
    push ds
    mov ax, 0  
    mov ax, DSEG
    mov ds, ax 
    
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ah ;color
    mov ch, 3   
    mov cl, 76
    int 10h
    
    lea dx, startMes
    mov ah, 9
    int 21h
    
    call NewLine
    
Begining:
    ; Size input
    lea dx, inpSizeMes
    mov ah, 9
    int 21h

    lea dx, strInput
    mov ah, 10
    int 21h
    
    call ExitCheck
    cmp dx, 1
    je endFlg
   
    call ConvertNum
    cmp dx, 1
    je Begining

    mov al, numBuf
    cmp AL, 2
    jl sizeErr
    cmp AL, MAX_SIZE
    jg sizeErr
    
    call cls
    
    ; Fill Array
    mov arrSize, AL
    call fillArray
    call printSep   
    
    ; Print Array
    call NewLine
    call printArrMes    
    CALL printArray     
    CALL sortArray
    
    ; Print Sorted Array
    call NewLine
    call printSortMes
    call printArray
    call NewLine
    call printSep
    
    ; Print Sum
    call NewLine
    call calculateSum
    call NewLine
    
    ; Print Min
    CALL printMin
    call NewLine
    
    ; Print Max
    CALL printMax
    call NewLine
    call printSmSep
    call NewLine
    
    mov ah, 09h
    mov al, 0  
    mov bl, 0bh ;color
    mov ch, 1   
    mov cl, 28  
    int 10h
    
    ; Continue procedure
    lea dx, continueMsg
    mov ah, 9
    int 21h
    lea DX, strInput
    mov AH, 10
    int 21h
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
    mov al, 0   
    mov bl, 0ch ;color
    mov ch, 1   
    mov cl, 0   
    int 10h
    
    lea DX, sizeErrMes
    mov AH, 9
    int 21h
    call NewLine
    jmp Begining
endprog:
    mov AH, 4ch
    int 21h
    ret
MAIN ENDP
;-------------------------------


;------------------------------- Print mes: Array 
printArrMes proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    lea dx, arrayMes
    mov ah, 9
    int 21h  
    ret
printArrMes endp
;-------------------------------
;------------------------------- Print mes: Sorted Array    
printSortMes proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h

    LEA DX, sortedMes
    MOV AH, 9
    INT 21h
    ret
printSortMes endp
;-------------------------------
;------------------------------- Print small separator
printSmSep proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0dh ;color
    mov cx, 29
    int 10h

    xor dx, dx
    lea dx, smallSeparator
    mov ah, 9
    int 21h
    ret
printSmSep endp
;-------------------------------
;------------------------------- Print separator
printSep proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0dh ;color
    mov cx, 51
    int 10h
    
    xor dx, dx
    lea dx, separator
    mov ah, 9
    int 21h
    ret
printSep endp
;-------------------------------
;------------------------------- Checks for Q in a input
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
;------------------------------- Convert string into number
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
    
    lea dx, incorrectMes
    mov ah, 9
    int 21h
    call NewLine
    
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
    
    lea dx, overflowMes
    mov ah, 9
    int 21h
    call NewLine
    
    pop di
    pop bp
    pop cx   
    pop ax
    
    mov dx, 1
    ret
ConvertNum endp
;-------------------------------
;------------------------------- Fills array
fillArray PROC
    lea dx, inpArrElMes
    mov ah, 9
    int 21h
    
    mov ch, 0
    mov si, 0
    mov cl, arrSize
getElement:
    call NewLine
    ; BEG: INPUT ELLEMENT PART
    lea dx, inputArrLine        
    mov ah, 9                   
    int 21h                     
                                
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
                                
    lea dx, slash               
    mov ah, 9                   
    int 21h                     
                               
    mov ah, arrSize               
    mov numBuf, ah              
    call PrintDigit             
                            
    lea dx, inpElemMes
    mov ah, 9
    int 21h
    
    lea dx, strInput
    mov ah, 10
    int 21h
    
    call ConvertNum
    cmp dx, 1
    je getElement
    ; END: INPUT ELLEMENT PART
    mov al, numBuf
    mov array[si], al   ; Move number into array
    inc si              ; Increase index
    
    loop getElement     ; Continue
    call cls
    ret
fillArray ENDP
;-------------------------------
;------------------------------- Prints array
printArray PROC  
    mov ch, 0
    mov cl, arrSize
    mov si, 0
showPrimary:
    mov dl, array[si]   ; Geting element
    mov numBuf, dl  
    call PrintDigit     ; Printing
    mov al, ' '
    int 29h
    inc si              ; |- Next
    loop showPrimary    ; |
    ret
printArray ENDP
;-------------------------------
;------------------------------- Prints one number
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
;------------------------------- Calculates and prints sum
calculateSum PROC
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0eh ;color
    mov cx, 2
    int 10h
    
    lea dx, sumMes
    mov ah, 9
    int 21h
    
    mov ch, 0
    mov cl, arrSize
    mov si, 0
    xor ax, ax
addEl:
    xor bh, bh
    mov bl, array[si]   ; Take element
    or bl, bl           ; Check for sign
    jns  pos            ; If no sign - jupm to positive
    neg bl              ; |Change sign 
    neg bx              ; |     Make negative 2 byte
pos:
    add ax, bx          ; Add to sum
    inc si              ; - Next element
    loop addEl          ; -
    mov sum, ax         ; - Printing sum     
    call printSum       ; -
    ret
calculateSum ENDP
;-------------------------------
;------------------------------- Prints sum 
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
;------------------------------- Bubble Sort to sort my array
sortArray proc 
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
    cmp al, array[bx] ; array[i] < array[j] : less (OK, skip swap)
    jle less
    ; [SWAP] array[j] < - > array[i]
    mov dl, array[bx]   
    mov array[bx], al ; array[j] <- array[i]    
    mov bl, i           
    mov array[bx], dl ; array[i] <- array[j]   
less:
    inc j
    mov al, j
    cmp al, arrSize; j < size : inner (cmp with next)
    jl inner
    inc i
    mov al, i
    mov bl, arrSize
    dec bl
    cmp al, bl ; i < size : outer (choose next el)
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
    lea DX, minMes
    mov AH, 9
    int 21h
    
    mov CH, 0
    mov CL, arrSize
    dec CL
    mov SI, 0
    xor AX, AX
    mov AL, array[SI] ; Take [0] el
    inc SI
minLoop:
    mov BL, array[SI]   ; Take next
    cmp BL, AL          ; [next] >= [prev]: greaterFlg
    jge greaterFlg
    mov AL, BL          ; [next] < [prev]: min = [next]
greaterFlg:
    inc SI
    loop minLoop
    mov numBuf, AL      ; print min
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
    
    lea DX, maxMes
    mov AH, 9
    int 21h
    mov CH, 0
    mov CL, arrSize
    dec CL
    mov SI, 0
    xor AX, AX
    mov AL, array[SI]
    inc SI
maxLoop:
    mov BL, array[SI]
    cmp BL, AL      ; [next] <= [prev]: lessFlg 
    jle lessFlg
    mov AL, BL      ; [next] > [prev]: max = [next]
lessFlg:
    inc SI
    loop maxLoop
    mov numBuf, AL  ; print max
    call PrintDigit
    ret
printMax ENDP
;-------------------------------
;-------------------------------
NewLine proc
    mov ah, 2
    mov dl, 13 
    int 21h

    mov dl, 10
    int 21h
    ret
NewLine endp
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

CSEG ENDS
END MAIN