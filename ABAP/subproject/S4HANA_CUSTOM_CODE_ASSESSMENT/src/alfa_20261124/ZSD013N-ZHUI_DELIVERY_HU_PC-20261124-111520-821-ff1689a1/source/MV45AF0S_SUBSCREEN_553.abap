*---------------------------------------------------------------------*
*       FORM SUBSCREEN_553                                            *
*---------------------------------------------------------------------*
*       Ermitteln Subscreen für Dynpro 553                            *
*       Beschaffung:  BANF/FAUF/PAUF/Netz/Service                     *
*---------------------------------------------------------------------*
FORM SUBSCREEN_553.

* Default: leerer Subscreen
  DYNPRO_SUB = '6553'.

* BANF
  IF NOT VBEP-BNFPO IS INITIAL.
    DYNPRO_SUB = '1553'.
  ENDIF.

* PAUF
  IF NOT VBEP-PLNUM IS INITIAL.
    DYNPRO_SUB = '2553'.
  ENDIF.

  IF NOT VBEP-AUFNR IS INITIAL.

    PERFORM T459K_LESEN(SAPMV45A).
    PERFORM T003O_SELECT(SAPMV45A) USING T459K-AUART
                                         CHARX
                                         SY-SUBRC.

    CASE T003O-AUTYP.
      WHEN FAUF.
        DYNPRO_SUB = '3553'.
      WHEN PROZESS.
        DYNPRO_SUB = '3553'.
      WHEN NETZ.
        DYNPRO_SUB = '4553'.
      WHEN SERVICE.
        DYNPRO_SUB = '5553'.
    ENDCASE.

  ENDIF.

ENDFORM.