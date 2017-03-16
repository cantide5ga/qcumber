DECLARE SUB loadSprite (code$, sprite%(), atIndex%)
DECLARE SUB pageTo (page AS ANY)
DECLARE SUB placeSprite (x%, y%, sprite%(), atIndex%, atFrame%)
DECLARE SUB placeTile (code$, x%, y%)
DECLARE SUB planarize (index%, w%, p AS ANY)
DECLARE SUB flip ()
DECLARE FUNCTION animate% (frame%, cycles%, goingLeft%, spriteFrameRate%)
DECLARE SUB bLoadImage (sourceFile AS STRING, image AS ANY)
DECLARE SUB specImage7 (image AS ANY, x1%, y1%, x2%, y2%)
DECLARE SUB bSaveImage (file AS STRING, image AS ANY)
DECLARE SUB scrollCrop (direction AS ANY, x1%, y1%, x2%, y2%, clipSize%)
DECLARE SUB setColor (attribute%, colour AS ANY)
DECLARE SUB specImage (image AS ANY, x1%, y1%, x2%, y2%, bpp%, p%, dat AS ANY)
DECLARE FUNCTION getRgb$ (attrib%, colour AS ANY)
DECLARE FUNCTION dePlanarize% (x%, y%, w%)
DECLARE SUB specColor (colour AS ANY, r%, g%, b%)
DECLARE SUB createMask (image AS ANY)
DECLARE SUB bLoadScreen (file$)
DECLARE SUB buildSprite (pose1 AS ANY, pose2 AS ANY, result%(), atIndex%)
DECLARE SUB load4BitBmp (file AS STRING, fullDecode%)
DECLARE SUB decorPrint (text$, colour%, shadowColor%)
DECLARE SUB fixAttribDef ()
DECLARE FUNCTION moveX% (direction AS ANY, x%, y%, pelSkip!, block%())
DECLARE FUNCTION moveY% (direction AS ANY, x%, y%, pelSkip!, block%())
DECLARE SUB pageToPrevious ()
DECLARE SUB bSaveScreen (file AS STRING)
DECLARE SUB nesPalPick (attribute%, hue AS ANY, tint%)

TYPE ColorType
        r AS INTEGER
        g AS INTEGER
        b AS INTEGER
END TYPE

TYPE PaletteType
        lite AS ColorType
        med AS ColorType
        dark AS ColorType
END TYPE

TYPE PlanarType
        x AS INTEGER
        y AS INTEGER
END TYPE

TYPE ImageType
        x1 AS INTEGER
        x2 AS INTEGER
        y1 AS INTEGER
        y2 AS INTEGER
        bpp AS INTEGER
        p AS INTEGER
        arrType AS DataType
        arrSize AS INTEGER
END TYPE

' Structure for holding state of a sprite as it moves across the plane (space
'and time)
TYPE SpatialType
        x AS INTEGER
        y AS INTEGER
        frame AS INTEGER 'current sprite pose
        direction AS DirectionType
        cycle AS INTEGER 'relative iterator for a sprite's frame rate
        spriteFrameRate AS INTEGER
        pelSkip AS SINGLE 'speed
        maxJump AS INTEGER
        isJumping AS INTEGER
        jumpStep AS SINGLE 'keeps track of current jump
        isFalling AS INTEGER
        fallStep AS SINGLE 'keeps track of current fall
END TYPE


