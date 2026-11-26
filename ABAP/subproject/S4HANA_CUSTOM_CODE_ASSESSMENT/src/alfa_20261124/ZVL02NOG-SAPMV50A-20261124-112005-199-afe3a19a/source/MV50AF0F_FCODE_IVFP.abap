***INCLUDE MV50AF0F_FCODE_IVFP .
*---------------------------------------------------------------------*
*       FORM FCODE_IVFP                                               *
*---------------------------------------------------------------------*
*       Anzeige Materialverfügbarkeit                                 *
*---------------------------------------------------------------------*
FORM fcode_ivfp USING t185f t185 t185v.

  IF lips-matnr IS INITIAL.
    MESSAGE s043.
    EXIT.
  ENDIF.
  IF lips-matnr NE xlips-matnr.
    PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
  ENDIF.
  IF lips-werks EQ space.
    MESSAGE ID 'V1' TYPE chari NUMBER '186' WITH lips-posnr.
    EXIT.
  ENDIF.
  IF lips-mtvfp EQ space.
    MESSAGE ID 'V1' TYPE chari NUMBER '278' WITH lips-posnr.
    EXIT.
  ENDIF.

* Bei Lieferung zu Reservierung/Projekt keine Verfuegbarkeitsprüfungen
  IF NOT lips-rsnum IS INITIAL AND
     NOT lips-rspos IS INITIAL AND
     NOT tvlk-aufer EQ gc_aufer-lohnbei.
*----some preliminaries for the link to co09 in the longtext
*----of vl299.
     SET PARAMETER ID 'MAT'  FIELD lips-matnr.
     SET PARAMETER ID 'WRK'  FIELD lips-werks.
     SET PARAMETER ID 'BERID'  FIELD lips-berid.
     SET PARAMETER ID 'AUN'  FIELD '        '.
     SET PARAMETER ID 'AUP'  FIELD '      '.
     CASE lips-sobkz .
        WHEN 'E'.
             SET PARAMETER ID 'PRR'  FIELD 'BE'.
             SET PARAMETER ID 'AUN'  FIELD lips-vbelv.
             SET PARAMETER ID 'AUP'  FIELD lips-posnv.
*       when 'Q'.
*            set parameter id 'PRR'  field 'BQ'.
*            set parameter id '???'  field lips-PS_PSP_PNR.
        WHEN ' '.
             SET PARAMETER ID 'PRR'  FIELD 'B '.
        WHEN OTHERS.
             SET PARAMETER ID 'PRR'  FIELD '  '. "force input
     ENDCASE.

     MESSAGE s299 WITH lips-rsnum lips-rspos.
     EXIT.
  ENDIF.

  DATA ATP_TYPE TYPE LES_ATP_TYPE.
  CALL FUNCTION 'LE_ATP_GET_VERSION'
        IMPORTING
             ATP_TYPE         = ATP_TYPE.

  IF ATP_TYPE EQ CHARO.
    PERFORM verfuegbarkeit_anzeigen(sapfv50v).
  ELSE.
    PERFORM verfuegbarkeit_anzeigen_neu.
  ENDIF.

ENDFORM.