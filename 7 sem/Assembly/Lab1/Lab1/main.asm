; ��1, ������� 2 (A=8, �=16; a=3, b=-12, c=3)
; ���� ����� � ������������, ����� � ����������.
; ���������� F(x)=3*x^2-12*x+3. ����� F � 16-������ � � ����������.


.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

; ������� �������
EXTERN  GetStdHandle@4:PROC
EXTERN  WriteConsoleA@20:PROC
EXTERN  ReadConsoleA@20:PROC
EXTERN  CharToOemA@8:PROC
EXTERN  lstrlenA@4:PROC
EXTERN  ExitProcess@4:PROC

; ---------------------------------------------------
.DATA; ������� ������
;���������
msgIntro db "������� ����� � ������������ �������: ", 0
msgInDec   db 13,10,"����� � ���������� �������: %d",13,10,0
msgPolyHex db "�������� �������� (hex): %X",13,10,0
msgPolyDec db "�������� �������� (dec): %d",13,10,0

; �����������
hIn   dd ?
hOut  dd ?

; ������
BUF   db 200 dup(?)
LENS  dd ?
OUTS  db 200 dup(?)   ; ����� ��� ��������������� �����

; �������������
x_val dd ?    ; �������� ����� (����������)
poly  dd ?    ; ��������� ��������

; ������������ 
Acoef dd 3
Bcoef dd -12
Ccoef dd 3

; ---------------------------------------------------
.CODE
MAIN PROC

