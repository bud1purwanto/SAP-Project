*eject
*---------------------------------------------------------------------*
*       FORM SEGMENT_UEBERNEHMEN                                      *
*---------------------------------------------------------------------*
*       Das Segment wird gelesen und in die Workarea uebernommen.     *
*---------------------------------------------------------------------*
FORM segment_uebernehmen USING zeitpunkt.
  rc = 0.
  CHECK fcausw-xneup IS INITIAL.
  IF fcausw-xlist NE space OR fcausw-xanfp NE space.
*--- bei KB wird festgehalten, ob diese Kontierung neu ist
    IF fcausw-xlist NE space AND zeitpunkt = o.
      IF fcausw-xaenp NE space OR fcausw-xselp NE space.
        xkont = xkont + eins.
      ENDIF.
    ENDIF.

    PERFORM segment_lesen USING zeitpunkt.
    IF rc NE 0.
      EXIT.
    ENDIF.

    IF fcausw-xselp IS INITIAL.
      IF t158-kzbew IS INITIAL OR xkzbew = 1.
*--- sofern sich bei KB die Kontierung geaendert hat (XKONT = EINS)
*    wird die neue Kontierung in die MSEGK-Felder uebernommen. Die
*    nachfolgenden Segmente werden gegen diese Kontierung geprueft,
*    sofern eine andere Kontierung vorliegt -> raus !
        IF fcausw-xlist NE space AND fcausw-xaenp NE space.
          IF xkont = eins.
            msegk = ymsegk.
          ELSE.
            IF ymsegk NE msegk OR
               mseg-bwart NE ymseg-bwart OR mseg-sobkz NE ymseg-sobkz.
              CLEAR xkont.
              rc = eins.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      IF t158-kzbew IS INITIAL OR xkzbew = 1.
        IF xkont = eins.
          msegk = ymsegk.
        ELSE.
          IF ymsegk-parbu IS INITIAL. ymsegk-parbu = msegk-parbu. ENDIF.
          IF ymsegk NE msegk OR
             mseg-bwart NE fuss-bwart OR mseg-sobkz NE fuss-sobkz.
            CLEAR xkont.
            rc = eins.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
      MOVE-CORRESPONDING fuss TO mseg.
      MOVE-CORRESPONDING fuss TO dm07m.
      MOVE-CORRESPONDING fuss TO vm07m.
    ENDIF.
*--- uebernehmen der gelesenen Segmentdaten in die Dynprofelder
    IF fuss-zeile IS INITIAL.
      mseg  = ymseg.
      vm07m = yvm07m.
      dm07m = ydm07m.
      IF NOT mseg-weanz IS INITIAL AND
         dm07m-xwesc IS INITIAL.
        wanzm = mseg-weanz.
      ENDIF.
      PERFORM werk_name_lesen(sapfm07m) USING mseg-werks.
    ENDIF.
  ENDIF.

ENDFORM.