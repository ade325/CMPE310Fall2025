
;Name: Alexander Enderlein
;Date: 10/1/2025
;Email: aenderl1@umbc.edu
;ID: BZ23497
;Desc: Assembly programing to find the hamming distance between two strings.

section .data
	greeting db 'Welcome to Hamming.asm', 0x0A
	len_greeting equ $ - greeting

	request1 db 'Please enter the first string. (max of 256 characters)',0x0A ;The first string reserving a byte for each character in the string
	len_req1 equ $ - request1 ;A constant value found by subtracting the current memory address minus the starting point of string 1

	request2 db 'Please enter the second string. (max of 256 characters)', 0x0A  ;The second string reserving a byte for each char
	len_req2 equ $ - request2 ; the constant value for the length of string2

	result db 'The Hamming distance is : ' 
	len_result equ $ - result 

section .bss
	increment_counter resb 4 ; The length of the shortest string of the two strings
	numeric_output resb 4 ; This will be the numeric value of the hamming distance
	string_output resb 16 ; this will be the memory reserved for converting to ASCII
	string1 resb 256 ; reserve 256 bytes for characters on the user input
	string2 resb 256
	len_string1 resb 4 ;
	len_string2 resb 4

section .text
	global _start
	_start:
		mov eax, 4 ; prints the greeting
		mov ebx, 1
		mov ecx, greeting
		mov edx, len_greeting
		int 0x80

		mov eax, 4 ; prompts the user for the first string
		mov ebx, 1
		mov ecx, request1
		mov edx, len_req1
		int 0x80
		
        mov eax, 3 ;gathers the user input
        mov ebx, 0            
        mov ecx, string1       
        mov edx, 256            
        int 0x80
		dec eax ; eax is set to the length of the string plus a newline character so remove that new line character
		mov [len_string1], eax ;set the data of len_string1 to the length 

		mov eax, 4 ; prompts the user for the second string
		mov ebx, 1
		mov ecx, request2
		mov edx, len_req2
		int 0x80

		mov eax, 3 ; gathers the user input
        mov ebx, 0            
        mov ecx, string2       
        mov edx, 256            
        int 0x80

		dec eax ; same thing above
		mov [len_string2], eax

		mov eax, [len_string1] ; Length of string 1 in EAX to be compared to string 2 to see which is shorter
		mov ebx, [len_string2]
		cmp eax, ebx ; comparing the two strings 
		jbe less_or_equal ; eax is less or equal and set increment counter to the len of string 1

		mov [increment_counter], ebx ; ebx is shorter and increment counter will be the len of string 2
		jmp main_loop ; continue to main loop
 			
	less_or_equal: 
		mov [increment_counter], eax ; eax is the shorest string
	
	main_loop: ; after the length has been found we proceed to find the hamming distance
		mov ecx, [increment_counter] ; places the derefenced increment_couter value into ecx ex.(4)
		mov esi, string1 ; creates a pointer address of the first byte of string1 into esi
		mov edi, string2 ; creates a pointer of the first byte of string2 into edi

		xor_loop: ; the loop that will compare each byte's bits to find the difference in ones between the two
			cmp ecx, 0 ; at the start of the loop compare ecx which is currently the amounted of times needed to loop to zero
			je print_loop ; if the loop counter is zero escape the loop
			mov al, [esi] ; we need to use al (1 byte) so that we don't have any garbage values
			mov bl, [edi] ; same thing with ab
			xor al, bl ; compares the two bytes with the xor value and the amount of ones
			movzx eax, al ; in order to use popcnt we have to use a 32-bit register so convert al to 4 bytes
			popcnt edx, eax ; count the amount of 1's in the binary value of eax
			add [numeric_output], edx ;add the amount of 1's counted from the xor value to the numeric output
			inc esi ; move on to the next character of the first string
			inc edi ; move on to the next character of thes second string
			dec ecx ; decrease the loop counter
			jmp xor_loop

	print_loop: ; using the divide by 10 algorithim we can convert this number to ASCII but it comes in a backwards
		mov eax, 4 ; Prints the result format
		mov ebx, 1
		mov ecx, result
		mov edx, len_result
		int 0x80

		mov eax, [numeric_output] ; we need to put the hamming distance into a register to convert it
		mov edi, string_output ; a pointer pointing at the address of the very first byte of string_output
		add edi, 15 ; move the pointer to the very end of the string_output address
		mov byte [edi], 0x0A ;place a newline character at the very end of string_output
		dec edi ;move the pointer to the second to last byte of string_output

	conversion_loop:

		mov ebx, 10 ; numeric output/ 10 will put the quotient in eax and the remainder in edx
		xor edx, edx ; we have to set edx to zero and xor to registers is an easy way to clear the data values 
		div ebx ; this will perform eax/ebx and place the remainder in edx and the quotient in eax
		add edx, '0' ; this is the remainder and to convert the number provided to its ASCII equivelent we add '0'
		mov [edi], dl ; we only want to move the first byte of edx into the string_output and edi is acting like a pointer
		dec edi ; we will move the pointer to the left in memory to continue working backwards
		cmp eax, 0 ; this is our exit condition 
		jne conversion_loop ; the logicalal operation to check the loop it will jump if the cmp was equal
	print: ; the loop that will actually print the converted characters
		inc edi; since we move edi until eax is 0 edi pointer will be one off we need to correct that
		mov ecx, string_output ; we need to find the length of the string_output so start the at the beginning of memory
		add ecx, 16 ; add 16 to get to the end of string_output
		sub ecx, edi ; edi is currently pointer to the very first byte of where the actual data begins so we subtract the two to get the length
		mov eax, 4 ; sys call 4 for write output
		mov ebx, 1 ; sys call
		mov edx, ecx ; move the amount of bytes that it will print out
		mov ecx, edi ; edi has the starting address of the actual numbers in string_output
		int 0x80

	Exit:
		mov eax, 1
		mov ebx, 0
		int 0x80 













