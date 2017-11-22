; Lab 7 task 2
DATA SEGMENT PARA PUBLIC 'DATA'
	SIR1	DB	'Ion are Mere', 10, 13, '$'
DATA ENDS

CODE SEGMENT PARA PUBLIC 'CODE'
	START PROC FAR
	ASSUME CS:CODE, DS:DATA
	
	PUSH	DS
	XOR 	AX, AX
	PUSH 	AX
	MOV 	AX, DATA
	MOV 	DS, AX
	
	; Print string
	MOV		AH, 09H
	MOV		DX, OFFSET SIR1
	INT 	21H
	; End print string
	
	MOV		SI, -1
	
	CONVERT:
		INC	SI
		CMP	SIR1[SI], 'a'
		JL	CONVERT
		CMP	SIR1[SI], 'z'
		JG	CONVERT
		MOV AL, SIR1[SI]
		SUB	AL, 20H
		MOV	SIR1[SI], AL
		CMP	SIR1[SI], '$'
		JNE	CONVERT
	
	; Print string
	MOV		AH, 09H
	MOV		DX, OFFSET SIR1
	INT 	21H
	; End print string
	
	RET
	START ENDP
CODE ENDS
END START