*---------------------------------------------------------------------*
*       FORM TCURV_SELECT                                             *
*---------------------------------------------------------------------*
*       Kurstypen lesen                                               *
* Lesen der Kurstypen, um festzustellen , ob es EURO Kurstypen gibt.  *
* Wenn ja ist die Währung bei teilfakturierten Aufträgen änderbar.    *
*---------------------------------------------------------------------*
FORM TCURV_SELECT CHANGING US_EURO_ACTIVE.

  CHECK US_EURO_ACTIVE = SPACE.

  SELECT * FROM TCURV WHERE
     XINVR = SPACE    AND
     BWAER NE SPACE   AND
     XFIXD = CHARX    AND
     XEURO = CHARX.
    US_EURO_ACTIVE = CHARY.
    EXIT.
  ENDSELECT.
  IF SY-SUBRC NE 0.
    US_EURO_ACTIVE = CHARN.
  ENDIF.

ENDFORM.