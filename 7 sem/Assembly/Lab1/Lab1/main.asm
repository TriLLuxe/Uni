; ЛР1, вариант 2 (A=8, Б=16; a=3, b=-12, c=3)
; Ввод числа в восьмеричной системе, вывод в десятичной.
; Вычисление F(x)=3*x^2-12*x+3. Вывод F в 16-ричной и в десятичной.

.386
.MODEL FLAT, STDCALL
OPTION CASEMAP:NONE

;  внешние функции Windows API 
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN ExitProcess@4: PROC
EXTERN lstrlenA@4: PROC

.DATA
;  сообщения 
STR_INVITE   DB "Введите число в восьмеричной системе: ",0
STR_DEC      DB "Число в десятичной системе: ",0
STR_FHEX     DB "F(x)=3*x^2-12*x+3 в шестнадцатеричной системе: ",0
STR_FDEC     DB "F(x)=3*x^2-12*x+3 в десятичной системе: ",0
STR_NL       DB 13,10,0
STR_ERR      DB 13,10,"Ошибка: вводите только цифры 0..7!",13,10,0
DIGITS       DB "0123456789ABCDEF",0 ; таблица символов для HEX

;  дескрипторы 
DIN  DD ?    ; stdin
DOUT DD ?    ; stdout

;  буферы и переменные 
BUF       DB 200 DUP(?)     ; буфер ввода
LENS      DD ?              ; длина строки
OUTBUF    DB 64 DUP(?)      ; буфер для вывода числа
OUTLEN    DD ?              ; длина строки в OUTBUF

X_DEC     DD ?              ; введённое число в десятичной
F_VAL     DD ?              ; значение полинома

Acoef     DD 3
Bcoef     DD -12
Ccoef     DD 3

X_SQR   DD ?      ; x^2
AX2     DD ?      ; a*x^2
BX1      DD ?      ; b*x

.CODE
MAIN PROC

;  перекодируем все сообщения в OEM 
    MOV  EAX, OFFSET STR_INVITE 
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

    MOV  EAX, OFFSET STR_DEC
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

    MOV  EAX, OFFSET STR_FHEX
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

    MOV  EAX, OFFSET STR_FDEC
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

    MOV  EAX, OFFSET STR_NL
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

    MOV  EAX, OFFSET STR_ERR
    PUSH EAX
    PUSH EAX
    CALL CharToOemA@8

;  получаем дескрипторы ввода/вывода 
    PUSH -10
    CALL GetStdHandle@4
    MOV  DIN,EAX

    PUSH -11
    CALL GetStdHandle@4
    MOV  DOUT,EAX

;  вывод приглашения 
    PUSH OFFSET STR_INVITE 
    CALL lstrlenA@4           ; длина строки в EAX
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_INVITE 
    PUSH DOUT
    CALL WriteConsoleA@20

;  чтение строки 
    PUSH 0
    PUSH OFFSET LENS
    PUSH 200
    PUSH OFFSET BUF
    PUSH DIN
    CALL ReadConsoleA@20
    sub LENS, 2

;  перевод строки (восьмеричной) в число 
    MOV  EDI,8                ; основание системы = 8
    MOV  ECX,LENS             ; счётчик символов
    MOV  ESI,OFFSET BUF       ; указатель на строку
    XOR  EAX,EAX              ; число = 0
    XOR  EBX,EBX              ; EBX будем использовать для цифры
    XOR EBP,EBP               ; EBP = 0 -> знак '+', 1 -> '-'

    CMP  BYTE PTR [ESI], '-'  ; символ -> BL
    JNE CONVERT_OCT
    MOV  EBP, 1               ; отметили минус
    INC  ESI                  ; пропускаем '-'
    DEC  ECX                  ; уменьшаем длину


