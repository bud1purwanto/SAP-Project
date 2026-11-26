*---------------------------------------------------------------------*
*       FORM CCODE_LESEN                                              *
*---------------------------------------------------------------------*
*       Tabelle 063C wird gelesen fuer die Koordinaten des Pop-Up's.  *
*---------------------------------------------------------------------*
FORM CCODE_LESEN.

  SELECT SINGLE * FROM T063C WHERE CCODE EQ CCODE.
  IF SY-SUBRC IS INITIAL.
    WHILE CCODE NE SPACE AND T063C-XMODA IS INITIAL.
      PERFORM DYNPRO_CALL.
    ENDWHILE.
    EXIT.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM   CURSOR_POSITIONIEREN                                   *
*---------------------------------------------------------------------*
*       Cursor auf gewuenschtes Feld positionieren                    *
*---------------------------------------------------------------------*
FORM CURSOR_POSITIONIEREN.

  CHECK T158-TRTYP = H.
  CASE SY-DYNNR.
    WHEN 0200.
      GET PARAMETER ID 'BWE' FIELD RM07M-BWART.
      IF NOT RM07M-BWART IS INITIAL OR T158-KZBEW = O.
        SET CURSOR FIELD 'RM07M-EBELN'.
      ELSE.
        SET CURSOR FIELD 'RM07M-BWARTWE'.
      ENDIF.
    WHEN 0201.
      GET PARAMETER ID 'BWE' FIELD RM07M-BWART.
      IF NOT RM07M-BWART IS INITIAL OR T158-KZBEW = O.
        SET CURSOR FIELD 'AM07M-LIFNR'.
      ELSE.
        SET CURSOR FIELD 'RM07M-BWARTWE'.
      ENDIF.
    WHEN 0231.
      PERFORM CURSOR_0421.
    WHEN 0241.
      PERFORM CURSOR_0421.
    WHEN 0300.
      GET PARAMETER ID 'BWE' FIELD RM07M-BWART.
      IF NOT RM07M-BWART IS INITIAL.
        SET CURSOR FIELD 'RM07M-AUFNR'.
      ELSE.
        SET CURSOR FIELD 'RM07M-BWARTWE'.
      ENDIF.
*---- Aufruf aus Transaktion CM01
      IF NOT SY-CALLD IS INITIAL AND SY-BINPT IS INITIAL.
        GET PARAMETER ID 'ANR' FIELD RM07M-AUFNR.
      ENDIF.
    WHEN 0400.
      GET PARAMETER ID 'BWA' FIELD RM07M-BWART.
      IF NOT RM07M-BWART IS INITIAL.
        SET CURSOR FIELD 'RM07M-WERKS'.
      ELSE.
        SET CURSOR FIELD 'RM07M-BWARTWA'.
      ENDIF.
    WHEN 0410.
      IF NOT MSEG-MATNR IS INITIAL.
        CASE DM07M-XWMHD.
          WHEN X.
            SET CURSOR FIELD 'DM07M-MHDAT'.
          WHEN SPACE.
            SET CURSOR FIELD 'MSEG-ERFMG'.
        ENDCASE.
      ELSE.
        SET CURSOR FIELD 'MSEG-MATNR'.
      ENDIF.
    WHEN 0421.
      PERFORM CURSOR_0421.
    WHEN 1406.
      IF RM07M-BWARTWA IS INITIAL.
        SET CURSOR FIELD 'RM07M-BWARTWA'.
      ELSE.
        IF RM07M-WERKS IS INITIAL.
          SET CURSOR FIELD 'RM07M-WERKS'.
        ELSE.
          SET CURSOR FIELD 'RM07M-MATNR'.
        ENDIF.
      ENDIF.
    WHEN 2421.
      IF MSEGK-KDAUF IS INITIAL.
        DYN_24XX = X.
        SET CURSOR FIELD 'MSEGK-KDAUF'.
      ENDIF.
    WHEN 2422.
      IF MSEGK-PS_PSP_PNR IS INITIAL.
        DYN_24XX = X.
        SET CURSOR FIELD 'MSEGK-PS_PSP_PNR'.           "note 350182
      ENDIF.
     WHEN 2423.                                        "note 350182
      IF MSEGK-MAT_KDAUF IS INITIAL.                   "note 350182
        DYN_24XX = X.                                  "note 350182
        SET CURSOR FIELD 'MSEGK-MAT_KDAUF'.            "note 350182
      ENDIF.                                           "note 350182
     WHEN 2424.                                        "note 350182
      IF MSEGK-MAT_PSPNR IS INITIAL.                   "note 350182
        DYN_24XX = X.                                  "note 350182
        SET CURSOR FIELD 'MSEGK-MAT_PSPNR'.            "note 350182
      ENDIF.                                           "note 350182
     WHEN OTHERS.

