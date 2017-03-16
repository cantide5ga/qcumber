DECLARE SUB pageTo (page AS ANY)
DECLARE SUB setColor (attribute%, colour AS ANY)
DECLARE FUNCTION animate% (frame%, cycles%, goingLeft%, spriteFrameRate%)
DECLARE SUB bLoadImage (sourceFile AS STRING, image AS ANY)
DECLARE SUB bLoadScreen (file$)
DECLARE SUB specImage7 (result AS ANY, x1%, y1%, x2%, y2%)
DECLARE SUB bSaveImage (file AS STRING, image AS ANY)
DECLARE SUB specImage (image AS ANY, x1%, y1%, x2%, y2%, bpp%, p%, dat AS ANY)
DECLARE SUB buildSprite (pose1 AS ANY, pose2 AS ANY, result%(), atIndex%)
DECLARE SUB createMask (image AS ANY)
DECLARE SUB pageToPrevious ()
DECLARE FUNCTION dePlanarize% (x%, y%, w%)
DECLARE FUNCTION getRgb$ (attrib%, colour AS ANY)
DECLARE SUB specColor (colour AS ANY, r%, g%, b%)
DECLARE SUB planarize (index%, w%, p AS ANY)
DECLARE FUNCTION moveX% (direction AS ANY, x%, y%, pelSkip!, block%())
DECLARE FUNCTION moveY% (direction AS ANY, x%, y%, pelSkip!, block%())
DECLARE SUB scrollCrop (direction AS ANY, x1%, y1%, x2%, y2%, clipSize%)
DECLARE SUB logit (message$, context$, module$, isError%)
REM $INCLUDE: 'modules\commons.bi'
REM $INCLUDE: 'modules\graphic.bi'
REM $INCLUDE: 'modules\utility.bi'

REM $INCLUDE: 'modules\commons.bas'

CONST ScreenClipSize% = 8
CONST HScreenClipSize% = 14
CONST VScreenClipSize% = 10
' Used for occasions where a procedure will need to recall the page on
'procedure invocation if any logic within it were to switch it
DIM SHARED previousPage%
DIM SHARED currentPage%

FUNCTION animate% (frame%, cycles%, goingLeft%, spriteFrameRate%)
	' If spriteFrameRate% = 0, use default
	spriteFrameRate% = -CyclesPerSpriteFrame * (spriteFrameRate% = 0) + spriteFrameRate%
	   
	' Iterate counter; reset if complete cycle
	cycles% = -(cycles% + 1) * (cycles% <= spriteFrameRate%)
	  
	' Switch frames for animation
	IF cycles% = spriteFrameRate% THEN
		frame% = Frame1 - (Frame2 * (frame% = Frame1 OR frame% = Frame1Left))
		frame% = frame% + -LeftFramesOffset * goingLeft%
		' Array lower bound is 0, so 1 needs be added
		frame% = frame% - (frame% = LeftFramesOffset%)
	END IF
	animate% = frame%
END FUNCTION

SUB bLoadImage (sourceFile AS STRING, image AS ImageType)

	DIM page(image.arrSize) AS INTEGER

	DEF SEG = VARSEG(page(0))
	BLOAD sourceFile, VARPTR(page(0))
	DEF SEG

	PUT (image.x1, image.y1), page, PSET

END SUB

SUB bLoadScreen (file$)

	DIM image AS ImageType
	specImage7 image, 0, 0, 319, 199
	CALL bLoadImage(file$, image)

END SUB

SUB bSaveImage (file AS STRING, image AS ImageType)

	DIM page%(image.arrSize)
	GET (image.x1, image.y1)-(image.x2, image.y2), page%
	DEF SEG = VARSEG(page%(0))
	BSAVE file, VARPTR(page%(0)), UBOUND(page%) * 2
	DEF SEG

END SUB

SUB bSaveScreen (file AS STRING)
	DIM image AS ImageType
	specImage image, 0, 0, 319, 199, 4, 1, t.Integers
	CALL bSaveImage(file, image)
END SUB

