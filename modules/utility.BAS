REM $INCLUDE: 'modules\utility.bi'

FUNCTION binToDec# (bit$)
'bit$ = "101011101"

numberOfDigits = LEN(bit$)
FOR power = 0 TO numberOfDigits - 1
	currentDigit$ = MID$(bit$, numberOfDigits - power, 1)
	charValue = VAL(currentDigit$)
	decimal# = decimal# + charValue * (2 ^ power)
NEXT power

'FOR power = 0 TO LEN(bit$) - 1
'        decimal = decimal + VAL(MID$(bit$, LEN(bit$) - power, 1)) * (2 ^ power)
'NEXT

binToDec = decimal#

END FUNCTION

FUNCTION bitShiftLeft% (decimal%, shifts%)
	shifts% = 2 ^ shifts%
	bitShiftLeft% = decimal% * shifts%
END FUNCTION

FUNCTION bitShiftRight% (decimal%, shifts%)
	shifts% = 2 ^ shifts%
	bitShiftRight% = decimal% \ shifts%
END FUNCTION

SUB bubbleSort (array%())

DO
	swapped% = FALSE
	FOR i% = LBOUND(array%) + 1 TO UBOUND(array%)
		IF array%(i% - 1) > array%(i%) THEN
			SWAP array%(i% - 1), array%(i%)
			swapped% = True
		END IF
	NEXT
LOOP UNTIL NOT swapped%

END SUB

SUB center (text$)

	LOCATE , ((40 - LEN(text$)) / 2)
	PRINT text$

END SUB

