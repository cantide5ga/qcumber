Using the Qcumber Library for Development
-----
Start QB with the Qcumber lib:
```
qb /l qcumber
```
Be sure to include it at the top of your code:
```
`$INCLUDE: `qcumber.fat`
```
See the **Globals** section at the bottom for values and types available.

QCUMBER.FAT
-----
An include of all qcumber module signatures.  To generate a new one, execute genFat() from the Utility module.
Does NOT include qb.bi.


CD2SRC.BAS
-----
Used for setting the path of this project correctly, without confusing the IDE, allowing for the use of relative paths for includes, etc.
See below for wiring into DOSBox.

Config
-----
*prog.ini* is used by *getConfig()* in Utility module for getting values at runtime, usually for initialization of assets and resources.
The INI file is a list of key/value pairs delimited by an =.  Use a # as the first character of a line to denote a comment, which are ignored by the parser.

Errors and Logging
-----
Handled errors are reported as "Unprintable error", but will dump some good-to-knows in *qcumber.log* of whatever directory you are in.

QB.BI
-----
Qb 4.5's assembly support include.  Copied over for easy reference.


Example DOSBox conf
-----
```
[sdl]
fullscreen=true
[render]
aspect=true
scaler=tv3x
[cpu]
cycles=max
[autoexec]
mount c p:\DetailedFiles\486dx
c:
cd\qb4.5
qb /l qcumber /run qcumber\CD2SRC.BAS
```

Globals
-----
### External
The 't' namespace are user-defined types, giving some degree of type safety

* True
* False
* t.ViewPage
* t.Buffer
* t.SpriteSheet
* t.TileSheet
* t.Integers
* t.Longs
* t.SFloat
* t.DFloat
* t.Rightward
* t.Leftward
* t.Downward
* t.Upward
* t.RightButton
* t.LeftButton
* t.DownButton
* t.UpButton
* t.BButton
* t.AButton
* t.StartButton
* t.SelectButton
* t.KeyHandlerKillCall

### Internal
The Qcumber lib uses these internally and you likely won't need them; use at your own risk

* UnitWidth
* UnitHeight
* DefaultArr
* NormalizedUnitWidth
* NormalizedUnitHeight
* Frame1
* Frame1Mask
* Frame1Left
* Frame1LeftMask
* Frame2
* Frame2Mask
* Frame2Left
* Frame2LeftMask
* Restorer
* SpriteArr
* SpriteXMax
* SpriteXMin
* SpriteYMax
* SpriteYMin
* SpriteYConvertedMin
* SpriteYConvertedMax
* LeftFramesOffset
* CyclesPerSpriteFrame

