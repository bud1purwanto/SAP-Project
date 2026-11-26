*----------------------------------------------------------------------*
*   INCLUDE MV45AFUV_XVBUV_SORTIEREN                                   *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  XVBUV_SORTIEREN
*&---------------------------------------------------------------------*
*  Eintragen der Rangfolge in die Tabelle xvbuv und anschl. sortieren
*----------------------------------------------------------------------*
*  Seiteneffekt: In der Tabelle xvbuv wird das Feld sortf geändert
*----------------------------------------------------------------------*
FORM XVBUV_SORTIEREN.
  LOOP AT XVBUV WHERE SORTF IS INITIAL.
    SELECT SINGLE * FROM TVUVF WHERE FEHGR = XVBUV-FEHGR
                               AND   TBNAM = XVBUV-TBNAM
                               AND   FDNAM = XVBUV-FDNAM.
    IF TVUVF-SORTF IS INITIAL.
      XVBUV-SORTF = 9999.
    ELSE.
      XVBUV-SORTF = TVUVF-SORTF.
    ENDIF.
    MODIFY XVBUV TRANSPORTING SORTF.
  ENDLOOP.

  SORT XVBUV BY VBELN POSNR SORTF ETENR PARVW TDID TBNAM FDNAM.

ENDFORM.                               " XVBUV_SORTIEREN