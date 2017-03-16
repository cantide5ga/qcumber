'Program to allow changing to source dir on QB load without messing up Paths

SHELL "cd c:\qb4.5\qcumber"

' Disables "Press any key to continue" prompt
DEF SEG = &H40
POKE &H1A, 25
DEF SEG

