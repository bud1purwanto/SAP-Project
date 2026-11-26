*eject
*---------------------------------------------------------------------*
*       MODUELE PPS_AUFTRAG_WA_POP                                    *
*---------------------------------------------------------------------*
*       Der Auftragskopf bei Warenbewegung zum Auftrag... wird        *
*       gelesen.                                                      *
*       Sofern im Auftragskopf eine Reservierung eingetragen ist,     *
*       wird diese gelesen und die Positionen werden in die Tabelle   *
*       FUSS übernommen.                                              *
*---------------------------------------------------------------------*
FORM PPS_AUFTRAG_WA_POP.
  CLEAR:   SELTAB1,
           ORDER_TAB.
  REFRESH: SELTAB1,
           ORDER_TAB.


  IF NOT RM07M-KZVRA IS INITIAL.
    ORDER_TAB-AUFNR = RM07M-AUFNR.
    APPEND ORDER_TAB.
    CALL FUNCTION 'CO_SF_SELECT_OPERATION'
         TABLES
              I_ORDER_TAB   = ORDER_TAB
              E_OPER_TAB    = OPER_TAB
         EXCEPTIONS
              NOTHING_TO_DO = 1
              OTHERS        = 2.
  ENDIF.
  CALL FUNCTION 'CO_SF_HEADER_GOODS_ISSUE'
       EXPORTING
            AUFNR = RM07M-AUFNR
       IMPORTING
            RSNUM = SELTAB1-RSNUM
            GAMNG = RM07M-SOLMG
            GMEIN = RM07M-MEINS.
  RM07M-ERFME = RM07M-MEINS.
  APPEND SELTAB1.
* Check if for this order AFFW entries exists.                   "534257
* Same check for reservations in MM07MFR0_RES_POSITIONEN_UEBE03  "534257
  CALL FUNCTION 'CO_FW_CHECK_AFFW_BY_RSNUM'                      "534257
    EXPORTING                                                    "534257
      I_AUFNR           = RM07M-AUFNR                            "534257
    EXCEPTIONS                                                   "534257
      INPUT_ERROR       = 1                                      "534257
      NOT_FOUND         = 2                                      "534257
      OTHERS            = 3.                                     "534257
* If AFFW entry exits sy-subrc = 0                               "534257
  IF sy-subrc = 0.                                               "534257
    CALL FUNCTION 'MB_CHECK_T160M'                               "534257
      EXPORTING                                                  "534257
        I_ARBGB          = 'M7'                                  "534257
        i_msgnr          =  '398'                                "534257
        I_MSGV1          = RM07M-AUFNR                           "534257
        I_OUTPUT         = 'X' .                                 "534257
  ENDIF.                                                         "534257
  xord_check = 'X'.          "avoid check for reservations       "534257

  PERFORM RESERVIERUNG_LESEN.
ENDFORM.