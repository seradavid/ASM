;PROGRAM EXAMPLE FOR USING A SIMPLE MACRO

TITLE Program with macro call

STACK SEGMENT PARA 'STACK'
	DB	 64	 DUP ('STACK')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	TAMP 	DB	 2000 DUP (' ')
DATA ENDS

MYCOD SEGMENT PARA 'CODE' 	; defines code segment
	PROCED PROC FAR 		; procedure with proced name
	ASSUME CS:MYCOD, ES:DATA, DS:DATA, SS:STACK
	EXTRN INTIRP:NEAR 		; extern declaration for INTIRP procedure
	PUSH 	DS
	XOR		AX, AX
	PUSH 	AX
	MOV 	AX, DATA 		; puts data segment in ax
	MOV 	ES, AX 
	MOV 	DS, AX 			; loads es with data segment
							; program will clear the display writing 25*80 spaces on the screen
							; writing those with different values in bl the screen color will change
							; intir macro will maintain this color for a time
	MOV 	CX, 08H 		; loops 8 times
	MOV 	BL, 00H 		; sets background color
	LOOP1: 
		LEA BP, TAMP 		; writes black string
		MOV DX, 0000H 		; sets the cursor to the upper left
		MOV AH, 19			; writes attribute string
		MOV AL, 1 			; writes a character and moves the cursor
		PUSH CX 			; saves cx
		MOV CX, 07D0H 		; writes 2000 spaces
		INT 10H 			; call 10h
		CALL INTIRP  		; delays 10 units
		ADD BL, 10H 		; changes background color
		POP CX 				; restores cx
		LOOP LOOP1 			; loops 8 times
	RET 					; hands over the control to dos
PROCED ENDP 				; end procedure
MYCOD ENDS 					; end code segment
	END PROCED 