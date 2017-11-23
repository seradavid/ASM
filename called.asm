; called procedure
COD1 SEGMENT PARA 'CODE';defines code segment
	PUBLIC INTIRP 	 	; public declaration for INTIRP procedure
	ASSUME CS:COD1
	INTIRP PROC NEAR 	; intirp procedure name
	PUSH 	DX		 	; saves dx şi cx registers
	PUSH 	CX 		 	;
	MOV 	DX, AX 	 	; loads a delay in dx
	P1: 
		MOV CX, 0FF00H 	; loads 0FF00h in cx counts
	P2: 
		DEC CX 			; delays decrementing cx
		JNZ P2 			; if cx!=0 continue
		DEC DX 			; if cx=0 decrements dx
		JNZ P1 			; if dx!=0 loads again cx
		POP CX 			; if dx=0 restore cx and
		POP DX			; dx
	RET 				; return to the main procedure 
INTIRP ENDP 			; procedure end
COD1 ENDS
END 
