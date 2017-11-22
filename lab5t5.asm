; Lab 5 task 5
DATA SEGMENT PARA PUBLIC 'DATA'
	NUM11		DW	0FFFFH	;
	NUM12		DW	0FF32H	; First number is NUM11:NUM12
	NUM21		DW	0000H	;
	NUM22		DW	0032H	; Second numebr is NUM21:NUM22
	REZ1		DW	0		;
	REZ2		DW  0		; 
	REZ3		DW	0		;
	REZ4		DW	0		; Result is REZ1:REZ2:REZ3:REZ4
	SIGN		DB	0		; Sign of the multiplication
DATA ENDS

CODE SEGMENT PARA PUBLIC 'CODE'
	START PROC FAR
		ASSUME CS:CODE, DS:DATA

		PUSH	DS
		XOR		AX, AX
		PUSH 	AX
		MOV 	AX, DATA
		MOV 	DS, AX
		
		XOR		AX, AX				; Clear AX
		
		TEST	NUM11, 1000000000000000B 	; See if the first number is negative
		JZ		JMPB				; If it is not go and check the second number
		NOT		NUM11				; Negate the first half
		NOT		NUM12				; Negate the second half
		ADD		NUM12, 1			; Add 1 to the number
		ADC		NUM11, 0			; Add the carry
		NOT		SIGN				; Modify the sign
		
		JMPB:
		TEST	NUM11, 1000000000000000B	; See if the second number is positive
		JZ		STARTLOOP			; If it is positive start the loop
		NOT		NUM11				; Negate the first half
		NOT		NUM12				; Negate the second half
		ADD		NUM12, 1			; Add 1 to the number
		ADC		NUM11, 0			; Add the carry
		NOT 	SIGN				; Modify the sign
		
		STARTLOOP:
			TEST	NUM12, 1		; Chect to see if we have an odd number
			JZ		OVER			; If number is even, we don't add it to the sum
				MOV		AX, NUM22	; Add the second half of the second number
				ADD		REZ4, AX	; to the sum
				MOV 	AX, NUM21	; Add the first half of the second number
				ADC		REZ3, AX	; to the sum
				ADC		REZ2, 0		;
				ADC		REZ1, 0		;
			OVER:					; If the number is even
			MOV		AX, NUM11		; Save the first half of the first number
			AND		AX, 1			; Calculate the LSB
			SHL		AX, 15			; Move it to the MSB position
			SHR		NUM11, 1		; Divide the first half of the first number by two
			SHR		NUM12, 1		; Divide the second half of the first number by two
			ADD		NUM12, AX		; Add the LSB from the first half to the MSB position of the second half
			XOR 	AX, AX			; Clear AX
			SHL		NUM22, 1		; Multiply by two the second half of the second number
			ADC		AX, 0			; Save the carry bit
			SHL		NUM21, 1		; Multiply by two the first half of the second number
			ADD		NUM21, AX		; Add the carry bit
			TEST	NUM11, -1		; Check if the first half of the first number is 0 
			JNZ		STARTLOOP 		; If it's not 0 we need to loop
			TEST	NUM12, -1		; Check if the second half of the first number is 0
			JNZ		STARTLOOP		; If it's not 0 we need to loop
		
		TEST	SIGN, 1				; Check the sign of the result
		JZ		RESULT				; If it is positive don't do anything
		NOT		REZ4				; Negate part 4 of the result
		NOT		REZ3				; Negate part 3 of the result
		NOT 	REZ2				; Negate part 2 of the result
		NOT		REZ1				; Negate part 1 of the resutl
		ADD		REZ4, 1				; Add 1 to result
		ADC		REZ3, 0				; Add carry
		ADC		REZ2, 0				; Add carry
		ADC		REZ1, 0				; Add carry
		
		RESULT:						; Result is given
		
		RET
	START ENDP
CODE ENDS
END START