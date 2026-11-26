*---------------------------------------------------------------------*
*       MODULE VBAP_LSTANR_VALUES.                                    *
*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld VBAP-LSTANR                              *
*---------------------------------------------------------------------*
MODULE VBAP_LSTANR_VALUES.

  GET CURSOR FIELD HELP_F LINE HELP_TABIX.
  IF HELP_TABIX GT 0.
    READ TABLE SVBAP INDEX HELP_TABIX.
    IF SY-SUBRC EQ 0.
      READ TABLE XVBAP INDEX SVBAP-TABIX.
      HELP_VBAP = XVBAP.
    ENDIF.
  ELSE.
    HELP_VBAP = VBAP.
  ENDIF.

  DA_DYNPPROG    = SY-REPID.
  DA_DYNPNR      = SY-DYNNR.
  DA_DYNPROFIELD = 'VBAP-LSTANR'.
  DA_STEPL       = HELP_TABIX.

  CLEAR DA_DISPLAY.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'VBAP-LSTANR'.
      IF SCREEN-INPUT = 0.
        DA_DISPLAY = CHARX.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF HELP_VBAP-UEPVW EQ CROSS_SELLING.
    DA_TABNAME   = 'MATS_CS_OV'.
    DA_FIELDNAME = 'LSTACS'.
  ELSE.
    DA_TABNAME   = 'VBAP'.
    DA_FIELDNAME = 'LSTANR'.
  ENDIF.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
       EXPORTING
            TABNAME     = DA_TABNAME
            FIELDNAME   = DA_FIELDNAME
            DYNPPROG    = DA_DYNPPROG
            DYNPNR      = DA_DYNPNR
            DYNPROFIELD = DA_DYNPROFIELD
            STEPL       = DA_STEPL
            DISPLAY     = DA_DISPLAY.

ENDMODULE.


