SUB buildSprite (pose1 AS ImageType, pose2 AS ImageType, result%(), atIndex%)
	' Given two ImageType image definitions, assign frames, masks, and
	'corresponding left facing sprites.  result%[] should be dimensioned
	'with SpriteArr% size.
	   
	DIM pose1Arr%(pose1.arrSize)
	DIM pose2Arr%(pose2.arrSize)
	GET (pose1.x1, pose1.y1)-(pose1.x2, pose1.y2), pose1Arr%
	GET (pose2.x1, pose2.y1)-(pose2.x2, pose2.y2), pose2Arr%

	pageTo t.Buffer
	   
	DIM mask AS ImageType
	specImage7 mask, 0, 0, 15, 15
	   
	' Animation frame 1
	PUT (0, 0), pose1Arr%, PSET
	GET (0, 0)-(15, 15), result%(Frame1 + atIndex%)
	createMask mask
	GET (0, 0)-(15, 15), result%(Frame1Mask + atIndex%)
	PUT (0, 0), pose1Arr%, PSET
	'flip vertically
	DIM row%(15)
	FOR y% = 0 TO 15
		FOR x% = 0 TO 15
			row%(x%) = POINT(x%, y%)
		NEXT
		FOR i% = 0 TO 15
			PSET (i%, y%), row%(15 - i%)
		NEXT
	NEXT
	GET (0, 0)-(15, 15), result%(Frame1Left + atIndex%)
	createMask mask
	GET (0, 0)-(15, 15), result%(Frame1LeftMask + atIndex%)

	' Animation frame 2
	PUT (0, 0), pose2Arr%, PSET
	GET (0, 0)-(15, 15), result%(Frame2 + atIndex%)
	createMask mask
	GET (0, 0)-(15, 15), result%(Frame2Mask + atIndex%)
	PUT (0, 0), pose2Arr%, PSET
	'flip vertically
	FOR y% = 0 TO 15
		FOR x% = 0 TO 15
			row%(x%) = POINT(x%, y%)
		NEXT
		FOR i% = 0 TO 15
			PSET (i%, y%), row%(15 - i%)
		NEXT
	NEXT
	GET (0, 0)-(15, 15), result%(Frame2Left + atIndex%)
	createMask mask
	GET (0, 0)-(15, 15), result%(Frame2LeftMask + atIndex%)
END SUB

SUB createMask (image AS ImageType)

FOR y = image.y1 TO image.y2
	FOR x = image.x1 TO image.x2
		IF POINT(x, y) = 0 THEN
			PSET (x, y), 15
		   ELSE
			PSET (x, y), 0
		END IF
NEXT: NEXT
 
END SUB

SUB decorPrint (text$, colour%, shadowColor%)
STATIC font%()
STATIC cached%
STATIC initialized%
IF NOT initialized% THEN GOSUB initDecorPrint
IF cached% <> colour% THEN GOSUB initDecorPrint

y% = CSRLIN

FOR x% = POS(0) TO POS(0) + LEN(text$) - 1
	n% = n% + 1
	 
	x1% = x% * 8 + x% - 9
	y1% = y% * 8 - 8
	 
	char% = ASC(MID$(UCASE$(text$), n%, 1))
	SELECT CASE char%
		' A - Z
		CASE 65 TO 90: PUT (x1%, y1%), font%((char% - 65) * 34), PSET
		' 0 - 9
		CASE 48 TO 57: PUT (x1%, y1%), font%((char% - 48) * 34 + 884), PSET
		' ?
		CASE 63: PUT (x1%, y1%), font%(1224), PSET
		' !
		CASE 33: PUT (x1%, y1%), font%(1258), PSET
		' apostrophe
		CASE 39: PUT (x1%, y1%), font%(1292), PSET
		' comma
		CASE 44: PUT (x1%, y1%), font%(1360), PSET
		' period
		CASE 46: PUT (x1%, y1%), font%(1394), PSET
		' +
		CASE 43: PUT (x1%, y1%), font%(1428), PSET
		' -
		CASE 45: PUT (x1%, y1%), font%(1462), PSET
		' /
		CASE 47: PUT (x1%, y1%), font%(1496), PSET
		' space
		CASE 32: PUT (x1%, y1%), font%(2006), PSET
	END SELECT
NEXT

LOCATE y% + 1: EXIT SUB

