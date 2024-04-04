STSEG SEGMENT PARA STACK "STACK"
    DB 64 DUP ("?")
STSEG ENDS


DSEG SEGMENT PARA PUBLIC "DATA"
    ; Data  
    startMes DB "+----------+", 13, 10, "|", 206," MATRIX ", 206,"|", 13, 10, "+----------+------------------------+", 13, 10,  "| Welcome to my program that will:  |", 13, 10, "+-----------------------------------+--------------------+", 13, 10, "|> Read the SIZE and your MATRIX itself                  |",  13, 10, "|> Search and display the coordinates of a matrix element|", 13, 10, "|* Matrix numbers must be between -127 and 127           |" , 13, 10, "+--------------------------------------------------------+", 10, 13, "$"
    
    inpRowsMes DB "+-------------------------------------+",13, 10, "|   How many ROWS? (2 <= size <= 8)   |",13, 10, "+-------------['Q' to exit]-----------+",13, 10,": $"
    inpColsMes DB "+----------------------------------------+",13, 10, "|   How many COLUMNS? (2 <= size <= 8)   |",13, 10, "+--------------['Q' to exit]-------------+",13, 10,": $"
    
    searchElementMes db "+-----------------------+-------------------------+------------+", 13, 10, "|Enter number to search | 'N' - Create new matrix | 'Q' - Exit |", 13, 10, "+-----------------------+-------------------------+------------+", 13, 10, ": $"
    
    
    inputArrLine DB "|[$"
    inpElemMes DB "]===> $"
    slash DB " / $"
    matrixMes db "+------------------+", 13, 10, "|--=\/=MATRIX=\/=--|", 13, 10, "+--+---------------+", "$"
    inpRowMes db "Enter row $"
    verLine db "]| $"
    
    incorrectMes DB "+=============[ERROR]=============+", 13, 10, "|>   Incorrect input. Try again  <|", 13, 10, "+=================================+", "$"
    overflowMes DB  "+=============[ERROR]============+",13, 10, "|>      Overflow. Try again     <|", 13, 10, "+================================+", "$"
    sizeErrMes DB "+=================[ERROR]=================+", 13,10, "|>  Size should be in range from 2 to 8  <|", 13, 10,"+=========================================+", 13,10, "$"
    notFoundMes db "+==================================+", 13, 10, "|>  Element not found. Try again  <|", 13, 10, "+==================================+", "$"
    continueMsg db 13, 10, "+----------------------------------------+", 13, 10,"| Exit - 'Q' | Continue - something else |", 13, 10,"+------------+---------------------------+", 13, 10,": $"
    
    strInput db 5, ?, 5 dup(" ")
    numBuf db ?
    searchEl db ?
    
    MAX_ROWS EQU 8
    MAX_COLS EQU 8
    rows db 0
    cols db 0
    arrSize db 0
    
    matrix DB MAX_ROWS*MAX_COLS dup ( 0 )
    array db MAX_COLS dup (0)
        
DSEG ENDS  

CSEG SEGMENT PARA PUBLIC "CODE"
MAIN PROC FAR
    ASSUME CS: CSEG, DS: DSEG, SS: STSEG
    ; -- Preparing ds
    push DS
    
    mov AX, 0  
    mov AX, DSEG
    mov DS, AX
    
    call printStart
    
Begining:    ; ROWS
    call NewLine
    lea dx, inpRowsMes  ; Message
    mov ah, 9
    int 21h
    lea dx, strInput    ; Get size
    mov ah, 10
    int 21h 
    call exitCheck      ; Check for Q
    cmp dx, 1
    je endFlg   
    call ConvertNum     ; Convert into num format
    cmp dx, 1
    je Begining
    mov al, numBuf      ; Size check
    cmp al, 2
    jl rowSizeErr
    cmp al, MAX_ROWS
    jg rowSizeErr
    mov rows, al        ; Assignment
