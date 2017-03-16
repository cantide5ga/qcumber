REM $INCLUDE: 'modules\commons.bi'
REM $INCLUDE: 'modules\u$er.bi'
REM $INCLUDE: 'modules\graphic.bi'
REM $INCLUDE: 'modules\arrange.bi'
REM $INCLUDE: 'modules\utility.bi'

DECLARE SUB controlPlayer (guy AS ANY, block%(), gravityOn%)
DECLARE SUB fadeOut (arg%, interval%, exclude%())
DECLARE SUB fadeOutAll (arg%, interval%)
DECLARE SUB jump (guy AS ANY, block%())
DECLARE SUB doGravity (guy AS ANY, fallMultiplier!, block%())
DECLARE SUB terminate ()

REM $INCLUDE: 'modules\commons.bas'