initDecorPrint:
	REDIM font%(2039)
	CALL pageTo(t.Buffer): CLS

	COLOR shadowColor%
	' Serifized
	PRINT " A B C D E F G H I J K L M N O P Q R S T"
	PRINT " U V W X Y Z 0 1 2 3 4 5 6 7 8 9 ? ! ' *"
	' NOT serifized
	PRINT " , . + - / * * * * * * * * * * * * * *"

	' Serifize
	FOR x% = 0 TO 318: PSET (x%, 0), POINT(x% + 1, 0): NEXT
	FOR x% = 0 TO 318: PSET (x%, 6), POINT(x% + 1, 6): NEXT
	FOR x% = 0 TO 318: PSET (x%, 8), POINT(x% + 1, 8): NEXT
	FOR x% = 0 TO 318: PSET (x%, 14), POINT(x% + 1, 14): NEXT

	' Shadow
	FOR y% = 0 TO 30
		FOR x% = 0 TO 318
			IF POINT(x%, y%) = shadowColor% THEN PSET (x% - 1, y%), colour%
	NEXT: NEXT

	index% = 0
	FOR y% = 0 TO 16 STEP 8
		FOR x% = 6 TO 319 STEP 16
			GET (x%, y%)-STEP(8, 7), font%(index%)
			index% = index% + 34
	NEXT: NEXT
	pageToPrevious
initialized% = True: cached% = colour%: RETURN

END SUB

FUNCTION dePlanarize% (x%, y%, w%)
	dePlanarize% = x% + (y% * w%)
END FUNCTION

SUB fixAttribDef

' Simplify the process of creating a custom colourette by setting each Digital
'Analog Converter index the same as its attribute in SCREEN 7.  Thanks to
'TheBob.
DacPortByte = INP(&H3DA)
FOR attribute = 0 TO 15
	OUT &H3C0, attribute 'color attribute
	OUT &H3C0, attribute 'align index with attribute
NEXT attribute
	OUT &H3C0, 32 'close DAC port

END SUB

SUB flip
	PCOPY t.Buffer.value, t.ViewPage.value
END SUB

FUNCTION getRgb$ (attrib%, colour AS ColorType)

'Returns hex color code

OUT &H3C7, attrib%
	colour.r = INP(&H3C9)
	colour.g = INP(&H3C9)
	colour.b = INP(&H3C9)

r$ = HEX$(colour.r): g$ = HEX$(colour.g): b$ = HEX$(colour.b)
IF LEN(r$) < 2 THEN r$ = "0" + r$
IF LEN(g$) < 2 THEN g$ = "0" + g$
IF LEN(b$) < 2 THEN b$ = "0" + b$
getRgb$ = r$ + g$ + b$

END FUNCTION

SUB load4BitBmp (file AS STRING, fullDecode%)

'FIXME
'IF NOT fileExists%(file) THEN
'    logit file + " not found.", "load4BitBmp()", "GRAPHIC", True
'    ERROR 255
'END IF

OPEN file FOR BINARY AS #1
' Loads Windows 16 color bitmaps natively in SCREEN 7.  Colors are not
'limited to the Windows 16 color palette or SCREEN 7 standard scheme.
'Specifying fullDecode to TRUE enables signature validation and palette
'decoding.

'IF fullDecode% THEN
	DIM signature AS STRING * 2
	GET #1, , signature ' should be 'BM'
	GET #1, 29, bpp% ' verifies 4-bit image
		IF signature <> "BM" THEN
			logit file + " is not a valid BMP file.", "load4BitBmp()", "GRAPHIC", True
			ERROR 255
		END IF
		IF bpp% <> 4 THEN
			logit file + " is not a 16 color bitmap.", "load4BitBmp()", "GRAPHIC", True
			ERROR 255
		END IF
'END IF

GET #1, 19, w& ' bitmap width byte position as a 32-bit dword
GET #1, 23, h& ' bitmap height byte postion as a 32-bit dword
h& = h& - 1 ' fix for 0 based coordinate

IF fullDecode% THEN
	' Each color definition is 4 bytes per attribute; the fourth byte is
	'not used for this implementation.  Make sure DAC index is aligned
	'with color attribute; see fixAttribDef().
	DIM b AS STRING * 1
	DIM g AS STRING * 1
	DIM r AS STRING * 1

	SEEK #1, 55 ' byte position of color table

	DIM colour AS ColorType
	FOR attribute% = 0 TO 15
		GET #1, , b: GET #1, , g: GET #1, , r
		SEEK #1, SEEK(1) + 1 ' skip reserved fourth byte
	   
		CALL specColor(colour, ASC(r) \ 4, ASC(g) \ 4, ASC(b) \ 4)
		CALL setColor(attribute%, colour)
	NEXT
