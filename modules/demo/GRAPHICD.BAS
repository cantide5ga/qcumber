DECLARE SUB scroll (direction AS ANY)
DECLARE SUB move (guy AS ANY, sprite%())
DECLARE FUNCTION resource$ (file$)
REM $INCLUDE: 'modules\commons.bi'
REM $INCLUDE: 'modules\graphic.bi'
REM $INCLUDE: 'modules\commons.bas'

CONST RESOURCES = "modules\demo\"

setup:
CLS : SCREEN 7: pageTo t.Buffer
RANDOMIZE TIMER
'FOR i% = 0 TO 750
'        LINE (INT(500 * RND - 100), INT(400 * RND - 100))-STEP(INT(50 * RND), INT(40 * RND)), INT(16 * RND), BF
'        CIRCLE (INT(320 * RND), INT(200 * RND)), INT(36 * RND + 5), INT(16 * RND)
'NEXT
'bSaveScreen resource$("backdrop.bsv")
'load4BitBmp resource$("demo.bmp"), True
'bSaveScreen "demo.bsv"
bLoadScreen resource$("demo.bsv")

DIM pose1 AS ImageType
DIM pose2 AS ImageType
specImage7 pose1, 0, 0, 15, 15
specImage7 pose2, 16, 0, 31, 15
DIM sprite%(SpriteArr)
buildSprite pose1, pose2, sprite%(), 0

pageTo t.ViewPage
bLoadScreen resource$("backdrop.bsv")

GOSUB demo1
GOSUB demo2
GOSUB demo3
SYSTEM

demo1:
	fixAttribDef

	DIM colour AS ColorType
	specColor colour, 255 \ 4, 164 \ 4, 64 \ 4
	setColor 1, colour
	specColor colour, 63, 63, 63
	setColor 3, colour
	specColor colour, 10, 10, 10
	setColor 2, colour

	FOR i% = 0 TO 100
		frame% = INT(3 * RND)
		offSet% = DefaultArr * frame% * 2 - (frame% > 0)
		placeSprite INT(305 * RND), INT(184 * RND), sprite%(), 0, offSet%
	NEXT
RETURN

demo2:
		decorPrint "Lorem ipsum dolor sit amet", 15, 5
		COLOR 7: PRINT CHR$(24) + " initialized"
		LOCATE 3: decorPrint "Dius aute irure dolor in", 15, 5
		decorPrint "?!'*,.+-/", 15, 5
		COLOR 7: PRINT CHR$(24) + " cached"
		LOCATE 6: decorPrint "sed do eiusmod tempor", 11, 1
		COLOR 7: PRINT CHR$(24) + " cache invalidated due to new colors;  re-initialized"
RETURN

demo3:
		pageTo t.Buffer ': bLoadScreen resource$("backdrop.bsv")

RANDOMIZE TIMER

COLOR , 4
COLOR 15

FOR i% = 1 TO 23
	FOR j% = 0 TO 19
		PRINT CHR$(193); :
		PRINT CHR$(194); :
	NEXT
	IF NOT (i% MOD 2) THEN PRINT CHR$(196); :
NEXT

FOR y% = 3 TO 199 STEP 8
	FOR x% = 2 TO 319 STEP 20
		IF INT(2 * RND - 1) THEN PAINT (x%, y%), 6, 15
	NEXT
NEXT

LINE (0, 180)-(319, 199), 10, BF
FOR y% = 180 TO 199
	FOR x% = 0 TO 319
		IF INT(2 * RND - 1) THEN PSET (x%, y%), 2
NEXT: NEXT
		'scroll t.Leftward
		'scroll t.Rightward
		'scroll t.Rightward
		'scroll t.Upward
		'scroll t.Downward
	   
		scrollCrop t.Upward, 5, 5, 190, 190, 12
		scrollCrop t.Leftward, 5, 5, 190, 190, 12
		scrollCrop t.Downward, 5, 5, 190, 190, 12
		scrollCrop t.Leftward, 5, 5, 190, 190, 12
	   

RETURN

FUNCTION resource$ (file$)
		resource$ = RESOURCES + file$
END FUNCTION

