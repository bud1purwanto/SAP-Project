*eject
*---------------------------------------------------------------------*
*       FORM SEGDATEN_LOESCHEN                                        *
*---------------------------------------------------------------------*
*       Teile der Segmentdaten müssen zurückgesetzt werden.           *
*       IFELD = YMSEGK-Felder                                         *
*       DFELD =  MSEGK-Felder                                         *
*       ZEITPUNKT = I -> PAI und O -YPBO                              *
*---------------------------------------------------------------------*
FORM segdaten_loeschen USING ifeld
                             dfeld
                             zeitpunkt.

  CLEAR ifeld.
  IF zeitpunkt = i.
    CLEAR dfeld.
  ENDIF.

ENDFORM.