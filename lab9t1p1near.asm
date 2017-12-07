DATE SEGMENT PARA PUBLIC 'DATA' ; data segment definition
 
DATE ENDS

STAC SEGMENT PARA STACK 'STACK' ;stack segment definition
	db 		64 dup ('MY_STACK')
STAC ENDS

COD1 SEGMENT PARA PUBLIC 'CODE' ; cod segment definition
EXTRN PROCED: NEAR
PRPRINC PROC FAR 		; main procedure definition
	ASSUME 	CS: COD1, DS: DATE, SS: STAC, ES: NOTHING
	PUSH	DS 			;prepare stack
	SUB 	AX, AX 		;to return
	PUSH	AX 			; to DOS
	MOV 	AX, DATE 	; load register
	MOV 	DS, AX 		; DS with data segment
						; The instructions of the main procedure
	CALL PROCED 		; call procedure
						; Other instructions
	RET 				; coming back to DOS
PRPRINC ENDP 			; end procedure
COD1 ENDS 				; segment’s end
	END PRPRINC 		; end of the first module 