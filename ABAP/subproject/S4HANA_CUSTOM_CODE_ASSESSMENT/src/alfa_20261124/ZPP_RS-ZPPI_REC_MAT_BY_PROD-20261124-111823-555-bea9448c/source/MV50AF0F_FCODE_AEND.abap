*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_AEND                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_AEND                                               *
*---------------------------------------------------------------------*
*       Aendern Lieferung                                             *
*---------------------------------------------------------------------*
FORM FCODE_AEND.

* ---- Wenn bereits im Call-Modus, dann Rücksprung in die aufrufende
*      Transaktion ermöglichen
  IF SY-CALLD EQ 'X'.
    CALL TRANSACTION 'VL02' AND SKIP FIRST SCREEN.
    LEAVE.
  ELSE.
    LEAVE TO TRANSACTION 'VL02'.
  ENDIF.

ENDFORM.