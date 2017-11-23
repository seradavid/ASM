TITLE Example of macro library using

IF1 						; includes a previously created
	INCLUDE C:\TASM\MLAB.MAC ; macro library
	; available on ftp.utcluj.ro/pub/users/cemil/asm/labs
ENDIF

STACK SEGMENT PARA 'STACK' ; defines a stack segment
	DB	 64 DUP ('STACK')
STACK ENDS

SEGDATA SEGMENT PARA 'DATA' ;data segment definition
	MESSAGE 	DB 	'I am a simple counting program$'
	TAMP DB 2000 DUP (‘ ‘)
SEGDATA ENDS

COD1 SEGMENT PARA 'CODE' 	; code segment definition
	MYPROC PROC FAR 		; procedure with myproc name
	ASSUME CS:COD1, DS:SEGDATA, SS:STACK
	PUSH 	DS				; saves ds
	SUB 	AX, AX 			; 0 in ax
	PUSH	AX 				; 0 on the stack
	MOV		AX, SEGDATA 	; adr segdata in ax
	MOV	 	DS, AX 			; adr segdata in ds
	DELETE 					; clear screen macro call
	CURSOR 	0019H 			; pos cursor macro call
	TYPECAR MESSAGE 		; message type macro call
	MOV 	AX, 00H 		; 0 in ax for counting
	REPEAT:
		CURSOR 0C28H 		; in middle of the screen
		TYPENUM 			; number type macro call
		INTIR 	1000 		; delay macro call
		ADD 	AL, 01H 	; increment al
		DAA 				; decimal adjustment
		CMP 	AL, 50H 	; test final
		JE 		SFIR 		; after 9 executions
		JMP 	REPEAT 		; else repeat
	SFIR: DELETE 			; clear screen macro call
	RET 					; back to dos
MYPROC ENDP 				; end procedure
COD1 ENDS 					; end segment
	END MYPROC 				; end program 