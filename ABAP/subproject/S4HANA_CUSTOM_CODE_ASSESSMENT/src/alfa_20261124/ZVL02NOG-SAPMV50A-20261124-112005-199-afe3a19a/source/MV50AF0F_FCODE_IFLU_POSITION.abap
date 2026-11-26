***INCLUDE MV50AF0F_FCODE_IFLU_POSITION .
*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_POSITION                                      *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß auf Positionsebene                          *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_POSITION USING US_T185F
                               US_T185
                               US_T185V.

  CLEAR VBCO6.
  IF LIPSD-UPDKZ NE UPDKZ_NEW.
    MOVE-CORRESPONDING LIPS TO VBCO6.

    CALL DIALOG 'RV_DOCUMENT_FLOW'
         EXPORTING
              VBCO6      FROM VBCO6
              MAKT-MAKTX FROM LIPS-ARKTX
              KNA1-KUNNR FROM KUWEV-KUNNR
              KNA1-NAME1 FROM KUWEV-NAME1
              MAKT-MATNR FROM LIPS-MATNR
              IVKORG     FROM LIKP-VKORG
              IVTWEG     FROM LIPS-VTWEG.
  ELSE.
    MESSAGE I371.
  ENDIF.
ENDFORM.