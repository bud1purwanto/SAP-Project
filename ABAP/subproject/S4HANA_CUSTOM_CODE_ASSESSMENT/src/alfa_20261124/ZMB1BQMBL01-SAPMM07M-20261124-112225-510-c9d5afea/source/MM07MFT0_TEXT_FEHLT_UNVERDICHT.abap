*---------------------------------------------------------------------*
*       FORM   TEXT_FEHLT_UNVERDICHTET                                *
*---------------------------------------------------------------------*
*       Ist DETAIL in XFTMAT gesetzt oder ist nur ein Eintrag pro     *
*       Werk, wird die Mail mit XTFEHL_ZEILEn ausgegeben              *
*---------------------------------------------------------------------*
FORM TEXT_FEHLT_UNVERDICHTET TABLES XTLINES STRUCTURE TLINE
                             USING FORMAT.

* Set parameters for possible transaction call from mail (e.g. CO06)
  SET PARAMETER ID 'MAT' FIELD XTFMAT-MATNR.
  SET PARAMETER ID 'WRK' FIELD XTFMAT-WERKS.
* 1st header line: material number and short text (F01 = 'Material')
  CLEAR XTLINES.
  xtlines-tdformat = format.
  CONCATENATE TEXT-F01 XTFMAT-MATNR XTFMAT-MAKTX INTO XTLINES-tdline
              SEPARATED BY SPACE.                           "note 364059
  APPEND XTLINES.
* 2nd header line: plant (F02 = 'Plant')
  CLEAR XTLINES.
  xtlines-tdformat = format.
  CONCATENATE TEXT-F02 XTFMAT-WERKS INTO XTLINES-tdline
               SEPARATED BY SPACE.                          "note 364059
  APPEND XTLINES.
* Empty line before table
  CLEAR XTLINES.
  xtlines-tdformat = format.
  APPEND XTLINES.
* Table header for MRP requirements (F3A: length 71)
  CLEAR XTLINES.
  xtlines-tdformat = format.
  WRITE  TEXT-F3A TO XTLINES-tdline.
  APPEND XTLINES.
* Underline for table header (F3B: length 71)
  CLEAR XTLINES.
  xtlines-tdformat = format.
  WRITE  TEXT-F3B TO XTLINES-tdline.
  APPEND XTLINES.
* Table content: list of MRP requirements. If there are more than
* 5 MRP requirements we exit from loop because anyway the user will
* have to work all MRP requirements through transaction CO06 so it is
* better to keep the mail small. Index_f = counter for MRP requirements.
* If more than 5, text F03 '*** list is incomplete ***
  CLEAR INDEX_F.
  LOOP AT YTFEHL WHERE WERKS = XTFMAT-WERKS
                 AND   MATNR = XTFMAT-MATNR.
    INDEX_F = INDEX_F + 1.
    CLEAR XTLINES.
    xtlines-tdformat = format.
    IF INDEX_F GT 5.
*     More than 5 MRP requirements. Stop here.
      WRITE TEXT-F03 TO XTLINES-tdline.
      APPEND XTLINES.
      EXIT.
    ELSE.
      WRITE YTFEHL-DAT00 TO XTLINES-tdline(10).
      WRITE YTFEHL-DELB1 TO XTLINES-tdline+12(10).
      WRITE YTFEHL-DELNR TO XTLINES-tdline+23(10).
      WRITE '/' TO XTLINES-tdline+33(1).
      WRITE YTFEHL-DELPS TO XTLINES-tdline+34(6).
      WRITE YTFEHL-MNG01 NO-SIGN TO XTLINES-tdline+42(14).
      WRITE YTFEHL-MNG02 NO-SIGN TO XTLINES-tdline+57(14).
      APPEND XTLINES.
    ENDIF.
  ENDLOOP.
ENDFORM.