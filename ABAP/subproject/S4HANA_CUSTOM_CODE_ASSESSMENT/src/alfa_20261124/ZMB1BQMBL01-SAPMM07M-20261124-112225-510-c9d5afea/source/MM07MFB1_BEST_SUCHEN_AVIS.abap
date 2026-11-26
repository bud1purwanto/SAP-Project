*eject
*----------------------------------------------------------------------*
*               FORM BEST_SUCHEN_AVIS                                  *
*----------------------------------------------------------------------*
*    Bestellungen suchen über Vorgängerbeleg Lieferavis                *
*----------------------------------------------------------------------*
FORM BEST_SUCHEN_AVIS.
  X_AVIS = 'X'.
  IF NOT RM07M-VLIEF IS INITIAL.
    CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
      EXPORTING
        I_VBELN   = RM07M-VLIEF
        I_VBELP   = RM07M-VBELP
      IMPORTING
        VERUR     = VERUR
        BOLNR     = BOLNR
        E_BESTTYP = XBESTTYP
      TABLES
        T_WUEB    = WUEB.
    IF NOT XBESTTYP IS INITIAL.
      IF XBESTTYP NE IBTYP_AVIS.
        SET CURSOR FIELD 'RM07M-VLIEF'.
        MESSAGE E190.
*    Der eingegebene Beleg ist kein Lieferavis
      ENDIF.
    ENDIF.
    IF NOT VERUR IS INITIAL OR NOT BOLNR IS INITIAL.        "qla
      LOOP AT WUEB.
        WUEB-XBLNR_AVIS = VERUR.
        WUEB-FRBNR_AVIS = BOLNR.
        MODIFY WUEB.
      ENDLOOP.
    ENDIF.
    IF NOT verur IS INITIAL AND NOT mkpf-xblnr IS INITIAL        "948472
       AND rm07m-lfsnr IS INITIAL.                               "948472
      CLEAR mkpf-xblnr.                                          "948472
    ENDIF.                                                       "948472
    IF NOT VERUR IS INITIAL AND NOT RM07M-LFSNR IS INITIAL AND"JKr
           VERUR <> RM07M-LFSNR.
*      CLEAR MKPF-XBLNR.                                 "822463 "948472
      CALL FUNCTION 'MB_CHECK_T160M'
        EXPORTING
          I_MSGNR  = '327'
          I_MSGV1  = VERUR
          I_MSGV2  = RM07M-LFSNR
          I_OUTPUT = X.
    ENDIF.                                                  "JKr
  ELSEIF NOT RM07M-TRAID IS INITIAL.
*------------- Suche Lieferavis nach Transportidentifikation -----------
    REFRESH XVMVMB.
    SELECT * FROM SHP_VIEW_TRAI INTO TABLE XVMVMB           "470
                          WHERE TRAID = RM07M-TRAID.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E859.
    ELSE.
      CLEAR LIEF1.
      LOOP AT XVMVMB.
        IF NOT RM07M-EINDT IS INITIAL.
          CHECK XVMVMB-LFDAT IN REINDT.
        ENDIF.
        IF NOT AM07M-LIFNR IS INITIAL.
          CHECK XVMVMB-LIFNR = AM07M-LIFNR.
        ELSE.
          IF LIEF1 IS INITIAL.
            MOVE XVMVMB-LIFNR TO LIEF1.
          ELSE.
            IF XVMVMB-LIFNR NE LIEF1.
              MESSAGE E148.
            ENDIF.
          ENDIF.
        ENDIF.
        IF NOT RM07M-TRATY IS INITIAL.
          CHECK XVMVMB-TRATY = RM07M-TRATY.
        ENDIF.
        CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
          EXPORTING
            I_VBELN   = XVMVMB-VBELN
          IMPORTING
            BOLNR     = BOLNR
            VERUR     = VERUR
            E_BESTTYP = XBESTTYP
          TABLES
            T_WUEB    = XWUEB.
        IF NOT XBESTTYP IS INITIAL.
          IF XBESTTYP NE IBTYP_AVIS.
            SET CURSOR FIELD 'RM07M-TRAID'.
            MESSAGE E190.
*    Der eingegebene Beleg ist kein Lieferavis
          ENDIF.
        ENDIF.
        LOOP AT XWUEB.
          XWUEB-VBELN = XVMVMB-VBELN.
          MOVE XWUEB TO WUEB.
          WUEB-XBLNR_AVIS = VERUR.                          "qla
          WUEB-FRBNR_AVIS = BOLNR.
          COLLECT WUEB.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ELSEIF NOT RM07M-TKNUM IS INITIAL.
*------------- Suche Lieferavis nach Transportnummer -------------------
    CLEAR:   RTKNUM.
    REFRESH: RTKNUM.
    RTKNUM-LOW    = RM07M-TKNUM.
    RTKNUM-SIGN   = I.
    RTKNUM-OPTION = 'EQ'.
    APPEND RTKNUM.

    CALL FUNCTION 'SD_SHINOTIF_FOR_SHIPMENT'
         TABLES
              SHIPMENT_I       = RTKNUM
*             SHINOTIF_I       =
              SHINOTIF_O       = RVLIEF
         EXCEPTIONS
               OTHERS           = 1.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID
              TYPE SY-MSGTY
              NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    LOOP AT RVLIEF.
      CALL FUNCTION 'ME_CONFIRMATION_SEARCH_GR'
        EXPORTING
          I_VBELN   = RVLIEF-LOW
        IMPORTING
          BOLNR     = BOLNR
          VERUR     = VERUR
          E_BESTTYP = XBESTTYP
        TABLES
          T_WUEB    = XWUEB.

      IF NOT XBESTTYP IS INITIAL.
        IF XBESTTYP NE IBTYP_AVIS.
*         Kein Lieferavis => Überspringen
          CONTINUE.
        ENDIF.
      ENDIF.
      LOOP AT XWUEB.
        XWUEB-VBELN = RVLIEF-LOW.
        MOVE XWUEB TO WUEB.
        WUEB-XBLNR_AVIS = VERUR.
        WUEB-FRBNR_AVIS = BOLNR.
        COLLECT WUEB.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "BEST_SUCHEN_AVIS