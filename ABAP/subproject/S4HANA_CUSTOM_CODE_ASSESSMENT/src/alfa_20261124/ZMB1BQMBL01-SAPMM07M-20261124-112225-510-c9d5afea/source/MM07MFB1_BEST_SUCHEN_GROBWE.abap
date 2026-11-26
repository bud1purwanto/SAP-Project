*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_GROBWE                                *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Vorgängerbeleg Grob-WE                   *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_GROBWE.
  X_GROBWE = 'X'.
  IF NOT RM07M-GWELF IS INITIAL.
    CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
         EXPORTING
              I_VBELN   = RM07M-GWELF
         IMPORTING
              BOLNR     = BOLNR
              VERUR     = VERUR
              E_BESTTYP = XBESTTYP
         TABLES
              T_WUEB    = WUEB.
    IF NOT XBESTTYP IS INITIAL.
      IF XBESTTYP NE IBTYP_GROBWE.
        SET CURSOR FIELD 'RM07M-GWELF'.
        MESSAGE E346.
*       Der eingegebene Beleg ist kein Grob-WE
      ENDIF.
    ENDIF.
    IF NOT VERUR IS INITIAL OR NOT BOLNR IS INITIAL.
      LOOP AT WUEB.
        WUEB-XBLNR_AVIS = VERUR.
        WUEB-FRBNR_AVIS = BOLNR.
        MODIFY WUEB.
      ENDLOOP.
    ENDIF.
  ELSE.
*------------- Suche Grob-WE nach Lieferscheinnummer -------------------
    REFRESH XVMVGA.
    SELECT * FROM SHP_IDX_ROGR INTO TABLE XVMVGA        "#EC CI_NOFIELD
                          WHERE VERUR = RM07M-GWELS.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E859.
    ELSE.
      CLEAR LIEF1.
      LOOP AT XVMVGA.
        IF NOT AM07M-LIFNR IS INITIAL.
          CHECK XVMVGA-LIFNR = AM07M-LIFNR.
        ELSE.
          IF LIEF1 IS INITIAL.
            MOVE XVMVGA-LIFNR TO LIEF1.
          ELSE.
            IF XVMVGA-LIFNR NE LIEF1.
              MESSAGE E148.
            ENDIF.
          ENDIF.
        ENDIF.
        CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
             EXPORTING
                  I_VBELN   = XVMVGA-VBELN
             IMPORTING
                  BOLNR     = BOLNR
                  VERUR     = VERUR
                  E_BESTTYP = XBESTTYP
             TABLES
                  T_WUEB    = XWUEB.
        IF NOT XBESTTYP IS INITIAL.
          IF XBESTTYP NE IBTYP_GROBWE.
            SET CURSOR FIELD 'RM07M-GWELS'.
            MESSAGE E346.
*           Der eingegebene Beleg ist kein Grob-WE
          ENDIF.
        ENDIF.
        LOOP AT XWUEB.
          XWUEB-VBELN = XVMVGA-VBELN.
          MOVE XWUEB TO WUEB.
          WUEB-XBLNR_AVIS = VERUR.
          WUEB-FRBNR_AVIS = BOLNR.
          COLLECT WUEB.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.