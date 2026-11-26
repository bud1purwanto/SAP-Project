*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_FOLGEDATEN                                        *
*---------------------------------------------------------------------*
*       Zum Buchen werden die Folgedaten aufbereitet.                 *
*---------------------------------------------------------------------*
FORM BUCHEN_FOLGEDATEN.

  LOOP AT XMSEG.
    READ TABLE XVM07M INDEX XMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'XVM07M' XMSEG-ZEILE.
    ENDIF.
    READ TABLE YMBUZ INDEX XMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'YMBUZ' XMSEG-ZEILE.
    ENDIF.
    READ TABLE ZDM07M INDEX YMBUZ-ZEILZ.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZDM07M' YMBUZ-ZEILZ.
    ENDIF.
*   Note 385355
*   For form routines with renumberich of zeile, it is necessary to
*   read zmbuz as well as it points to the old YMSEG line. This is
*   needed for applications creating their internal table with a pointer
*   to YMSEG-ZEILE in SEGMENT_HINZUFUEGEN.
*   Example application: see QSS_SEGMENT_GENERIEREN. A similar solution
*   was implemented for serial numbers in form BUCHEN_AUSFUEHREN with
*   internal table lt_sermbuz.
*   CAREFUL: the solution here is based on the principle that no
*   subroutine below makes a new reading of zmbuz!
*
*   YMBUZ = index between XMSEG and ZMSEG (ZMSEG contains zero lines)
*                                         (XMSEG has transfer lines)
*           XMSEG-ZEILE = tabix of YMBUZ
*           ZMSEG-ZEILE = YMBUZ-ZEILZ
*
*   ZMBUZ = index between ZMSEG and YMSEG (YMSEG contains F12 lines)
*
*           ZMSEG-ZEILE = YMBUZ-ZEILZ = tabix of ZMBUZ
*           YMSEG-ZEILE = ZMBUZ-ZEILY
*
*   So we can find the right ZMBUZ with tabix = YMBUZ-ZEILZ.
*   The YMSEG-ZEILE is contained in ZMBUZ-ZEILY.
    READ TABLE zmbuz INDEX ymbuz-zeilz.                "385355
    IF sy-subrc <> 0.                                  "385355
      MESSAGE E001 with 'ZMBUZ' ymbuz-zeilz.           "385355
    ENDIF.                                             "385355

    PERFORM I-SEGMENT_GENERIEREN.
    IF_FIRST.
    PERFORM R-SEGMENT_GENERIEREN.
    PERFORM QSS_SEGMENT_GENERIEREN.
    PERFORM LVS_SEGMENT_GENERIEREN.
    END_FIRST.
    PERFORM PPS_SEGMENT_GENERIEREN.
    IF_FIRST.
    PERFORM V-SEGMENT_GENERIEREN.
    END_FIRST.
    PERFORM STATISTIK_GENERIEREN.
    IF_FIRST.
    PERFORM SD_BELEGFLUSS_GENERIEREN.
    PERFORM CHARGENVERWENDUNGSNACHWEIS.
ENHANCEMENT-POINT BUCHEN_FOLGEDATEN_01 SPOTS ES_SAPMM07M.
    END_FIRST.
  ENDLOOP.
  PERFORM I-SEGMENTE_ERGAENZEN.
  IF_FIRST.
  PERFORM LVS_SEGMENTE_ERGAENZEN.
  END_FIRST.
  PERFORM PPS_SEGMENTE_ERGAENZEN.
  PERFORM J_1B_NF_DOCUMENT_GENERATE.   "localization Brazil
  PERFORM SERIALNUMBER_USER_EXIT TABLES XMSEG
                                        XEKBE.

ENDFORM.