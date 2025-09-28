
.386
.model flat, stdCALL

EXTERN GetStdHandle@4: PROC   
EXTERN WriteConsoleA@20: PROC
EXTERN ReadConsoleA@20: PROC 
EXTERN CharToOemA@8: PROC     
EXTERN ExitProcess@4: PROC    
EXTERN lstrlenA@4: PROC       

.DATA
    s        DB 128 dup (?)                ; строка для обработки
    len      DD ?                          ; длина строки
    d_in     DD ?                          ; дескриптор ввода
    d_out    DD ?                          ; дескриптор вывода
    s_in     DB "Введите строку: ", 0      ; запрос ввода
    s_out    DB "Строка без повторов: ", 0 ; префикс вывода
    s_er_len DB "Ошибка: в строке должно быть не менее 1 символов", 0 ; текст ошибки

.CODE
 MAIN PROC
        ; получение дескрипторов ввода/вывода
        PUSH -10             
        CALL GetStdHandle@4  
        MOV d_in, EAX        
        PUSH -11             
        CALL GetStdHandle@4  
        MOV d_out, EAX       

        ; подготовка строк
        PUSH OFFSET s_in     
        PUSH OFFSET s_in     
        CALL CharToOemA@8   
        PUSH OFFSET s_out    
        PUSH OFFSET s_out   
        CALL CharToOemA@8    
        PUSH OFFSET s_er_len 
        PUSH OFFSET s_er_len 
        CALL CharToOemA@8    

        ; вывод запроса строки
        PUSH OFFSET s_in      
        CALL lstrlenA@4      
        PUSH 0                
        PUSH OFFSET len       
        PUSH EAX              
        PUSH OFFSET s_in      
        PUSH d_out            
        CALL WriteConsoleA@20 

        ; ввод строки
        PUSH 0               
        PUSH OFFSET len      
        PUSH 128             
        PUSH OFFSET s        
        PUSH d_in            
        CALL ReadConsoleA@20 
        SUB len, 2           ; len -= 2 (для пропуска переноса строки)

        ; проверка длины строки
        MOV EAX, len
        CMP EAX, 1
        JL error
        JE done
        
        
        ; инициализация
        MOV ECX, len ; ECX = <длина строки>
        DEC ECX      ; ECX--
        ; ECX = <индекс последнего символа>

    remove_duplicates: ; метка замены повторяющихся символов
        ; поиск повторяющегося символа
        ; ECX = <индекс проверяемого символа>
        PUSH ECX             ; стек <= ECX
        MOV ESI, OFFSET s    ; ESI = адрес начала строки
        LEA EDI, [ESI + ECX] ; EDI = текущая позиция
        MOV AL, [EDI]        ; AL = текущий символ
        DEC EDI             
        STD                 
        REPNE SCASB          ; поиск пока не AL
        CLD                
        ;ECX = найденный индекс, EDI = найденный адрес - 1 

        ; обработка результата
        ; EDI = найденный адрес - 1
        JNE no_match          
        MOV ECX, ESI          
        SUB ECX, EDI         
        ADD ECX, len          
        SUB ECX, 2            
        MOV ESI, EDI          
        ADD ESI, 2            
        ADD EDI, 1            
        ;ESI-адрес начала хвоста, EDI-адрес повторки, ECX-кол-во символов в хвосте
        REP MOVSB             ; сдвиг текста с перезаписью найденного символа
        MOV byte ptr [EDI], 0 
        DEC len               
       

    no_match: 
        
        POP ECX               ; стек => ECX
        DEC ECX              
        CMP ECX, 0           
        JZ done               
        JMP remove_duplicates 

    done: 
        
        PUSH OFFSET s_out    
        CALL lstrlenA@4       
        PUSH 0                
        PUSH OFFSET len      
        PUSH EAX              
        PUSH OFFSET s_out     
        PUSH d_out            
        CALL WriteConsoleA@20 

        ; вывод результата
        PUSH OFFSET s         
        CALL lstrlenA@4       
        PUSH 0               
        PUSH OFFSET   len     
        PUSH EAX              
        PUSH OFFSET s         
        PUSH d_out           
        CALL WriteConsoleA@20 

        ; выход
        PUSH 0                
        CALL ExitProcess@4    

    error: 
      
        PUSH OFFSET s_er_len 
        CALL lstrlenA@4       
        PUSH 0               
        PUSH OFFSET len      
        PUSH EAX              
        PUSH OFFSET s_er_len 
        PUSH d_out           
        CALL WriteConsoleA@20 

        ; выход
        PUSH 1                
        CALL ExitProcess@4    
MAIN ENDP

END MAIN


