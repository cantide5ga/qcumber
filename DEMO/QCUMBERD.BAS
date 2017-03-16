DECLARE SUB mock (SpriteResource$, TileResource$)
DECLARE SUB move (guy AS ANY, block%())

REM $INCLUDE: 'qcumber.fat'

CONST SPRITE0 = 0
CONST SPRITE1 = SpriteArr + 1
CONST SPRITE2 = SpriteArr * 2 + 1
CONST SPRITE3 = SpriteArr * 3 + 1
CONST SPRITE4 = SpriteArr * 4 + 1
CONST SPRITE5 = SpriteArr * 5 + 1
CONST RESTORER0 = Restorer
CONST RESTORER1 = SpriteArr + Restorer
CONST RESTORER2 = SpriteArr * 2 + Restorer
CONST RESTORER3 = SpriteArr * 3 + Restorer
CONST RESTORER4 = SpriteArr * 4 + Restorer
CONST RESTORER5 = SpriteArr * 5 + Restorer

setup:
	CLS : SCREEN 7: pageTo t.Buffer

	DIM sprite%(SpriteArr * 6)
	loadSprite CHR$(0), sprite%(), SPRITE0
	loadSprite CHR$(1), sprite%(), SPRITE1
	loadSprite CHR$(2), sprite%(), SPRITE2
	loadSprite CHR$(1), sprite%(), SPRITE3
	loadSprite CHR$(2), sprite%(), SPRITE4
	loadSprite CHR$(1), sprite%(), SPRITE5

	pageTo t.ViewPage

	GOSUB demo1
terminate

demo1:
DIM block%(19, 11)
DIM tile%(DefaultArr)
pageTo t.Buffer: CLS : PAINT (0, 0), 8, 8
FOR y% = 0 TO 11
	FOR x% = 0 TO 19
		READ block$
		IF block$ <> "." THEN
			block%(x%, y%) = True
			placeTile CHR$(VAL(block$)), x% * 16, y% * 16
		END IF
NEXT: NEXT
	   
DIM guy(5) AS SpatialType
' Initialize spatial values for each sprite; usually will be supplied by
'room data (NOSTORY.DAT)
FOR i% = 0 TO 5
	guy(i%).direction = t.Rightward
	guy(i%).pelSkip = 1
NEXT
guy(2).spriteFrameRate = 0: guy(2).pelSkip = 3
guy(1).spriteFrameRate = 1: guy(1).pelSkip = 10: guy(1).y = guy(2).y
guy(0).spriteFrameRate = 3: guy(0).pelSkip = 4
guy(3).spriteFrameRate = 3: guy(3).pelSkip = 3
guy(4).spriteFrameRate = 4: guy(4).pelSkip = 2
guy(2).x = 16: guy(2).y = 0
guy(1).x = 300: guy(1).y = 0
guy(0).x = 16: guy(0).y = 0: guy(0).maxJump = 20: guy(0).fallStep = 1
guy(3).x = 250: guy(3).y = 100
guy(4).x = 285: guy(4).y = 60
guy(5).x = 80: guy(5).y = 105
	   
PALETTE 4, 12
PALETTE 3, 1
PALETTE 1, 9
PALETTE 2, 15
PALETTE 8, 0
'PALETTE 2, 8
'PALETTE 1, 13
'PALETTE 3, 3
'PALETTE 4, 10
'PALETTE 5, 3
'PALETTE 6, 14
'PALETTE 8, 1

LOCATE guy(4).y \ 8 + 1: PRINT "Press Z key to exit"
' Priority queue
q$ = "012345"
qSize% = LEN(q$)
	  