END IF

' From here on is the pixel array.  Each color attribute is expressed as a
'nibble (4-bits).  Two nibbles exist in a standard byte octet in real order.
SEEK #1, 119 ' jump to pel data
DIM byte AS STRING * 1

FOR y% = h& TO 0 STEP -1 ' because the pixels are stored upside down
	FOR x% = 0 TO w& - 1 STEP 2
		GET #1, , byte
		hiNibble% = ASC(byte) \ &H10 '16
		loNibble% = ASC(byte) AND &HF '15

		PSET (x%, y%), hiNibble%
		PSET (x% + 1, y%), loNibble%
	NEXT
	
	' Skip the standard BMP padding
	SEEK #1, SEEK(1) + ((32 - ((w& / 2 * 8) MOD 32)) \ 8) MOD 4
		' ^ This breaks down as follows:
		'       w& = bmp_width
		'       bmp_width / 2 = total_bytes (2 nibbles per byte)
		'       total_bytes * 8 = total_bits (an octet of bits in a
		'                                     byte)
		'       total_bits % dword = free_bits (total_bits / 32_bits
		'                                       gives the number of
		'                                       dwords; those bits
		'                                       left need to be padded
		'                                       to form full dwords)
		'       32 - free_bits = pad_bits
		'       pad_bits \ 8 = pad_bytes
		'       pad_bytes % 4 = pad_bytes (if pad_bytes is a multiple
		'                                  of 4, then no padding is
		'                                  needed)
NEXT

CLOSE #1

END SUB

SUB loadSprite (code$, sprite%(), atIndex%)
	STATIC initialized%
	pageTo t.SpriteSheet
	IF NOT initialized THEN GOSUB initLoadSprite
	
	DIM planarized AS PlanarType
	planarize ASC(code$) * 2, 20, planarized
	x% = planarized.x * 16
	y% = planarized.y * 16
	DIM pose1 AS ImageType
	DIM pose2 AS ImageType
	specImage7 pose1, x%, y%, x% + 15, y% + 15
	specImage7 pose2, x% + 16, y%, x% + 31, y% + 15
	buildSprite pose1, pose2, sprite%(), atIndex%
EXIT SUB

initLoadSprite:
	bLoadScreen (getConfig$("sprite_rsrc"))
	initialized = True: RETURN
END SUB

FUNCTION moveX% (direction AS DirectionType, x%, y%, pelSkip!, block%())
	' Increments/decrements x% along the axis up to the pixel skip amount,
	'returning False if a collision occurs.
	   
	goingRight% = (direction.value = Rightward)
	ay% = (y% + 1) \ UnitWidth
	by% = (y% - 1) \ UnitWidth + 1
	pelSkip! = pelSkip! - (pelSkip! < 1)
	  
	FOR i% = 0 TO pelSkip!
		j% = x% - (i% XOR goingRight%) + goingRight%
		ax% = j% \ UnitWidth - goingRight%
		IF block%(ax%, ay%) OR block%(ax%, by%) THEN : EXIT FOR
	NEXT
	moveX% = NOT i% < pelSkip!
	x% = j%
END FUNCTION

FUNCTION moveY% (direction AS DirectionType, x%, y%, pelSkip!, block%())
	' Increments/decrements y% along the axis up to the pixel skip amount,
	'returning False if a collision occurs.
		  
	goingDown% = (direction.value = Downward)
	ax% = (x% + 1) \ UnitHeight
	bx% = (x% - 1) \ UnitHeight + 1
	pelSkip! = pelSkip! - (pelSkip! < 1)

	FOR i% = 0 TO pelSkip!
		j% = y% - (i% XOR goingDown%) + goingDown%
		ay% = j% \ UnitHeight - goingDown%
		IF ay% < SpriteYConvertedMin THEN EXIT FOR
		IF block%(ax%, ay%) OR block%(bx%, ay%) THEN EXIT FOR
	NEXT
	moveY% = NOT i% < pelSkip!
	y% = j%
END FUNCTION