CONVERT_OCT:
    MOV  BL,[ESI] 
    CMP  BL,'0'
    JB   BAD_INPUT            ; если < '0' ? ошибка
    CMP  BL,'7'
    JA   BAD_INPUT            ; если > '7' ? ошибка
    SUB  BL,'0'               ; преобразуем символ в цифру
    SHL EAX, 3                ; EAX = EAX * 8
    ADD  EAX,EBX              ; EAX += цифра
    INC  ESI                  ; следующий символ
    LOOP CONVERT_OCT          ; повторяем ECX раз  
NEXT_OCT:   
    
    CMP EBP, 0
    JE CONVERT_OK
    XOR  EDX, EDX             ; EDX = 0
    SUB  EDX, EAX             ; EDX = 0 - EAX
    MOV  EAX, EDX             ; EAX = -EAX
    JMP  CONVERT_OK



; обработка ошибки 
BAD_INPUT:
    ; печатаем строку STR_ERR
    PUSH OFFSET STR_ERR
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_ERR
    PUSH DOUT
    CALL WriteConsoleA@20

    ; завершаем программу
    PUSH 0
    CALL ExitProcess@4

CONVERT_OK:
    MOV  X_DEC,EAX            ; сохранили десятичное число
    
; подпись "Число в десятичной системе: "
    PUSH OFFSET STR_DEC
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_DEC
    PUSH DOUT
    CALL WriteConsoleA@20

    ;  конвертация EAX -> десятичная строка со знаком 
    MOV  EAX, X_DEC            ; число для печати (signed)
    XOR  EBP, EBP              ; EBP=0 -> '+', 1 -> '-'
    CMP EAX, 0
    JGE  dec_abs_ready
    MOV  EBP, 1                ; отрицательное
    XOR  EDX, EDX
    SUB  EDX, EAX              ; |EAX| = 0 - EAX   (без NEG)
    MOV  EAX, EDX
dec_abs_ready:

    LEA  ESI, OUTBUF[63]       ; будем писать с конца буфера
    XOR  ECX, ECX              ; длина строки = 0
    MOV  EBX, 10

    ; частный случай: ноль
    CMP  EAX, 0
    JNE  dec_loop
    DEC  ESI
    MOV  BYTE PTR [ESI], '0'
    INC  ECX
    JMP  dec_sign

dec_loop:
    ; EAX > 0: вытаскиваем цифры в обратном порядке
    XOR  EDX, EDX
    DIV  EBX                   ; EAX = EAX/10, EDX = остаток
    ADD  DL, '0'
    DEC  ESI
    MOV  [ESI], DL
    INC  ECX
    CMP EAX, 0
    JNZ  dec_loop

dec_sign:
    CMP EBP, 0
    JZ   dec_print
    DEC  ESI
    MOV  BYTE PTR [ESI], '-'
    INC  ECX

dec_print:
    ; Печатаем ECX байт начиная с ESI
    PUSH 0
    PUSH OFFSET LENS           ; сюда вернётся кол-во выведенных символов
    PUSH ECX                   ; длина
    PUSH ESI                   ; адрес начала строки
    PUSH DOUT
    CALL WriteConsoleA@20
    
    ; перевод строки
    PUSH OFFSET STR_NL
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_NL
    PUSH DOUT
    CALL WriteConsoleA@20

; ===================== ВЫЧИСЛЕНИЕ F(x) =====================
    ; x^2
    MOV   EAX, X_DEC
    IMUL  EAX, EAX            ; EAX = x*x
    MOV   X_SQR, EAX

    ; a*x^2
    MOV   EAX, X_SQR
    IMUL  EAX, Acoef          ; EAX = a*x^2
    MOV   AX2, EAX

    ; b*x
    MOV   EAX, X_DEC
    IMUL  EAX, Bcoef          ; EAX = b*x
    MOV   BX1, EAX

    ; F = a*x^2 + b*x + c
    MOV   EAX, AX2
    ADD   EAX, BX1
    ADD   EAX, Ccoef
    MOV   F_VAL, EAX
; ===========================================================
  
  
; ---- подпись для HEX ----
    PUSH OFFSET STR_FHEX
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_FHEX
    PUSH DOUT
    CALL WriteConsoleA@20

