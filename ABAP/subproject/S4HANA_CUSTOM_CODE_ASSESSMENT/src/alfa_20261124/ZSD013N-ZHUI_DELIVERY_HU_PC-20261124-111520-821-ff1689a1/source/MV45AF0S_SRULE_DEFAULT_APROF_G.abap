*---------------------------------------------------------------------*
*       FORM srule_default_aprof_get
*---------------------------------------------------------------------*
*       Die Routine ermittelt zu einer Objektnummer das Abrechnungs-  *
*       profil                                                      - *
*       Sie wird bei der Abrechnung(VA88) benötigt, wenn die        - *
*       Ergebnisrechnung nicht aktiv ist.                           - *
*       Ansonsten sollte man sie nicht benutzen !                   - *
*---------------------------------------------------------------------*
FORM SRULE_DEFAULT_APROF_GET USING VALUE(US_OBJNR) LIKE ONR00-OBJNR
                             CHANGING CH_APROF LIKE TKB1A-APROF
                                      CH_SUBRC LIKE SY-SUBRC.

  DATA: DA_VBELN LIKE VBAK-VBELN,
        DA_POSNR LIKE VBAP-POSNR.

  CALL FUNCTION 'OBJECT_KEY_GET_VB'
       EXPORTING
            OBJNR       = US_OBJNR
       IMPORTING
            POSNR       = DA_POSNR
            VBELN       = DA_VBELN
       EXCEPTIONS
            NOT_FOUND   = 1
            WRONG_OBART = 2
            OTHERS      = 3.
  CH_SUBRC = SY-SUBRC.
  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'SD_VBAP_SELECT'
       EXPORTING
            I_DOCUMENT_NUMBER = DA_VBELN
            I_ITEM_NUMBER     = DA_POSNR
       IMPORTING
            E_VBAP            = VBAP
            E_VBAPVB          = XVBAP
       EXCEPTIONS
            ITEM_NOT_FOUND    = 1
            OTHERS            = 2.
  CH_SUBRC = SY-SUBRC.
  CHECK SY-SUBRC = 0.

  IF VBAP-BEDAE IS INITIAL.
    CH_SUBRC = 8.
    EXIT.
  ENDIF.
  PERFORM T459A_SELECT USING VBAP-BEDAE
                             CHARX
                             SY-SUBRC.
  CH_SUBRC = SY-SUBRC.
  CHECK SY-SUBRC = 0.
  PERFORM T459K_SELECT(SAPFV45V) USING T459A-BEDAR
                                       CHARX
                                       SY-SUBRC.
  CH_SUBRC = SY-SUBRC.
  CHECK SY-SUBRC = 0.

  CH_SUBRC = 0.
  CH_APROF = T459K-APROF.

ENDFORM.