SUB nesPalPick (attribute%, hue AS HueType, tint%)
	'Thanks to loopy for the RGB values of the NES palette.
	'TODO link
   
	IF tint% < 0 THEN tint% = 0
	IF tint% > 3 THEN tint% = 3

	DIM colour AS ColorType

	SELECT CASE hue.value
	CASE Gray:
		IF tint% = 0 THEN specColor colour, 117, 117, 117
		IF tint% = 1 THEN specColor colour, 188, 188, 188
		IF tint% = 2 THEN specColor colour, 255, 255, 255
		IF tint% = 3 THEN specColor colour, 255, 255, 255
	CASE Indigo:
		IF tint% = 0 THEN specColor colour, 39, 27, 143
		IF tint% = 1 THEN specColor colour, 0, 115, 239
		IF tint% = 2 THEN specColor colour, 63, 191, 255
		IF tint% = 3 THEN specColor colour, 171, 231, 255
	CASE Blue:
		IF tint% = 0 THEN specColor colour, 0, 0, 171
		IF tint% = 1 THEN specColor colour, 35, 59, 239
		IF tint% = 2 THEN specColor colour, 95, 151, 255
		IF tint% = 3 THEN specColor colour, 199, 215, 255
	CASE Violet:
		IF tint% = 0 THEN specColor colour, 71, 0, 159
		IF tint% = 1 THEN specColor colour, 131, 0, 243
		IF tint% = 2 THEN specColor colour, 167, 139, 253
		IF tint% = 3 THEN specColor colour, 215, 203, 255
	CASE Pink:
		IF tint% = 0 THEN specColor colour, 143, 0, 119
		IF tint% = 1 THEN specColor colour, 191, 0, 191
		IF tint% = 2 THEN specColor colour, 247, 123, 255
		IF tint% = 3 THEN specColor colour, 255, 199, 255
	CASE Red:
		IF tint% = 0 THEN specColor colour, 171, 0, 19
		IF tint% = 1 THEN specColor colour, 231, 0, 91
		IF tint% = 2 THEN specColor colour, 255, 119, 183
		IF tint% = 3 THEN specColor colour, 255, 199, 219
	CASE Orange:
		IF tint% = 0 THEN specColor colour, 167, 0, 0
		IF tint% = 1 THEN specColor colour, 219, 43, 0
		IF tint% = 2 THEN specColor colour, 255, 119, 99
		IF tint% = 3 THEN specColor colour, 255, 191, 179
	CASE Burnt:
		IF tint% = 0 THEN specColor colour, 127, 11, 0
		IF tint% = 1 THEN specColor colour, 203, 79, 15
		IF tint% = 2 THEN specColor colour, 255, 155, 59
		IF tint% = 3 THEN specColor colour, 255, 219, 171
	CASE Brown:
		IF tint% = 0 THEN specColor colour, 67, 47, 0
		IF tint% = 1 THEN specColor colour, 139, 115, 0
		IF tint% = 2 THEN specColor colour, 243, 191, 63
		IF tint% = 3 THEN specColor colour, 255, 231, 163
	CASE Forest:
		IF tint% = 0 THEN specColor colour, 0, 71, 0
		IF tint% = 1 THEN specColor colour, 0, 151, 0
		IF tint% = 2 THEN specColor colour, 131, 211, 19
		IF tint% = 3 THEN specColor colour, 227, 255, 163
	CASE Green:
		IF tint% = 0 THEN specColor colour, 0, 81, 0
		IF tint% = 1 THEN specColor colour, 0, 171, 0
		IF tint% = 2 THEN specColor colour, 79, 223, 75
		IF tint% = 3 THEN specColor colour, 171, 243, 191
	CASE Celadon:
		IF tint% = 0 THEN specColor colour, 0, 63, 23
		IF tint% = 1 THEN specColor colour, 0, 147, 59
		IF tint% = 2 THEN specColor colour, 88, 248, 152
		IF tint% = 3 THEN specColor colour, 179, 255, 243
	CASE Cadet:
		IF tint% = 0 THEN specColor colour, 27, 63, 95
		IF tint% = 1 THEN specColor colour, 0, 131, 139
		IF tint% = 2 THEN specColor colour, 0, 235, 219
		IF tint% = 3 THEN specColor colour, 159, 255, 243
	CASE ELSE: specColor colour, 0, 0, 0
	END SELECT

	colour.r% = colour.r% \ 4
	colour.g% = colour.g% \ 4
	colour.b% = colour.b% \ 4
   
	setColor attribute%, colour
