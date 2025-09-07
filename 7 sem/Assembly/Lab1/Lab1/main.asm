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
STR_DEC      DB 13,10,"Число в десятичной системе: ",0
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
CONVERT_OCT:
    MOV  BL,[ESI]             ; символ -> BL
    CMP  BL,'0'
    JB   BAD_INPUT             ; если < '0' → ошибка
    CMP  BL,'7'
    JA   BAD_INPUT             ; если > '7' → ошибка
    SUB  BL,'0'               ; преобразуем символ в цифру
    MUL  EDI                  ; EAX = EAX * 8
    ADD  EAX,EBX              ; EAX += цифра
NEXT_OCT:
    INC  ESI                  ; следующий символ
    LOOP CONVERT_OCT           ; повторяем ECX раз
    MOV  X_DEC,EAX            ; сохранили десятичное число
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

    ; сразу завершаем программу
    PUSH 0
    CALL ExitProcess@4

CONVERT_OK:


; выход
PUSH 0
CALL ExitProcess@4
MAIN ENDP

END MAIN
