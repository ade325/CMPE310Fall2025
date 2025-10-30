;Name: Alexander Enderlein
;Date: 10/25/2025
;Email: aenderl1@umbc.edu
;ID: BZ23497
;Desc: Assembly program to take numbers from a file and sum them up and print the sum.



%macro print 2 
    mov eax, 4 ; macro for printing
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro


section .data
    greeting db 'Welcome to sumfile.asm.', 0x0A ; just the hard coded text for printing
    len_greeting equ $ - greeting

    prompt db 'Please enter the name of the text file.', 0x0A
    len_prompt equ $ - prompt

    sum_result db 'The total sum is: ' 
    len_result equ $ - sum_result
section .bss
    user_input resb 256
    buffer resb 4000
    file_description resb 4
    loop_counter resb 4
    sum resb 4
    string_buffer resb 16 
    buffer_end:
    string_ptr resb 4
    string_len resb 4
section .text
    global _start
    _start:
    input:
   		print greeting, len_greeting
        print prompt, len_prompt
        mov eax, 3
        mov ebx, 0 
        mov ecx, user_input
        mov edx, 256
        int 0x80
        dec eax
        mov byte [user_input + eax], 0
    open_file: 
        mov eax, 5 
        mov ebx, user_input
        mov ecx, 0
        mov edx, 0
        int 0x80
        mov [file_description], eax
        mov edx, buffer_end
    read_file:
        mov eax, 3
        mov ebx, [file_description]
        mov ecx, buffer
        mov edx, 4000
        int 0x80
    parse_buffer:
        mov dword [sum], 0
        mov eax, buffer
        call string_to_int
        mov [loop_counter], eax
        add [sum], eax
        mov ebx, [loop_counter]
        buffer_loop:
            cmp ebx, 0
            je print_number
            mov eax, edi
            call string_to_int
            add [sum],eax
            dec ebx
            jmp buffer_loop
    print_number:
        mov eax, [sum]
        mov edx, buffer_end
        call int_to_string
        mov [string_ptr], eax
        mov [string_len], ecx
        print sum_result, len_result
        print [string_ptr], [string_len]
    jmp exit


    int_to_string: ; Input, EAX has to have the numeric value, and EDX has to have the end pointer of buffer_end
        push ebx
        push edi
        mov edi, edx
        dec edi
        mov byte [edi], 0x0A
        mov ecx, edi
        dec edi
        str_conversion_loop:
            mov ebx, 10
            xor edx, edx
            div ebx
            add edx, '0'
            mov [edi], dl
            dec edi
            cmp eax, 0
            jne str_conversion_loop
        sub ecx, edi
        inc edi
        mov eax, edi
        pop edi
        pop ebx
        ret ; Will return the pointer at the beginning for the string in EAX, ecx contains the length of that string 

    string_to_int: ; requires EAX to contain a pointer to the beginning of that string
        push ebx
        mov edi, eax
        xor eax, eax ; eax contains the total
        xor ecx, ecx
        xor edx, edx
        int_conversion_loop:
            mov cl, [edi]
            cmp cl, '0'
            jl return
            inc edi ; move the pointer forward
            sub cl, '0' ; convert the string to a number
            movzx ebx, cl
            mov ecx, 10
            mul ecx
            add eax, ebx
            jmp int_conversion_loop

        return:
            pop ebx
            inc edi
            ret ; it will return the numberic value total in EAX and edi contains a pointer to the next number
    exit:
        mov eax, 6
        mov ebx, [file_description]
        int 0x80
        mov eax, 1
        mov ebx, 0
        int 0x80





