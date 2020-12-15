code    segment
        assume  cs:code,ds:code
        org     100h
        
start:  jmp     load
        old     dd  0	;адрес старого обработчика
        buf     db  ' 00:00:00 ',0	;шаблон для вывода текущего времени
		EXIT	db	0
decode  proc	;процедура заполнения шаблона
        mov     ah,  al	;преобразование двоично-десятичного
        and     al,  15	;числа в регистре al
        shr     ah,  4	;в пару ASCII символов
        add     al,  '0'
        add     ah,  '0'
        mov     buf[bx + 1],  ah	;запись ASCII символов
        mov     buf[bx + 2],  al	;в шаблон
        add     bx,  3
        ret
decode  endp

clock   proc	;процедура обработчика прерываний от таймера
        pushf
        call    cs:old	;вызов старого обработчика прерываний
        push    ds
        push    es
		push    ax
		push    bx
        push    cx
        push    dx
		push    di
        push    cs
        pop     ds

        mov     ah,  02h	;функция BIOS для получения текущего времени
        int     1Ah	;прерывание BIOS

        xor     bx,  bx	;bx на начало шаблона
        mov     al,  ch	;часы
        call    decode
        mov     al,  cl	;минуты
        call    decode
        mov     al,  dh	;секунды
        call    decode

        mov     ax,  0B800h
        mov     es,  ax
        mov     di,  140   ;чтобы вывести в правом верхнем углу
        xor     bx,  bx	;bx на начало шаблона
		mov ah, 00001111b	;атрибут выводимых символов
@@1:    mov     al,  buf[bx]	;цикл для записи символов шаблона в видеопамять
        stosw	;запись слова в строку
        inc     bx
        cmp     buf[bx],  0	;пока не конец шаблона,
        jnz     @@1	;продолжать запись символов

@@5:    pop     di	;восстановление модифицируемых регистров
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        pop     es
        pop     ds
        iret
clock   endp
end_clock:

load:   mov     ax,  351Ch	;получение адреса старого обработчика
        int     21h	;прерываний от таймера
        mov     word ptr old,  bx	;сохранение смещения обработчика
        mov     word ptr old + 2,  es	;сохранение сегмента обработчика
        mov     ax,  251Ch	;установка адреса обработчика
        mov     dx,  offset clock	;установка смещения обработчика
        int     21h
        mov ah, 4ch
        int     21h
code    ends
end     start
