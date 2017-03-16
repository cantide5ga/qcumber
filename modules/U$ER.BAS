DECLARE FUNCTION isPressed% (button AS ANY)
REM $INCLUDE: 'modules\commons.bi'
REM $INCLUDE: 'modules\u$er.bi'

REM $INCLUDE: 'modules\commons.bas'

'cleaned% = isPressed%(t.KeyHandlerCleanUp): SYSTEM

FUNCTION isPressed% (button AS JoyType)
	STATIC kbControl%(), kbMatrix%(), initialized%
	IF NOT initialized% THEN GOSUB initIsPressed

	k% = button.value
	' Turn off interrupt
	IF k% = 0 THEN
		DEF SEG = VARSEG(kbControl%(0))
		CALL ABSOLUTE(3)
		DEF SEG
		EXIT FUNCTION
	ELSE ' Return status
		isPressed% = (-kbMatrix%(k%) * NOT (k% > 128 OR k% < 1)) = 1
	END IF

EXIT FUNCTION

initIsPressed:
 DIM kbControl%(128)
 DIM kbMatrix%(128)
 code$ = ""
 code$ = code$ + "E91D00E93C00000000000000000000000000000000000000000000000000"
 code$ = code$ + "00001E31C08ED8BE24000E07BF1400FCA5A58CC38EC0BF2400B85600FAAB"
 code$ = code$ + "89D8ABFB1FCB1E31C08EC0BF2400BE14000E1FFCFAA5A5FB1FCBFB9C5053"
 code$ = code$ + "51521E560657E460B401A8807404B400247FD0E088C3B700B0002E031E12"
 code$ = code$ + "002E8E1E100086E08907E4610C82E661247FE661B020E6205F075E1F5A59"
 code$ = code$ + "5B589DCF"
 DEF SEG = VARSEG(kbControl%(0))
 FOR i% = 0 TO 155                     ' Load ASM
	 d% = VAL("&h" + MID$(code$, i% * 2 + 1, 2))
	 POKE VARPTR(kbControl%(0)) + i%, d%
 NEXT i%
 i& = 16       ' I think this stuff connects the interrupt with kbmatrix%()
 n& = VARSEG(kbMatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 n& = VARPTR(kbMatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE i&, l&: POKE i& + 1, h&: i& = i& + 2
 
 DEF SEG = VARSEG(kbControl%(0))
 CALL ABSOLUTE(0)                     ' Run interrupt
 DEF SEG

 initialized% = True: RETURN

END FUNCTION

