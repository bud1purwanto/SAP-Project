*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PPAR_SUB_LEAVE_U_D                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PPAR_SUB_LEAVE_U_D
*&---------------------------------------------------------------------*
*       Partner-Subscreen wird verlassen (Position)
*       Wechsel auf Übersichtsbild
*----------------------------------------------------------------------*
  FORM PPAR_SUB_LEAVE_U_D.

    PERFORM PPAR_SUB_LEAVE_DET.

* Übersicht vorbereiten
    PERFORM XVBAP_UEBERSICHT_ANSTEUERN(SAPFV45P).

  ENDFORM.                             " PPAR_SUB_LEAVE_U_D





















