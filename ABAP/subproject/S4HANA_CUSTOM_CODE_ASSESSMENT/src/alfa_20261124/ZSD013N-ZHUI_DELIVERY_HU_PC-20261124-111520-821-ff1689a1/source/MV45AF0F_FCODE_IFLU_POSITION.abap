*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_POSITION                                      *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß auf Positionsebene                          *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_POSITION USING US_T185F
                               US_T185
                               US_T185V.

  CLEAR VBCO6.
  MOVE-CORRESPONDING VBAP TO VBCO6.

  CALL DIALOG 'RV_DOCUMENT_FLOW'
       EXPORTING
            VBCO6      FROM VBCO6
            MAKT-MAKTX FROM VBAP-ARKTX
            KNA1-KUNNR FROM KUAGV-KUNNR
            KNA1-NAME1 FROM KUAGV-NAME1
            MAKT-MATNR FROM VBAP-MATNR
            IVKORG     FROM VBAK-VKORG
            IVTWEG     FROM VBAK-VTWEG.
ENDFORM.