DO
	IF isPressed%(t.StartButton) THEN EXIT DO
		  
	POKE (1132), 0 ' reset tick
		 
	controlPlayer guy(0), block%(), True
	GET (guy(0).x, guy(0).y)-STEP(15, 15), sprite%(RESTORER0)
	move guy(1), block%(): GET (guy(1).x, guy(1).y)-STEP(15, 15), sprite%(RESTORER1)
	move guy(2), block%(): GET (guy(2).x, guy(2).y)-STEP(15, 15), sprite%(RESTORER2)
	move guy(3), block%(): GET (guy(3).x, guy(3).y)-STEP(15, 15), sprite%(RESTORER3)
	move guy(4), block%(): GET (guy(4).x, guy(4).y)-STEP(15, 15), sprite%(RESTORER4)
	move guy(5), block%(): GET (guy(5).x, guy(5).y)-STEP(15, 15), sprite%(RESTORER5)

	' Put all sprites
	FOR i% = 1 TO qSize%
		IF peekTick% > 0 THEN EXIT FOR
		j% = VAL(MID$(q$, i%, 1))
		placeSprite guy(j%).x, guy(j%).y, sprite%(), SpriteArr * j% - (j% > 0), guy(j%).frame
	NEXT
		   
	' Rotate q, prioritizing skipped sprites for displaying in next loop
	IF i% > 1 AND i% < qSize% THEN
		skipped$ = RIGHT$(q$, i%)
		notSkipped$ = LEFT$(q$, qSize% - i%)
		q$ = skipped$ + notSkipped$
	END IF
		  
	flip
		   
	' Restore backdrop square for each sprite
	PUT (guy(0).x, guy(0).y), sprite%(RESTORER0), PSET
	PUT (guy(1).x, guy(1).y), sprite%(RESTORER1), PSET
	PUT (guy(2).x, guy(2).y), sprite%(RESTORER2), PSET
	PUT (guy(3).x, guy(3).y), sprite%(RESTORER3), PSET
	PUT (guy(4).x, guy(4).y), sprite%(RESTORER4), PSET
	PUT (guy(5).x, guy(5).y), sprite%(RESTORER5), PSET
					
	IF NOT peekTick% THEN DO: LOOP UNTIL peekTick% ' delay, if necessary,
												   'for consistent
												   'framerate
LOOP
RETURN

DATA 0,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,.,.,.,.,.,.,1,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,.,.,.,.,.,.,5,1,1,1,1,1,1,1,1,6
DATA 4,.,.,.,.,1,.,.,.,1,5,5,.,.,.,.,1,.,.,6
DATA 4,1,1,.,.,.,.,.,.,.,.,.,.,.,.,1,5,1,.,6
DATA 4,.,.,.,.,.,.,.,.,.,.,.,1,1,1,.,5,5,1,6
DATA 4,.,.,.,0,1,2,3,.,.,.,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,4,5,5,6,.,.,.,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,4,5,5,6,.,1,.,.,.,.,.,.,.,.,.,6
DATA 4,.,.,.,.,.,.,.,.,.,1,.,.,.,.,.,.,.,.,6
DATA 4,1,1,1,1,1,1,.,.,.,5,1,1,1,1,1,1,1,1,1

SUB mock (SpriteResource$, TileResource$)
	isMock% = True
	mockSpriteResource$ = SpriteResource$
	mockTileResource$ = TileResource$
END SUB

SUB move (guy AS SpatialType, block%())
	collided% = NOT moveX%(guy.direction, guy.x, guy.y, guy.pelSkip, block%())
	IF collided% THEN
		IF guy.direction.value = Leftward THEN
			guy.direction.value = Rightward
		   ELSE
			guy.direction.value = Leftward
		END IF
	END IF
	goingLeft% = (guy.direction.value = Leftward)
	guy.frame = animate%(guy.frame, guy.cycle, goingLeft%, guy.spriteFrameRate)

	doGravity guy, 1.75, block%()
	   
	IF guy.x >= SpriteXMax THEN
		guy.direction = t.Leftward
		guy.x = SpriteXMax ' don't forget to fix in case
				   ' of > 1 pelSkip%
	ELSEIF guy.x <= SpriteXMin THEN
		guy.direction = t.Rightward
		guy.x = SpriteXMin
	END IF
END SUB