inputColumns:   ; COLUMNS
    call NewLine
    lea dx, inpColsMes  ; Message
    mov ah, 9
    int 21h
    lea dx, strInput    ; Get size
    mov ah, 10
    int 21h 
    call exitCheck      ; Check for Q
    cmp dx, 1
    je endFlg   
    call ConvertNum     ; Convert into num format
    cmp dx, 1
    je inputColumns
    mov al, numBuf
    cmp al, 2
    jl colSizeErr
    cmp al, MAX_COLS
    jg colSizeErr
    mov cols, al        ; Assignment
    call cls
    
    call fillMatrix     ; Getting matrix
    call printMatrix    ; Show matrix
    
    jmp inpDesiredNum
    
    lea dx, continueMsg ;Continue / New matrix[TODO] / Exit
    mov ah, 9
    int 21h
    lea dx, strInput
    mov ah, 10
    int 21h
    call ExitCheck
    cmp dx, 1
    je endprog
    
    call cls
    
    jmp Begining
endFlg:
    jmp endprog 
rowSizeErr:
    call cls
    mov cx, 205
    mov bl, 0ch
    call makeColor
    lea dx, sizeErrMes
    mov ah, 9
    int 21h
    jmp Begining
colSizeErr:
    call cls
    mov cx, 205
    mov bl, 0ch
    call makeColor
    lea dx, sizeErrMes
    mov ah, 9
    int 21h
    jmp inputColumns
    
inpDesiredNum:
    call NewLine
    lea dx, searchElementMes
    mov ah, 9
    int 21h
  
    lea dx, strInput
    mov ah, 10
    int 21h
    
    call NewCheck 
    cmp dx, 1
    je begFlag
    
    call ExitCheck
    cmp dx, 1
    je endprog
    
    call ConvertNum     ; Convert into num format
    cmp dx, 1
    je inpDesiredNum
    
    mov al, numBuf
    mov searchEl, al
    
    call elementSearching 
    
    jmp inpDesiredNum    
endprog:
    mov AH, 4ch
    int 21h
    ret
begFlag:
    call cls
    jmp Begining
MAIN ENDP
;#-----------------------------------------#
;#-----------------------------------------#
printStart proc
    mov ah, 09h
    mov al, 0   ;symb
    mov bl, 0ah ;color
    mov ch, 2   
    mov cl, 186 
    int 10h
    
    lea DX, startMes
    mov AH, 9
    int 21h
ret
printStart endp
;#-----------------------------------------#
;#-----------------------------------------#
makeColor proc
    ; CX - Lenght
    ; BL - Color
    mov ah, 09h
    mov al, 0  
    int 10h
    ret
makeColor endp 
;    0 = Black       8 = Gray
;    1 = Blue        9 = Light Blue
;    2 = Green       A = Light Green
;    3 = Aqua        B = Light Aqua
;    4 = Red         C = Light Red
;    5 = Purple      D = Light Purple
;    6 = Yellow      E = Light Yellow
;    7 = White       F = Bright White
;#-----------------------------------------#
;#-----------------------------------------#
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
    mov dx, 1
contp:
    pop ax
    pop si
    ret
ExitCheck ENDP
;#-----------------------------------------#
;#-----------------------------------------#
NewCheck proc
    mov dx, 0
    
    push si
    lea si, strInput + 2
    
    push ax
    mov al, [si]
    
    cmp al, 'N'
    je isN
    jne contSrch
isN:
    inc si
    mov al, [si]
    cmp al, 13
    je newM
    jne contSrch
newM:
    mov dx, 1
contSrch:
    pop ax
    pop si
    ret
NewCheck endp
;#-----------------------------------------#
;#-----------------------------------------#
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
    
    mov bl, 0ch
    mov cx, 195
    call makeColor
    
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
    
    mov bl, 0ch
    mov ch, 1
    call makeColor
    
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
;#-----------------------------------------#
;#-----------------------------------------#
fillMatrix proc
    xor ch, ch
    xor si, si
    mov cl, rows
fillRow:
    call NewLine
    lea dx, inpRowMes
    mov ah, 9
    int 21h
    mov ax, si
    mov numBuf, al
    inc numBuf
    mov al, '['
    int 29h
    push cx
    mov cx, 1
    mov bl, 0ah
    call makeColor
    pop cx
    call PrintDigit
    lea dx, slash
    mov ah, 9
    int 21h
    mov ah, rows
    mov numBuf, ah
    call PrintDigit
    mov al, ']'
    int 29h
    
    call fillArray ; Filling ROW
    
    xor di, di
    push cx
    mov cl, cols
