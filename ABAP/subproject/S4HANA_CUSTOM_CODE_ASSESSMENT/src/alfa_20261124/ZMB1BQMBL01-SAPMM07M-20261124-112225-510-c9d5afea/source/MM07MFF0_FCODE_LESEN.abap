*eject
*---------------------------------------------------------------------*
*        FORM FCODE_LESEN                                             *
*---------------------------------------------------------------------*
*        Der Funktionscode wird aus Tabelle 063F gelesen.             *
*---------------------------------------------------------------------*
FORM fcode_lesen USING f-fcode LIKE t063-fcode.
  CHECK f-fcode NE fcausw-fcode.
  IF f-fcode NE t063f-fcode.
    SELECT SINGLE * FROM t063f WHERE fcode = f-fcode.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e001 WITH '063F' f-fcode.
    ENDIF.
  ENDIF.
  fcausw = t063f.

ENDFORM.