*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PPAR_SUB_LEAVE_DET                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PPAR_SUB_LEAVE_DET
*&---------------------------------------------------------------------*
*       Partner-Subscreen wird verlassen (Position)
*----------------------------------------------------------------------*
FORM PPAR_SUB_LEAVE_DET.

  CLEAR MV45A_DATALOSS_PAR_SUB.

* Initialize call-back-memory
  PERFORM PARTNER_CALL_BACK_IN USING VBAK-VBELN
                                     VBAK-VBTYP
                                     TVAK.

ENDFORM.                               " PPAR_SUB_LEAVE_DET



