END SUB

SUB pageTo (page AS PageType)
	previousPage = currentPage
	SCREEN , , page.value, 0
	currentPage = page.value
END SUB

SUB pageToPrevious
	SCREEN , , previousPage, 0
END SUB

SUB placeSprite (x%, y%, sprite%(), atIndex%, frame%)
	offset% = frame%
	offset% = offset% + atIndex%
	maskOffset% = frame% + DefaultArr - (frame% = 0)
	maskOffset% = maskOffset% + atIndex%
	PUT (x%, y%), sprite%(maskOffset%), AND
	PUT (x%, y%), sprite%(offset%), OR
END SUB

SUB placeTile (code$, x%, y%)
	STATIC initialized%, tile%(), planarized AS PlanarType
	pageTo t.TileSheet
	IF NOT initialized% THEN GOSUB initPlaceTile

	planarize ASC(code$), 20, planarized

	GET (planarized.x * 16, planarized.y * 16)-STEP(15, 15), tile%
	pageTo t.Buffer
	PUT (x%, y%), tile%, PSET
EXIT SUB

initPlaceTile:
	DIM tile%(DefaultArr)
	bLoadScreen (getConfig$("tile_rsrc"))
	initialized% = True: RETURN
END SUB

SUB planarize (index%, w%, p AS PlanarType)
	p.x% = (index% MOD w%) '- 1
	p.y% = index% \ w%
END SUB

SUB scroll (direction AS DirectionType)

CALL scrollCrop(direction, 0, 0, 319, 199, ScreenClipSize)

END SUB

SUB scrollCrop (direction AS DirectionType, x1%, y1%, x2%, y2%, clipSize%)

' Executes a full copy from BUFFER at the end to accomodate uneven
'divisible clipSize% (likely)

DIM img AS ImageType
DIM cropToAdd(dynamic%) AS INTEGER
DIM cropToPan(dynamic%) AS INTEGER

IF direction.value = Leftward THEN GOSUB scrollLeft
IF direction.value = Rightward THEN GOSUB scrollRight
IF direction.value = Upward THEN GOSUB scrollUp
IF direction.value = Downward THEN GOSUB scrollDown

scrollRight:
pannedOutStartVertexX% = x1% + clipSize%
pannedOutEndVertexX% = x2% - clipSize%
clipHeight% = y2% - y1%
initBufferVertexX% = pannedOutEndVertexX%

specImage7 img, x1%, y1%, x1% + clipSize%, y2%
REDIM cropToAdd(img.arrSize%) AS INTEGER
specImage7 img, x1%, y1%, x2% - clipSize%, y2%
REDIM cropToPan(img.arrSize%) AS INTEGER

FOR bufferStartVertexX% = initBufferVertexX% TO x1% STEP -clipSize%
	pageTo t.Buffer
	GET (bufferStartVertexX%, y1%)-STEP(clipSize%, clipHeight%), cropToAdd
	pageTo t.ViewPage
	GET (x1%, y1%)-(pannedOutEndVertexX%, y2%), cropToPan

	SCREEN , , 7, 0
	PUT (x1%, y1%), cropToAdd, PSET
	PUT (pannedOutStartVertexX%, y1%), cropToPan, PSET
	PCOPY 7, 0
NEXT
GOSUB finalize
EXIT SUB

scrollLeft:
pannedOutStartVertexX% = x1% + clipSize%
pannedInStartVertexX% = x2% - clipSize%
clipHeight% = y2% - y1%

specImage7 img, x1%, y1%, x1% + clipSize%, y2%
REDIM cropToAdd(img.arrSize%) AS INTEGER
specImage7 img, x1%, y1%, x2% - clipSize%, y2%
REDIM cropToPan(img.arrSize%) AS INTEGER

FOR bufferStartVertexX% = x1% TO x2% STEP clipSize%
	pageTo t.Buffer
	GET (bufferStartVertexX%, y1%)-STEP(clipSize%, clipHeight%), cropToAdd
	pageTo t.ViewPage
	GET (pannedOutStartVertexX%, y1%)-(x2%, y2%), cropToPan

	SCREEN , , 7, 0
	PUT (pannedInStartVertexX%, y1%), cropToAdd, PSET
	PUT (x1%, y1%), cropToPan, PSET
	PCOPY 7, 0
