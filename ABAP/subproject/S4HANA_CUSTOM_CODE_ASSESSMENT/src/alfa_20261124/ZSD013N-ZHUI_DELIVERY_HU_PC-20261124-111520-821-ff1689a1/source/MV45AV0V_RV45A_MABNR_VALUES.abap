*----------------------------------------------------------------------*
*   INCLUDE MV45AV0V_RV45A_MABNR_VALUES                                *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       Werte-Hilfe für Feld RV45A-MABNR                              *
*---------------------------------------------------------------------*
MODULE RV45A_MABNR_VALUES.

  DATA: BEGIN OF DA_RETURN_TAB OCCURS 0.
          INCLUDE STRUCTURE DDSHRETVAL.
  DATA: END OF DA_RETURN_TAB.

  DATA: BEGIN OF DA_DYNPROFIELDS OCCURS 0.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF DA_DYNPROFIELDS.

  DATA: DA_ATBNR_INITIAL VALUE SPACE.

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
  DA_DYNPROFIELD = 'RV45A-MABNR'.
  DA_STEPL       = HELP_TABIX.

  CLEAR DA_DISPLAY.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'RV45A-MABNR'.
      IF SCREEN-INPUT = 0.
        DA_DISPLAY = CHARX.
      ENDIF.
      EXIT.
    ENDIF.
  ENDLOOP.

*--------------------------------------------------------------------*
* Material(bestell)nummer und Produktkatalogfindung                  *
*--------------------------------------------------------------------*
  IF TVAK-ERMAT EQ CHARA  OR  TVAK-ERMAT EQ CHARB.
    DA_TABNAME   = 'HELPATBNR'.
    DA_FIELDNAME = 'ATBNR'.

    CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
         EXPORTING
              TABNAME     = DA_TABNAME
              FIELDNAME   = DA_FIELDNAME
              DYNPPROG    = DA_DYNPPROG
              DYNPNR      = DA_DYNPNR
              DYNPROFIELD = DA_DYNPROFIELD
              STEPL       = DA_STEPL
              DISPLAY     = DA_DISPLAY
         TABLES
              RETURN_TAB  = DA_RETURN_TAB.

    IF SY-SUBRC <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


*   wenn RV45A-MABNR nicht gefüllt ist, da bspw. der Katalog ohne
*   Materialbestellnummer arbeitet, also nur VBAP-MATNR gefüllt ist,
*   muß RV45A-MABNR mit VBAP-MATNR gefüllt werden;
*   dies muß hier geschehen, da sonst nie RV45A-MABNR gelöscht werden
*   könnte, da es immer mit VBAP-MATNR wieder gefüllt wird

    MOVE SPACE TO DA_ATBNR_INITIAL.

    LOOP AT DA_RETURN_TAB WHERE FIELDNAME EQ 'ATBNR'.
      IF DA_RETURN_TAB-FIELDVAL IS INITIAL.
        DA_ATBNR_INITIAL = CHARX.
      ENDIF.
    ENDLOOP.

    LOOP AT DA_RETURN_TAB WHERE FIELDNAME EQ 'MATNR'.
      IF NOT DA_RETURN_TAB-FIELDVAL IS INITIAL AND
         DA_ATBNR_INITIAL EQ CHARX.
*        RV45A-MABNR = VBAP-MATNR.
        DA_DYNPROFIELDS-STEPL       = DA_STEPL.

        DA_DYNPROFIELDS-FIELDNAME   = 'VBAP-MATNR'.
        DA_DYNPROFIELDS-FIELDVALUE  = DA_RETURN_TAB-FIELDVAL.
        APPEND DA_DYNPROFIELDS.

        DA_DYNPROFIELDS-FIELDNAME   = DA_DYNPROFIELD.   "RV45A-MABNR
        DA_DYNPROFIELDS-FIELDVALUE  = DA_RETURN_TAB-FIELDVAL.
        APPEND DA_DYNPROFIELDS.

        READ TABLE DA_RETURN_TAB WITH KEY FIELDNAME = 'WMINR'.
        DA_DYNPROFIELDS-FIELDNAME   = 'VBKD-WMINR'.
        DA_DYNPROFIELDS-FIELDVALUE  = DA_RETURN_TAB-FIELDVAL.
        APPEND DA_DYNPROFIELDS.

        READ TABLE DA_RETURN_TAB WITH KEY FIELDNAME = 'CCODE'.
        DA_DYNPROFIELDS-FIELDNAME   = 'RV45A-CCODE'.
        DA_DYNPROFIELDS-FIELDVALUE  = DA_RETURN_TAB-FIELDVAL.
        APPEND DA_DYNPROFIELDS.

        CALL FUNCTION 'DYNP_VALUES_UPDATE'
             EXPORTING
                  DYNAME     = DA_DYNPPROG
                  DYNUMB     = DA_DYNPNR
             TABLES
                  DYNPFIELDS = DA_DYNPROFIELDS.
        IF SY-SUBRC <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

*--------------------------------------------------------------------*
* Material                                                           *
*--------------------------------------------------------------------*
  IF TVAK-ERMAT IS INITIAL.
    PERFORM VBAP_MATNR_VALUES USING 'RV45A-MABNR'.
  ENDIF.




ENDMODULE.






















