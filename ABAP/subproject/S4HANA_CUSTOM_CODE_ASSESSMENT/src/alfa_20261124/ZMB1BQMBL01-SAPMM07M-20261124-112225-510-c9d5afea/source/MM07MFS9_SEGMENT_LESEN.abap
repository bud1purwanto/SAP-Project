*eject
*---------------------------------------------------------------------*
*       FORM SEGMENT_LESEN                                            *
*---------------------------------------------------------------------*
*       Das Segment wird gelesen.                                     *
*---------------------------------------------------------------------*
FORM segment_lesen USING zeitpunkt.

  IF fcausw-xselp IS INITIAL.
    READ TABLE ymseg INDEX a_zeile.
    rc = sy-subrc.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.
    IF NOT fcausw-xaenp IS INITIAL AND NOT fcausw-xlist IS INITIAL
       AND ( t158-kzbew IS INITIAL OR xkzbew = 1 OR xkzbew = 3 )
       AND sy-subrc IS INITIAL.
      MOVE-CORRESPONDING ymseg TO ymsegk.
    ENDIF.
    READ TABLE yvm07m INDEX a_zeile.
    rc = sy-subrc.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.
    READ TABLE ydm07m INDEX a_zeile.
    ydm07m-xexit = dm07m-xexit.
    rc = sy-subrc.
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.
    IF t158-kzbew IS INITIAL OR xkzbew = 1 OR xkzbew = 3.
      IF ydm07m-xkman IS INITIAL.
        CLEAR ymsegk-konto.
      ELSE.
        ymsegk-konto = ydm07m-konto.
      ENDIF.
      IF NOT yvm07m-xstor = zwei.
        IF ydm07m-fausw+55(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-ummat
                                           msegk-ummat
                                           zeitpunkt.
        ENDIF.
        IF ydm07m-fausw+56(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-umwrk
                                           msegk-umwrk
                                           zeitpunkt.
        ENDIF.
        IF ydm07m-fausw+57(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-umlgo
                                           msegk-umlgo
                                           zeitpunkt.
        ENDIF.
      ENDIF.
    ENDIF.
ENHANCEMENT-POINT SEGMENT_LESEN_01 SPOTS ES_SAPMM07M.
  ELSE.
    READ TABLE fuss INDEX a_zeile.
*   note 652177: first get the relevant line, then take over the field
    IF NOT fuss-elikz_input IS INITIAL.                         " 652177
      MOVE fuss-elikz_input TO dm07m-elikz_input.               " 652177
    ENDIF.                                                      " 652177
    rc = sy-subrc.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING fuss TO ymsegk.
      IF t158-kzbew IS INITIAL OR xkzbew = 1 OR xkzbew = 3.
        IF fuss-xkman IS INITIAL.
          CLEAR ymsegk-konto.
        ELSE.
          ymsegk-konto = fuss-konto.
        ENDIF.
      ENDIF.
      IF NOT fuss-xstor = zwei.
        IF fuss-fausw+55(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-ummat
                                           msegk-ummat
                                           zeitpunkt.
        ENDIF.
        IF fuss-fausw+56(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-umwrk
                                           msegk-umwrk
                                           zeitpunkt.
        ENDIF.
        IF fuss-fausw+57(1) = minus.
          PERFORM segdaten_loeschen USING ymsegk-umlgo
                                           msegk-umlgo
                                           zeitpunkt.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT sy-subrc IS INITIAL AND NOT sy-stepl IS INITIAL.
      EXIT FROM STEP-LOOP.
    ENDIF.
  ENDIF.

ENDFORM.