NEXT
GOSUB finalize
EXIT SUB

scrollUp:
pannedOutStartVertexY% = y1% + clipSize%
pannedInStartVertexY% = y2% - clipSize%
clipWidth% = x2% - x1%

specImage7 img, x1%, y1%, x2%, y1% + clipSize%
REDIM cropToAdd(img.arrSize%) AS INTEGER
specImage7 img, x1%, y1%, x2%, y2% - clipSize%
REDIM cropToPan(img.arrSize%) AS INTEGER

FOR bufferStartVertexY% = y1% TO y2% STEP clipSize%
	pageTo t.Buffer
	GET (x1%, bufferStartVertexY%)-STEP(clipWidth%, clipSize%), cropToAdd
	pageTo t.ViewPage
	GET (x1%, pannedOutStartVertexY%)-(x2%, y2%), cropToPan

	SCREEN , , 7, 0
	PUT (x1%, pannedInStartVertexY%), cropToAdd, PSET
	PUT (x1%, y1%), cropToPan, PSET
	PCOPY 7, 0
NEXT
GOSUB finalize
EXIT SUB

scrollDown:
toPanOutStartVertexY% = y1% + clipSize%
toPanOutEndVertexY% = y2% - clipSize%
clipWidth% = x2% - x1%
initBufferVertexY% = toPanOutEndVertexY%

specImage7 img, x1%, y1%, x2%, y1% + clipSize%
REDIM cropToAdd(img.arrSize%) AS INTEGER
specImage7 img, x1%, y1%, x2%, y2% - clipSize%
REDIM cropToPan(img.arrSize%) AS INTEGER

FOR bufferStartVertexY% = initBufferVertexY% TO y1% STEP -clipSize%
	pageTo t.Buffer
	GET (x1%, bufferStartVertexY%)-STEP(clipWidth%, clipSize%), cropToAdd
	pageTo t.ViewPage
	GET (x1%, y1%)-(x2%, toPanOutEndVertexY%), cropToPan

	SCREEN , , 7, 0
	PUT (x1%, y1%), cropToAdd, PSET
	PUT (x1%, toPanOutStartVertexY%), cropToPan, PSET
	PCOPY 7, 0
NEXT
GOSUB finalize
EXIT SUB

finalize:
	specImage7 img, x1%, y1%, x2%, y2%
	DIM all(img.arrSize%) AS INTEGER
	  
	pageTo t.Buffer
	GET (x1%, y1%)-(x2%, y2%), all
	pageTo t.ViewPage
   
	' Unexplained graphic slowness on back-to-back scrolls; try removing
	PUT (x1%, y1%), all, PSET
   
	ERASE cropToAdd
	ERASE cropToPan
	ERASE all

	RETURN

END SUB

SUB setColor (attribute%, colour AS ColorType)
' Normally, each RGB component is expressed as a value between 0 - 255. QBasic
'instead works only with an intensity range between 0 - 63; dividing normal
'component values by 4 yields the same result.

OUT &H3C8, attribute%
	OUT &H3C9, colour.r%
	OUT &H3C9, colour.g%
	OUT &H3C9, colour.b%

END SUB

SUB specColor (colour AS ColorType, r%, g%, b%)
	colour.r = r%
	colour.g = g%
	colour.b = b%
END SUB

SUB specImage (image AS ImageType, x1%, y1%, x2%, y2%, bpp%, p%, dat AS DataType)

image.x1 = x1%
image.x2 = x2%
image.y1 = y1%
image.y2 = y2%
image.bpp% = bpp%
image.p% = p%

image.arrType = dat
SELECT CASE image.arrType.value
	CASE t.Integers.value: bytesPerEl% = 2
	CASE t.Longs.value: bytesPerEl% = 4
	CASE t.SFloat.value: bytesPerEl% = 4
	CASE t.DFloat.value: bytesPerEl% = 8
END SELECT
size! = 4 + INT(((x2% - x1% + 1) * bpp% + 7) / 8) * p% * ((y2% - y1%) + 1)
size! = size! \ bytesPerEl%
size! = size! - 1

image.arrSize% = CINT(size!)

END SUB

SUB specImage7 (result AS ImageType, x1%, y1%, x2%, y2%)

	specImage result, x1%, y1%, x2%, y2%, 1, 4, t.Integers

END SUB

