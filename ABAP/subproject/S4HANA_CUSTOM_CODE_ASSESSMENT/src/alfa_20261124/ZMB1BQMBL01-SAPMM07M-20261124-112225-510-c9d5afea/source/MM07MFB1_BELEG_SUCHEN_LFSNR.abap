*eject
*&---------------------------------------------------------------------*
*&      Form  BELEG_SUCHEN_LFSNR
*&---------------------------------------------------------------------*
*       Materialibelege zum Lieferschein
*----------------------------------------------------------------------*
FORM BELEG_SUCHEN_LFSNR.               "Version of note 208382
  DATA:
    BEGIN OF LT_MEBEX OCCURS 0,
      MBLNR LIKE M_MEBEX-BELNR,
      MJAHR LIKE M_MEBEX-GJAHR,
      EBELN LIKE M_MEBEX-EBELN,
      LIFNR LIKE EKKO-LIFNR,
      BLDAT LIKE MKPF-BLDAT,
    END OF LT_MEBEX,
    L_LINES TYPE I,
    LS_SEL  TYPE SLIS_SELFIELD,
    LS_FC   TYPE SLIS_FIELDCAT_ALV,
    LT_FC   TYPE SLIS_T_FIELDCAT_ALV,
    ET_ZEILE TYPE TY_T_MBLPO.                                    "406146
  RANGES:
    LR_GJAHR FOR M_MEBEX-GJAHR.

* Use Material document year as selection if filled
  IF NOT RM07M-MJAHR IS INITIAL.
    LR_GJAHR-SIGN = 'I'.
    LR_GJAHR-OPTION = 'EQ'.
    LR_GJAHR-LOW = RM07M-MJAHR.
    APPEND LR_GJAHR.
  ENDIF.
* Select goods receipt documents from M_MEBEX (view on EKBE).
  SELECT EBELN BELNR AS MBLNR GJAHR AS MJAHR
         INTO CORRESPONDING FIELDS OF TABLE LT_MEBEX
         FROM M_MEBEX
         WHERE XBLNR = RM07M-LFSNR
           AND GJAHR IN LR_GJAHR
           AND VGABE = '1'.
  SORT LT_MEBEX BY EBELN MBLNR MJAHR.
  DELETE ADJACENT DUPLICATES FROM LT_MEBEX.
* Read vendor and document date. Performance is not an issue here...
  LOOP AT LT_MEBEX.
    CLEAR: LT_MEBEX-LIFNR, LT_MEBEX-BLDAT.
    SELECT SINGLE LIFNR INTO (LT_MEBEX-LIFNR)
                        FROM EKKO
                        WHERE EBELN = LT_MEBEX-EBELN.
    SELECT SINGLE BLDAT INTO (LT_MEBEX-BLDAT)
                        FROM MKPF
                        WHERE MBLNR = LT_MEBEX-MBLNR
                          AND MJAHR = LT_MEBEX-MJAHR.
    MODIFY LT_MEBEX.
  ENDLOOP.
* If vendor entered, check for equality
  IF NOT RM07M-LIFNR IS INITIAL.
    DELETE LT_MEBEX WHERE LIFNR <> RM07M-LIFNR.
  ENDIF.
  SORT LT_MEBEX BY LIFNR MBLNR MJAHR BLDAT.
  DELETE ADJACENT DUPLICATES FROM LT_MEBEX.
* Number of lines left. Zero: Error. One: Take. More: Popup.
  DESCRIBE TABLE LT_MEBEX LINES L_LINES.
  IF L_LINES = 0.
    MESSAGE E247.
  ENDIF.
  IF L_LINES = 1.
    LS_SEL-TABINDEX = 1.
  ELSE.
*   Prepare the popup
    LS_FC-FIELDNAME = 'LIFNR'. LS_FC-REF_TABNAME = 'EKKO'.
    APPEND LS_FC TO LT_FC.
    LS_FC-FIELDNAME = 'MBLNR'. LS_FC-REF_TABNAME = 'MKPF'.
    APPEND LS_FC TO LT_FC.
    LS_FC-FIELDNAME = 'MJAHR'. LS_FC-REF_TABNAME = 'MKPF'.
    APPEND LS_FC TO LT_FC.
    LS_FC-FIELDNAME = 'BLDAT'. LS_FC-REF_TABNAME = 'MKPF'.
    APPEND LS_FC TO LT_FC.
*   Start
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
         EXPORTING
              I_TABNAME   = 'LT_MEBEX'
              IT_FIELDCAT = LT_FC
         IMPORTING
              ES_SELFIELD = LS_SEL
         TABLES
              T_OUTTAB    = LT_MEBEX.
  ENDIF.
* Leave if the popup has been terminated
  IF LS_SEL-TABINDEX = 0.
    MESSAGE E247.
  ENDIF.
* Fill the material document selected and call BELEG_LESEN
  READ TABLE LT_MEBEX INDEX LS_SEL-TABINDEX.
  RM07M-MBLNR = LT_MEBEX-MBLNR.
  RM07M-MJAHR = LT_MEBEX-MJAHR.
  PERFORM beleg_lesen TABLES et_zeile[].                         "406146
ENDFORM.                     " BELEG_SUCHEN_LFSNR version of note 208382
ENHANCEMENT-POINT MM07MFB1_BELEG_SUCHEN_LFSNR_01 SPOTS ES_SAPMM07M STATIC.