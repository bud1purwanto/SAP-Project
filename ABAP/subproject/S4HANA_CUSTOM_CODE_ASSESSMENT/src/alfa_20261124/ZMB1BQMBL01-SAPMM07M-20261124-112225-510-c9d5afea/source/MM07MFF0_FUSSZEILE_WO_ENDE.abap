*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WO_ENDE                                       *
*---------------------------------------------------------------------*
*        Die Fusszeilenbearbeitung für die Verrechnung von            *
*        wird abgeschlossen.                                          *
*---------------------------------------------------------------------*
FORM fusszeile_wo_ende.

  CHECK NOT fcausw(20) = fcode_next.
  LOOP AT fuss WHERE fcode = fcod-slnv.
    IF fuss-dimng = 0.
      CLEAR fuss-fcode.
    ELSE.
      fuss-fcode = fcod-np.
    ENDIF.
    MODIFY fuss.
  ENDLOOP.
  CLEAR l_zeile.

ENDFORM.