*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_KPAR_SUB_LEAVE_DET                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  KPAR_SUB_LEAVE_DET
*&---------------------------------------------------------------------*
*       Partner-Subscreen wird verlassen (Kopf)
*----------------------------------------------------------------------*
FORM KPAR_SUB_LEAVE_DET.

  CLEAR MV45A_DATALOSS_PAR_SUB.

* Initialize call-back-memory
  PERFORM PARTNER_CALL_BACK_IN USING VBAK-VBELN
                                     VBAK-VBTYP
                                     TVAK.

ENDFORM.                               " KPAR_SUB_LEAVE_DET



















