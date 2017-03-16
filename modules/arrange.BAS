REM $INCLUDE: 'modules\arrange.bi'

SUB add (value%, array%())
	size% = sizeOf%(array%())
	DIM tempArr%(size% + 1)

	copyArray array%(), tempArr%()

	REDIM array%(size% + 1)
	FOR i% = LBOUND(array%) TO UBOUND(array%)
		array%(i%) = tempArr%(i%)
	NEXT
	   
	array%(UBOUND(array%)) = value%
END SUB

SUB copyArray (fromArr%(), toArr%())
	FOR i% = LBOUND(fromArr%) TO UBOUND(fromArr%)
		toArr%(i%) = fromArr%(i%)
	NEXT
END SUB

FUNCTION firstOccuranceOf% (value%, array%())
	'Returns the index of the value.  Returns FAIL if not found.
	  
	FOR i% = LBOUND(array%) TO UBOUND(array%)
		IF array%(i%) = value% THEN
			firstOccuranceOf% = i%
			EXIT FUNCTION
		END IF
	NEXT
	firstOccuranceOf% = FAIL
END FUNCTION

FUNCTION hasValInArr% (value%, array%())
	hasValInArr% = (firstOccuranceOf%(value%, array%()) <> FAIL)
END FUNCTION

FUNCTION pop% (array%())
	index% = LBOUND(array%)
	pop% = array%(index%)

	size% = sizeOf%(array%()) - 1
	DIM tempArr%(size%)

	FOR i% = LBOUND(tempArr%) TO UBOUND(tempArr%)
		tempArr%(i%) = array%(i% + 1)
	NEXT
	   
	REDIM array%(size%)
	FOR i% = LBOUND(array%) TO UBOUND(array%)
		array%(i%) = tempArr%(i%)
	NEXT
END FUNCTION

SUB push (value%, array%())
	size% = sizeOf%(array%())
	DIM tempArr%(size% + 1)

	copyArray array%(), tempArr%()

	REDIM array%(size% + 1)
	FOR i% = LBOUND(array%) + 1 TO UBOUND(array%)
		array%(i%) = tempArr%(i%)
	NEXT
	
	array%(LBOUND(array%)) = value%

END SUB

SUB remove (value%, array%())
	index% = firstOccuranceOf%(value%, array%())
	removeAt index%, array%()
END SUB

SUB removeAt (index%, array%())
	size% = sizeOf%(array%()) - 1
	DIM tempArr%(size%)
	  
	first% = LBOUND(tempArr%)
	last% = UBOUND(tempArr%)
	i% = first%
	j% = i%
	DO
		IF j% = index% THEN j% = j% + 1
		IF j% > last% THEN EXIT DO
		tempArr%(i%) = array%(j%)
		i% = i% + 1
		j% = j% + 1
	LOOP UNTIL i% = last%
	  
	REDIM array%(size%)
	copyArray tempArr%(), array%()
END SUB

SUB removeMany (array%(), exclude%())
'  Removes values from array. Dynamic array required for re-fit.

first% = LBOUND(array%)
last% = UBOUND(array%)
arrSize% = last% - first%

DIM temp%(arrSize%)
copyArray array%(), temp%()

FOR i = 0 TO UBOUND(exclude%)
NEXT

i% = first%
DO
	FOR j% = LBOUND(exclude%) TO UBOUND(exclude%)
		IF temp%(i%) = exclude%(j%) THEN
			FOR k% = i% TO last% - 1
				temp%(k%) = temp%(k% + 1)
			NEXT
			arrSize% = arrSize% - 1
			last% = last% - 1
			i% = i% - 1 '*** list has been truncated so go back
			EXIT FOR
		END IF
	NEXT
	i% = i% + 1
LOOP UNTIL i% = last%

REDIM array%(arrSize%)
FOR i% = 0 TO arrSize%
	array%(i%) = temp%(i%)
NEXT

END SUB

FUNCTION sizeOf% (array%())
	sizeOf% = ABS(UBOUND(array%) - LBOUND(array%))
END FUNCTION

SUB sortPairAscend (array%(), otherArray%())

' Sorts array pairs ascending based on the evaluation of the second array of
'the pair.

DO
	swapped% = FALSE
	FOR i% = LBOUND(otherArray%) + 1 TO UBOUND(otherArray%)
		IF otherArray%(i% - 1) > otherArray%(i%) THEN
			SWAP array%(i% - 1), array%(i%)
			SWAP otherArray%(i% - 1), otherArray%(i%)
			swapped% = TRUE
		END IF
	NEXT
LOOP UNTIL NOT swapped%

END SUB

