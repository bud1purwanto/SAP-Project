***INCLUDE MV50AF0F_FCODE_IFLU_KOPF .
*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_KOPF                                          *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß auf Kopfebene                               *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_KOPF USING US_T185F STRUCTURE T185F
                           US_T185  STRUCTURE T185
                           US_T185V STRUCTURE T185V.

  CLEAR VBCO6.
  MOVE-CORRESPONDING LIKP TO VBCO6.

  CALL DIALOG 'RV_DOCUMENT_FLOW'
       EXPORTING
            VBCO6      FROM VBCO6
            MAKT-MAKTX FROM SPACE
            KNA1-KUNNR FROM KUWEV-KUNNR
            KNA1-NAME1 FROM KUWEV-NAME1
            MAKT-MATNR FROM SPACE
            IVKORG     FROM LIKP-VKORG
            IVTWEG     FROM RV50A-VTWEG.

ENDFORM.