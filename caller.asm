; Program example for procedure use procedure defined in a different source file

TITLE Program with procedure call

STACK SEGMENT PARA 'STACK'
	DB	 64 DUP ('STACK')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	TAMP DB 2000 DUP (' ')
DATA ENDS
 
COD1 SEGMENT PARA 'CODE' 	; code segment definition
	PROCED PROC FAR 		; procedure with proced name
	ASSUME CS:COD1, ES: DATA, DS:DATA, SS:STACK
	EXTRN INTIRP:NEAR 		; extern declaration for INTIRP procedure
	PUSH DS 				; saves ds
	SUB AX, AX 				; 0 in ax
	PUSH AX 				; puts 0 on the stack
	MOV AX, DATA 			; puts seg data in ax
	MOV DS,AX
							; main program
	MOV AX, 100 			; parameter in ax
	CALL INTIRP 			; intirp procedure call
	RET 					; gives the control to dos
PROCED ENDP 				; procedure end
COD1 ENDS					; code segment end
	END PROCED 				; end program 