; ---- конвертация F_VAL -> HEX ----
    MOV  EAX, F_VAL           ; число для печати 
    XOR  EBP, EBP             ; 0 = '+', 1 = '-'
    CMP EAX, 0
    JGE  f_hex_abs_ready
    MOV  EBP, 1               ; отрицательное
    XOR  EDX, EDX
    SUB  EDX, EAX             ; |EAX| = 0 - EAX
    MOV  EAX, EDX
f_hex_abs_ready:

    LEA  ESI, OUTBUF[63]      ; будем писать с конца буфера
    XOR  ECX, ECX             ; длина строки = 0
    MOV  EBX, 16

    ; частный случай: ноль
    CMP  EAX, 0
    JNE  f_hex_loop
    DEC  ESI
    MOV  BYTE PTR [ESI], '0'
    INC  ECX
    JMP  f_hex_sign

f_hex_loop:
    XOR  EDX, EDX
    DIV  EBX                  ; EAX = EAX / 16, EDX = остаток 0..15
    MOV  DL, [DIGITS+EDX]     ; символ из таблицы
    DEC  ESI
    MOV  [ESI], DL
    INC  ECX
    CMP EAX, 0
    JNZ  f_hex_loop

f_hex_sign:
    CMP EBP, 0
    JZ   f_hex_print
    DEC  ESI
    MOV  BYTE PTR [ESI], '-'
    INC  ECX

f_hex_print:
    PUSH 0
    PUSH OFFSET LENS
    PUSH ECX                  ; длина строки
    PUSH ESI                  ; адрес первого символа
    PUSH DOUT
    CALL WriteConsoleA@20

    ; перевод строки
    PUSH OFFSET STR_NL
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_NL
    PUSH DOUT
    CALL WriteConsoleA@20


; ---- подпись для десятичного F(x) ----
    PUSH OFFSET STR_FDEC
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_FDEC
    PUSH DOUT
    CALL WriteConsoleA@20

; ---- конвертация F_VAL -> десятичная строка ----
    MOV  EAX, F_VAL           ; число для печати 
    XOR  EBP, EBP             ; 0 = '+', 1 = '-'
    CMP EAX, 0         
    JGE  f_dec_abs_ready
    MOV  EBP, 1               ; отрицательное
    XOR  EDX, EDX
    SUB  EDX, EAX             ; |EAX| = 0 - EAX
    MOV  EAX, EDX
f_dec_abs_ready:

    LEA  ESI, OUTBUF[63]      ; пишем с конца буфера
    XOR  ECX, ECX             ; длина строки = 0
    MOV  EBX, 10

    ; частный случай: 0
    CMP  EAX, 0
    JNE  f_dec_loop
    DEC  ESI
    MOV  BYTE PTR [ESI], '0'
    INC  ECX
    JMP  f_dec_sign

f_dec_loop:
    XOR  EDX, EDX
    DIV  EBX                  ; EAX = EAX/10, EDX = остаток
    ADD  DL, '0'
    DEC  ESI
    MOV  [ESI], DL
    INC  ECX
    CMP EAX, 0
    JNZ  f_dec_loop

f_dec_sign:
    CMP EBP, 0
    JZ   f_dec_print
    DEC  ESI
    MOV  BYTE PTR [ESI], '-'
    INC  ECX

f_dec_print:
    ; печатаем ECX байт, начиная с ESI
    PUSH 0
    PUSH OFFSET LENS
    PUSH ECX
    PUSH ESI
    PUSH DOUT
    CALL WriteConsoleA@20

    ; перевод строки
    PUSH OFFSET STR_NL
    CALL lstrlenA@4
    PUSH 0
    PUSH OFFSET LENS
    PUSH EAX
    PUSH OFFSET STR_NL
    PUSH DOUT
    CALL WriteConsoleA@20

; выход
PUSH 0
CALL ExitProcess@4
MAIN ENDP

END MAIN