moveRow:
    mov bl, array + di
    ; Calculates position in matrix
    mov ax, si
    mul cols
    add ax, di
    mov dx, di
    mov di, ax
    ; 
    mov matrix + di, bl 
    mov di, dx          ; Element from array moves to matrix
    ;
    inc di      ; Next element
    ;
    loop moveRow
    pop cx
    inc si
    loop fillRow
    ret
fillMatrix endp
;#-----------------------------------------#
;#-----------------------------------------#
printMatrix proc
    mov cx, 180
    mov bl, 05h
    call makeColor
    lea dx, matrixMes
    mov ah, 9
    int 21h
    call NewLine
    
    xor ch, ch
    mov cl, rows
    xor si, si
printRow:
    mov al, '['
    int 29h
    mov ax, si
    inc ax
    mov numBuf, al
    push cx
    mov cx, 1
    mov bl, 0ah
    call makeColor
    pop cx
    call PrintDigit
    lea dx, verLine
    mov ah, 9 
    int 21h
    
    xor di, di
    push cx
    mov cl, cols
printElement:
    mov ax, si
    mul cols    ; rows * cols
    add ax, di  ; + col
    mov dx, di
    mov di, ax
    mov bl, matrix + di ; Get that element to bl
    mov numBuf, bl      
    call PrintDigit     ; and print
    mov di, dx
    mov al, ' '
    int 29h
    inc di
    loop printElement
    pop cx

    call NewLine
    
    inc si
    loop printRow
    ret
printMatrix endp

;#-----------------------------------------#
;#-----------------------------------------#
fillArray proc
    push si
    push cx
    
    mov ch, 0
    mov si, 0
    mov cl, cols
getElement:
    call NewLine
    
    lea dx, inputArrLine
    mov ah, 9
    int 21h
    push cx
    mov bl, 0ah ;color
    mov cl, 2
    call makeColor
    pop cx
    mov ax, si
    inc al
    mov numBuf, al
    call PrintDigit
    lea dx, slash
    mov ah, 9
    int 21h
    mov ah, cols
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
    
    mov al, numBuf
    mov array[si], al
    inc si
    
    loop getElement
    call cls
    pop cx
    pop si
    ret
fillArray ENDP
;#-----------------------------------------#
;#-----------------------------------------#
PrintDigit PROC  
    push cx
    push ax
    push dx
    
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
    pop dx
    pop ax
    pop cx
    ret
PrintDigit ENDP
;#-----------------------------------------#
;#-----------------------------------------#
elementSearching PROC
    call NewLine
    xor ch, ch
    mov al, rows
    mul cols
    mov cl, al
    xor si, si
    xor dl, dl
searchLoop:
    mov bl, matrix[si]
    cmp bl, searchEl ; Check for element
    jne notFound
    inc dl ; Find - inc counter - print it - seach again
    mov ax, si
    div cols        ; Div for row number
    mov bl, al
    mov al, '('
    int 29h
    mov numBuf, bl
    inc numBuf
    call PrintDigit
    mov al, ','
    int 29h
    mov al, ' '
    int 29h
    mov numBuf, ah  ; Div puts the remainder(column) in the ah 
    inc numBuf
    call PrintDigit
    mov al, ')'
    int 29h
    mov al, ' '
    int 29h
notFound:
    inc si 
    loop searchLoop 
    cmp dl, 0
    jne finishSearch
    
    call cls
    mov bl, 6
    mov cx, 196
    call makeColor
    
    lea dx, notFoundMes 
    mov ah, 9
    int 21h
    call NewLine
    call printMatrix
    
finishSearch: 
    call NewLine
    ret
elementSearching ENDP
;#-----------------------------------------#
;#-----------------------------------------#
NewLine proc
    mov ah, 2
    mov dl, 13 
    int 21h

    mov dl, 10
    int 21h
    ret
NewLine endp
;#-----------------------------------------#
;#-----------------------------------------#
cls proc
    push ax
    mov ax,03
    int 10h
    pop ax
    ret
cls endp
;#-----------------------------------------#
;#-----------------------------------------#
CSEG ENDS
END MAIN