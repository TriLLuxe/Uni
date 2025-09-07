; ЛР1, вариант 2 (A=8, Б=16; a=3, b=-12, c=3)
; Ввод числа в восьмеричной, вывод в десятичной.
; Вычисление F(x)=3*x^2-12*x+3. Вывод F в 16-ричной и в десятичной.


.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

; внешние функции
EXTERN  GetStdHandle@4:PROC
EXTERN  WriteConsoleA@20:PROC
EXTERN  ReadConsoleA@20:PROC
EXTERN  CharToOemA@8:PROC
EXTERN  lstrlenA@4:PROC
EXTERN  ExitProcess@4:PROC

; ---------------------------------------------------
.DATA; сегмент данных
;сообщения
msgIntro db "Введите число в восьмеричной системе: ", 0
msgInDec   db 13,10,"Число в десятичной системе: %d",13,10,0
msgPolyHex db "Значение полинома (hex): %X",13,10,0
msgPolyDec db "Значение полинома (dec): %d",13,10,0

; дескрипторы
hIn   dd ?
hOut  dd ?

; буфера
BUF   db 200 dup(?)
LENS  dd ?
OUTS  db 200 dup(?)   ; буфер для форматированных строк

; промежуточные
x_val dd ?    ; введённое число (десятичное)
poly  dd ?    ; результат полинома

; коэффициенты 
Acoef dd 3
Bcoef dd -12
Ccoef dd 3

; ---------------------------------------------------
.CODE
MAIN PROC

