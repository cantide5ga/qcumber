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

SYSTEM

