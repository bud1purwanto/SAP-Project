***INCLUDE MV50AF0F_FCODE_IMAT .
*---------------------------------------------------------------------*
*       FORM FCODE_IMAT                                               *
*---------------------------------------------------------------------*
*       Anzeige Material                                              *
*---------------------------------------------------------------------*
FORM FCODE_IMAT.

  IF LIPS-MATNR IS INITIAL.
    MESSAGE S043.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    SET PARAMETER ID 'MXX' FIELD CHARV.
    SET PARAMETER ID 'MAT' FIELD LIPS-MATNR.
    SET PARAMETER ID 'VKO' FIELD LIKP-VKORG.
    SET PARAMETER ID 'VTW' FIELD RV50A-VTWEG.
    SET PARAMETER ID 'WRK' FIELD LIPS-WERKS.
  ENDIF.

ENDFORM.