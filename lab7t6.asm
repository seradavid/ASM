; Lab 7 task 6
CODE SEGMENT PARA PUBLIC 'CODE'
	START PROC FAR
	ASSUME CS:CODE
	
	PUSH	DS
	XOR 	AX, AX
	PUSH 	AX
	
	MOV 	AH, 01H
	
	LOOP_READ:
		;XOR	AL, AL
		INT 21H
		CMP	AL, 10H
		JE	LOOP_END
		CMP	AL, '0'
		JL	LOOP_READ
		CMP	AL, '9'
		JG	LOOP_READ
		MUL	10
		ADD	BX, AX
		
	LOOP_END:
	
	RET
	START ENDP
CODE ENDS
END START