REM $INCLUDE: 'qcumber.bi'

SUB controlPlayer (guy AS SpatialType, block%(), gravityOn%)
	STATIC isJumpLocked%
	fallMultiplier! = 1.75
	   
	' Lock jump when falling starts
	isJumpLocked% = guy.isFalling OR isJumpLocked%
	
	' Disallow auto-fire of jump button once grounded; player must
	'disengage and re-engage to jump again
	isJumpLocked% = (isJumpLocked% AND NOT isPressed%(t.UpButton)) XOR isJumpLocked%
	
	' Once jump button disengaged during a jump, ignore further jumping
	'until grounded
	isJumpLocked% = NOT isPressed%(t.UpButton) AND guy.isJumping OR isJumpLocked%

	' <- and -> in same IF block for performance; doesn't make sense to
	'support simultaneous presses
	IF isPressed%(t.LeftButton) THEN
		guy.direction = t.Leftward
		' Execute logic in function, but disregard return
		ignore% = moveX(guy.direction, guy.x, guy.y, guy.pelSkip, block%())
		  
		guy.frame = animate%(guy.frame, guy.cycle, True, guy.spriteFrameRate)
	ELSEIF isPressed%(t.RightButton) THEN
		guy.direction = t.Rightward
		ignore% = moveX(guy.direction, guy.x, guy.y, guy.pelSkip, block%())
		  
		guy.frame = animate%(guy.frame, guy.cycle, False, guy.spriteFrameRate)
	END IF
	
	IF isPressed%(t.UpButton) AND NOT isJumpLocked% AND NOT guy.isFalling THEN
		jump guy, block%()
	   ELSE
		' TODO gravity switch to enable/disable
		guy.isJumping = False
		guy.jumpStep = 0 'reset
		IF gravityOn% THEN doGravity guy, fallMultiplier!, block%()
	END IF

	IF NOT gravityOn% AND isPressed%(t.DownButton) THEN
		guy.direction = t.Downward
		ignore% = moveY(guy.direction, guy.x, guy.y, guy.pelSkip, block%())
	END IF
END SUB

SUB doGravity (guy AS SpatialType, fallMultiplier!, block%())
	' Acceleration with cap
	guy.fallStep = guy.fallStep * fallMultiplier!
	IF guy.fallStep > UnitHeight THEN guy.fallStep = UnitHeight
		  
	' Always fall if not standing on a block
	guy.isFalling = moveY(t.Downward, guy.x, guy.y, guy.fallStep, block%())
	IF NOT guy.isFalling THEN guy.fallStep = 1 'reset
END SUB

SUB fadeOut (arg%, interval%, exclude%())
DIM colour AS ColorType

dynSize% = 15: DIM arrangedPal%(dynSize%) ' dynamic array
FOR i% = 0 TO 15: arrangedPal%(i%) = i%: NEXT
removeMany arrangedPal%(), exclude%() ' exclude colors to be faded

includeSize% = UBOUND(arrangedPal%)
DIM weight%(includeSize%)
FOR i% = 0 TO includeSize%
	code$ = getRgb$(i%, colour)
	'weight%(i%) = .11 * colour.b + .59 * colour.g + .3 * colour.r
	weight%(i%) = (colour.b + colour.g + colour.r) \ 3
NEXT

pageTo t.ViewPage

IF arg% = 0 THEN GOSUB grayscaleFadeOut
IF arg% = 1 THEN GOSUB paletteFadeOut

grayscaleFadeOut:
	FOR i% = 0 TO includeSize%
		a% = weight%(i%)
		colour.r% = a%: colour.g% = a%: colour.b% = a%
		setColor arrangedPal%(i%), colour
	NEXT
	GOSUB paletteFadeOut

paletteFadeOut:
	sortPairAscend arrangedPal%(), weight%() ' order by weight
	FOR i% = 1 TO includeSize%
		'*** Shift down
		FOR j% = includeSize% TO i% STEP -1
			a% = j% - interval%
			IF a% < 0 THEN a% = 0
		  
			attrib% = arrangedPal%(a%)
			code$ = getRgb$(attrib%, colour)
			setColor arrangedPal%(j%), colour
		NEXT
		hold (1)
	NEXT
	EXIT SUB
END SUB

SUB fadeOutAll (arg%, interval%)
	DIM exclude%(0)
	fadeOut arg%, interval%, exclude%()
END SUB

SUB jump (guy AS SpatialType, block%())
	jumpDivisor! = 1.5
	jumpCap! = 1.3

	guy.isJumping = True
		  
	IF guy.jumpStep = 0 THEN
		guy.jumpStep = guy.maxJump / jumpDivisor!
	   ELSE
		guy.jumpStep = guy.jumpStep / jumpDivisor!
	END IF
	exceedsMaxSkip% = guy.jumpStep > UnitHeight
	pelSkip! = UnitHeight * -exceedsMaxSkip% + guy.jumpStep * -(NOT exceedsMaxSkip%)
		  
	' Fall if hit obstacle from above or if jump has maxed out
	guy.isFalling = NOT moveY(t.Upward, guy.x, guy.y, pelSkip!, block%()) OR guy.jumpStep < jumpCap!

	' Continue jump if not maxed
	guy.isJumping = NOT guy.jumpStep < jumpCap!
END SUB

SUB terminate
	disabled% = isPressed%(t.KeyHandlerKillCall)
	SYSTEM
END SUB

