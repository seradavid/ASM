; Lab 7 task 3
DATA SEGMENT PARA PUBLIC 'DATA'
	SIR1	DB	1, 2, 3, 4, 5
	LEN1	DB	$-SIR1
	AFIS	DB	?
DATA ENDS

CODE SEGMENT PARA PUBLIC 'CODE'
	START PROC FAR
	ASSUME CS:CODE, DS:DATA
	
	PUSH	DS
	XOR 	AX, AX
	PUSH 	AX
	MOV 	AX, DATA
	MOV 	DS, AX
	
	XOR		AX, AX
	XOR		SI, SI
	XOR 	CX, CX
	MOV		CL, LEN1
	
	AVG:
		ADD	AL, SIR1[SI]
		INC SI
		LOOP AVG
		
	DIV		LEN1
	ADD		AL, 30H
	MOV		AFIS, AL
	
	; Print a character
	MOV		AH, 02H
	MOV		DL, AL
	INT 	21H
	; End print
	RET
	START ENDP
CODE ENDS
END START