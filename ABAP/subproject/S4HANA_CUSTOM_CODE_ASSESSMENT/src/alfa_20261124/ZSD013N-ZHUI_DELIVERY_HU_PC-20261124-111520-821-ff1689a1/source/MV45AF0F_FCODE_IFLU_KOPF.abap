*---------------------------------------------------------------------*
*       FORM FCODE_IFLU_KOPF                                          *
*---------------------------------------------------------------------*
*       Anzeige Belegfluß auf Kopfebene                               *
*---------------------------------------------------------------------*
FORM FCODE_IFLU_KOPF USING US_T185F STRUCTURE T185F
                           US_T185  STRUCTURE T185
                           US_T185V STRUCTURE T185V.

  CLEAR VBCO6.
  MOVE-CORRESPONDING VBAK TO VBCO6.

  CALL DIALOG 'RV_DOCUMENT_FLOW'
       EXPORTING
            VBCO6      FROM VBCO6
            MAKT-MAKTX FROM SPACE
            KNA1-KUNNR FROM KUAGV-KUNNR
            KNA1-NAME1 FROM KUAGV-NAME1
            MAKT-MATNR FROM SPACE
            IVKORG     FROM VBAK-VKORG
            IVTWEG     FROM VBAK-VTWEG.

ENDFORM.