ENHANCEMENT-POINT CURSOR_POSITIONIEREN_01 SPOTS ES_SAPMM07M.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM CURSOR_0421                                              *
*---------------------------------------------------------------------*
FORM CURSOR_0421.

  CLEAR VW.
  IF FCAUSW-XSELP IS INITIAL.
    IF AKTYP = H.
      LOOP AT INT_COBLF WHERE CUPOS = MOD_ON.
        DATA: BEGIN OF FNAM,
                START(6) VALUE 'MSEGK-',
                FDNAM    LIKE COBLF-FDNAM,
              END OF FNAM.
        FNAM-FDNAM = INT_COBLF-FDNAM.
        ASSIGN TABLE FIELD (FNAM) TO <F>.
        IF <F> IS INITIAL.
          VW = X.
        ENDIF.
        EXIT.
      ENDLOOP.
    ENDIF.
    IF VW IS INITIAL.
      LOOP AT SCREEN.
        IF SCREEN-REQUIRED = MOD_ON.
          ASSIGN TABLE FIELD (SCREEN-NAME) TO <F>.
          IF NOT SY-SUBRC IS INITIAL.
            MESSAGE E103 WITH SCREEN-NAME '<F>'.
          ENDIF.
          IF <F> IS INITIAL.
ENHANCEMENT-SECTION     CURSOR_0421_01 SPOTS ES_SAPMM07M.
            SET CURSOR FIELD SCREEN-NAME.
END-ENHANCEMENT-SECTION.
            VW = X.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF VW IS INITIAL AND DYN_24XX IS INITIAL.
      IF XMATE IS INITIAL.
        SET CURSOR FIELD 'MSEG-MATNR' LINE 1.
      ELSE.
        SET CURSOR FIELD 'MSEG-ERFMG' LINE 1.
      ENDIF.
    ENDIF.
  ELSE.
    SET CURSOR FIELD 'RM07M-XSELK' LINE 1.
  ENDIF.
  CLEAR: VW, DYN_24XX.

ENDFORM.
*

*---------------------------------------------------------------------*
*       FORM CHECK_KZBEW                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  XWERT                                                         *
*  -->  MBVAL                                                         *
*  -->  KZBEW                                                         *
*---------------------------------------------------------------------*
form check_movement using xwert mbval kzbew vgart brazil inventur.
  if ( vgart eq 'WQ' or not brazil is initial
                or  not inventur is initial )
                    and not mbval is initial.
    message e273(m7).
  endif.
endform.
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_FACTORS_CLEAR
*&---------------------------------------------------------------------*
*       Added by note 458130
*       This form is called when mseg-erfmg is changes on screen
*       210 (mb01), 310 (mb31).
*       New unit conversion is necessary -> the old
*       values of dm07m-umrez and dm07m-umren have to be cleared
*       otherwise MB_UNIT_CONVERSION would use them.
*----------------------------------------------------------------------*
form conversion_factors_clear.
  clear: dm07m-umren, dm07m-umrez.
endform.                    " CONVERSION_FACTORS_CLEAR
*&---------------------------------------------------------------------*
*&      Form  conversion_factors_clear_fuss
*&---------------------------------------------------------------------*
*       Added by note 792756
*       This form is called when mseg-erfmg is changed on screen 321
*       (mb31)
*----------------------------------------------------------------------*
FORM conversion_factors_clear_fuss.
  CLEAR: fuss-umrez, fuss-umren.
  MODIFY fuss TRANSPORTING umrez umren
    WHERE zeile = mseg-zeile.
ENDFORM.                               " conversion_factors_clear_fuss