FUNCTION decToBaseN$ (baseTen#, n%)
length% = LEN(STR$(baseTen#))
FOR digit% = 1 TO length%
	remainder% = baseTen# MOD n%
	trimmed$ = LTRIM$(CHR$(remainder% + 48 + (-7 * (remainder% > 9))))
	base16$ = trimmed$ + base16$

	baseTen# = baseTen# \ n%
	IF baseTen# = 0 THEN
		decToBaseN$ = base16$: EXIT FUNCTION
	END IF
NEXT
END FUNCTION

FUNCTION decToBin$ (decimal#)
	WHILE decimal# <> 0
		remainder% = decimal# MOD 2
		remainder$ = STR$(remainder%)
		binary$ = remainder$ + binary$
		decimal# = decimal# \ 2
	WEND
	decToBin$ = binary$
'baseTwo$ = SPACE$(100)
'baseTen# = 0

'INPUT "Decimal"; baseTen#

'FOR bit = 100 TO 1 STEP -1
'        MID$(baseTwo$, bit) = RIGHT$(STR$(baseTen# MOD 2), 1)
'        baseTen# = baseTen# \ 2
'        IF baseTen# = 0 THEN
'                baseTwo$ = MID$(baseTwo$, bit)
'                EXIT FOR
'        END IF
'NEXT

'PRINT baseTwo$
END FUNCTION

FUNCTION decToHex$ (baseTen#)
base16$ = ""

FOR digit% = 1 TO 50
	remainder% = baseTen# MOD 16
	SELECT CASE remainder%
		CASE IS = 10: base16$ = "A" + base16$
		CASE IS = 11: base16$ = "B" + base16$
		CASE IS = 12: base16$ = "C" + base16$
		CASE IS = 13: base16$ = "D" + base16$
		CASE IS = 14: base16$ = "E" + base16$
		CASE IS = 15: base16$ = "F" + base16$
		CASE ELSE: base16$ = LTRIM$(STR$(remainder%)) + base16$
	END SELECT
	   
	baseTen# = baseTen# \ 16
	IF baseTen# = 0 THEN
		decToHex$ = base16$: EXIT FUNCTION
	END IF
NEXT

END FUNCTION

FUNCTION fileExists% (file$)
	DIM inRegs AS RegTypeX, outRegs AS RegTypeX
	  
	api% = &H21 'main DOS api
	service% = &H4E00 'find first matching file

	ascizFile$ = file$ + CHR$(0)
	inRegs.ds = VARSEG(file$)
	inRegs.dx = SADD(file$)
	inRegs.cx = 15
	inRegs.ax = service%
	CALL INTERRUPTX(api%, inRegs, outRegs)

	fileExists% = (outRegs.dx = 0)
END FUNCTION

SUB genFat
' Creates a fat include of all qcumber modules.  Dependent on directory
'structure of the Qcumber project.

DIM declares(100) AS STRING
DIM include(4) AS STRING
DIM postInclude(0) AS STRING

' Content layed out in this order
include(0) = "commons.bi"
include(1) = "u$er.bi"
include(2) = "graphic.bi"
include(3) = "arrange.bi"
include(4) = "utility.bi"
' qcumber.bi declares
postInclude(0) = "commons.bas"

' Open qcumber.bi and grab the DECLAREs
OPEN "qcumber.bi" FOR INPUT AS #1
DO UNTIL EOF(1)
	LINE INPUT #1, line$
	IF NOT (MID$(line$, 1, 3) = "REM" OR MID$(line$, 1, 1) = "`") THEN
		declares(i%) = line$
		i% = i% + 1
	END IF
LOOP
CLOSE #1

OPEN "qcumber.fat" FOR OUTPUT AS #1

' Now transfer the content of each include to qcumber.fat; order matters
max% = UBOUND(include)
FOR i% = 0 TO max%
	OPEN "modules\" + include(i%) FOR INPUT AS #2
	DO UNTIL EOF(2)
		LINE INPUT #2, line$
		PRINT #1, line$
	LOOP
	CLOSE #2
NEXT

' qcumber.bi declarations
max% = UBOUND(declares)
FOR i% = 0 TO max%
	PRINT #1, declares(i%)
NEXT

' Post declaration includes
max% = UBOUND(postInclude)
FOR i% = 0 TO max%
	OPEN "modules\" + postInclude(i%) FOR INPUT AS #2
	DO UNTIL EOF(2)
		LINE INPUT #2, line$
		PRINT #1, line$
	LOOP
	CLOSE #2
NEXT

CLOSE #1

END SUB

FUNCTION getBit% (decimal%, position%)
	'TODO fix me!
	mask% = bitShiftLeft%(1, position%)
	getBit% = bitShiftRight%(decimal% AND mask%, position%)
END FUNCTION

FUNCTION getConfig$ (key$)
value$ = getIfHasConfig$(key$)

IF toBool%(value$) THEN
	getConfig$ = value$
  ELSE
	logit "Config key " + key$ + " not found.", "getConfig()", "UTILITY", -1
	CLOSE #1
	ERROR 255
END IF

CLOSE #1
END FUNCTION

FUNCTION getIfHasConfig$ (key$)
file$ = "prog.ini"
delim$ = "="
comment$ = "#"

OPEN file$ FOR INPUT AS #1

line$ = ""
i% = 0
length% = 0
DO UNTIL EOF(1) OR k$ = key$
	k$ = ""
	LINE INPUT #1, line$
	length% = LEN(line$)
			PRINT line$
	IF MID$(line$, 1, 1) <> comment$ THEN
		FOR i% = 1 TO length%
			char$ = MID$(line$, i%, 1)
			
			IF char$ = delim$ THEN EXIT FOR
		 
			k$ = k$ + char$
		NEXT
	END IF
LOOP
CLOSE #1

IF k$ = key$ THEN
	getIfHasConfig$ = MID$(line$, i% + 1, length%)
  ELSE
	getIfHasConfig$ = CHR$(0)
END IF

END FUNCTION

SUB hold (delay%)
'Approximate 1/19s * n delay

	DEF SEG = 0
	POKE (1132), 0 'reset

	DO: LOOP UNTIL peekTick% > delay%

	DEF SEG
END SUB

FUNCTION isNil% (value$)
	isNil% = (value$ = CHR$(0))
END FUNCTION

SUB logit (message$, context$, module$, isError%)
	IF isError% THEN level$ = "ERROR" ELSE level$ = "i"

	OPEN "qcumber.log" FOR APPEND AS #255
	PRINT #255, USING "[&] & { &: & @ &: &"; level$; message$; DATE$; TIME$; module$; context$
	CLOSE #255
END SUB

SUB nullify (value$)
	value$ = CHR$(0)
END SUB

FUNCTION peekTick%
	' Each tick is ~ 1/19 seconds; ~ 13.5 seconds per (0 - 255) cycle.
	'Found at memory location 0:1132 (segment:offset)

	DEF SEG = 0
	peekTick% = PEEK(1132)

END FUNCTION

SUB teardownTest
	CLS : SCREEN 0: WIDTH 80, 25
END SUB

FUNCTION toBool% (s$)
	s$ = UCASE$(s$)

	IF s$ = "TRUE" THEN
		toBool% = -1
	  ELSEIF s$ = "FALSE" THEN
		toBool% = 0
	  ELSEIF VAL("1" + s$) = 1 AND LEN(s$) > 1 THEN
		toBool% = -1
	  ELSEIF VAL(s$) > 0 THEN
		toBool% = -1
	  ELSE
		toBool% = 0
	END IF
END FUNCTION

