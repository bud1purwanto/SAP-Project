*eject
*----------------------------------------------------------------------*
*     FORM ANZAHL_WESCHEIN                                             *
*----------------------------------------------------------------------*
*     Anzahl der WE-Scheine wird errechnet.                            *
*----------------------------------------------------------------------*
FORM ANZAHL_WESCHEIN.
* changes as per note 392241. If any changes are done here in
* future please notice that same source in within LMIGOKN1 in MIGO
* from 46B on.

  DATA: L_WEANZ_FLOAT TYPE F,
        L_WEANZ_INT   TYPE I.

  CHECK T158-TRTYP = H.
  IF DM07M-XWESC IS INITIAL.
*   slip number not entered manually
    IF DM07M-WESCH IS INITIAL OR MSEG-ERFMG IS INITIAL.
      MSEG-WEANZ = 1.
      EXIT.
    ENDIF.
*   Divide into a floating point to get decimals.
    L_WEANZ_FLOAT = MSEG-ERFMG / DM07M-WESCH.
*   Find next integer
    L_WEANZ_INT   = CEIL( L_WEANZ_FLOAT ).
*   Convert type i to n
    MSEG-WEANZ    = L_WEANZ_INT.
    WANZM         = L_WEANZ_INT.
  ELSE.
*   slip number entered manually
    MSEG-WEANZ = ANZMA.
    WANZM      = ANZMA.
  ENDIF.

ENDFORM.