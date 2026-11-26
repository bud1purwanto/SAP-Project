*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_PS_PBO
*&---------------------------------------------------------------------*
form fmii1_prepare.

  DATA: da_actyp VALUE 'M'.

  IF t180-trtyp = chara.
    da_actyp = chard.
  ENDIF.

* Wenn Ergebnisrechnung nicht aktiv ist, ist COBL nicht gefüllt
  PERFORM cobl_fuellen(sapfv45p) USING vbak
                                       vbap
                                       vbkd
                              CHANGING cobl.

  CALL FUNCTION 'FM_CO_ASS_INPUT_PREPARE_LORD'
    EXPORTING
      I_COBL                              = cobl
      I_VBAK                              = vbak
      I_VBAP                              = vbap
      I_ACTYP                             = da_actyp
*   I_FLG_INCOMPLETE_MESSAGE            = 'X'
*   I_FLG_REASSIGN                      =
* IMPORTING
*   E_EXIT                              =
*   E_FLG_ASSIGNMENT_CHANGE             =
*   E_FLG_ASSIGNMENT_COMPLETE           =
*   E_FLG_MISSING_FUNDS_CENTER          =
*   E_FLG_MISSING_COMMITMENT_ITEM       =
*   E_FLG_MISSING_FUND                  =
*   E_FLG_MISSING_FKBER                 =
*   E_FLG_MISSING_MEASURE               =
*   E_FLG_MISSING_GRANT_NBR             =
            .
endform.                    "fmii1_prepare

*&---------------------------------------------------------------------*
*&      Form  FMII1_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->STAT_CI    text
*      -->STAT_FC    text
*      -->STAT_FU    text
*      -->STAT_FA    text
*      -->STAT_GR    text
*----------------------------------------------------------------------*
FORM FMII1_INPUT USING STAT_CI TYPE CHAR1
                       STAT_FC TYPE CHAR1
                       STAT_FU TYPE CHAR1
                       STAT_FA TYPE CHAR1
                       STAT_GR TYPE CHAR1
                       STAT_BP TYPE CHAR1.

  DATA: DA_ACTYP VALUE 'M'.
  DATA L_FMZUCO TYPE FMZUCO.

* Wenn Ergebnisrechnung nicht aktiv ist, ist COBL nicht gefüllt
  PERFORM COBL_FUELLEN(SAPFV45P) USING VBAK
                                       VBAP
                                       VBKD
                              CHANGING COBL.

  CALL FUNCTION 'FM_CO_ASS_INPUT_DEMAND_SD'
    EXPORTING
      I_BUKRS        = COBL-BUKRS
      I_FIKRS        = COBL-FIKRS
      I_VBAK         = VBAK
      I_VBAP         = VBAP
    IMPORTING
      E_FMZUCO       = L_FMZUCO
    EXCEPTIONS
      NO_ENTRY_FOUND = 1.

  STAT_CI = L_FMZUCO-FSTATUS_CI.
  STAT_FC = L_FMZUCO-FSTATUS_FC.
  STAT_FU = L_FMZUCO-FSTATUS_FU.
  STAT_FA = L_FMZUCO-FSTATUS_FT.
  STAT_GR = L_FMZUCO-FSTATUS_GR.
  STAT_BP = L_FMZUCO-FSTATUS_BP.

* In case of display mode
  IF T180-TRTYP = CHARA.
    IF STAT_CI = 1 or STAT_CI = 2.
      STAT_CI = 0.
    ENDIF.
    IF STAT_FC = 1 or STAT_FC = 2.
      STAT_FC = 0.
    ENDIF.
    IF STAT_FU = 1  or STAT_FU = 2.
      STAT_FU = 0.
    ENDIF.
    IF STAT_FA = 1  or STAT_FU = 2.
      STAT_FA = 0.
    ENDIF.
    IF STAT_GR = 1  or STAT_GR = 2.
      STAT_GR = 0.
    ENDIF.
    IF STAT_BP = 1  or STAT_BP = 2.
      STAT_BP = 0.
    ENDIF.
  ENDIF.

ENDFORM.                    "FMII1_INPUT


*&---------------------------------------------------------------------*
*&      Form  check_ps_accass_availablity
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->L_SUBRC    text
*----------------------------------------------------------------------*
form check_ps_accass_availablity using l_subrc.
  data: l_f_fmzuco type fmzuco.

  CALL FUNCTION 'FM_CO_ASS_INPUT_DEMAND_SD'
    EXPORTING
      I_BUKRS              = vbak-bukrs_vf
*   I_FIKRS              =
*   I_VBAK               =
*   I_VBAP               =
    IMPORTING
      E_FMZUCO             = l_f_fmzuco
   EXCEPTIONS
     NO_ENTRY_FOUND       = 1
     OTHERS               = 2.

  if  sy-subrc <> 0
   or l_f_fmzuco-xact_onl = ' '.
    l_subrc = 1.
  else.
    clear l_subrc.
  endif.
endform.                    "check_ps_accass_availablity