*---------------------------------------------------------------------*
*       FORM   TEXT_FEHLT_VERDICHTET                                  *
*---------------------------------------------------------------------*
*       Ist DETAIL in XFTMAT nicht gesetzt und ist mehr als 1 Eintrag *
*       im Werk, wird die Mail mit YTFMAT-Zeilen ausgegeben           *
*---------------------------------------------------------------------*
FORM TEXT_FEHLT_VERDICHTET TABLES XTLINES STRUCTURE TLINE USING FORMAT.
* Set parameters for possible transaction call from mail (e.g. CO06)
* In case of a summarized missing part mail, there might be several
* materials, but we can only set one parameter. So take the first entry.
  read table ytfmat index 1.
  SET PARAMETER ID 'MAT' FIELD YTFMAT-MATNR.
  SET PARAMETER ID 'WRK' FIELD YTFMAT-WERKS.
* First add an empty line
  CLEAR XTLINES.
  xtlines-tdformat = format.
  APPEND XTLINES.
* Table header: 'List of materials in plant' + plant
  CLEAR XTLINES.
  xtlines-tdformat = format.
  WRITE TEXT-F10 TO XTLINES-tdline.
  concatenate xtlines-tdline ytfmat-werks into xtlines-tdline
              separated by space.
  APPEND XTLINES.
* Underline for table header (length: 34)
  CLEAR XTLINES.
  xtlines-tdformat = format.
  WRITE TEXT-F11 TO XTLINES-tdline.
  APPEND XTLINES.
* Table content: list of material short text and number
* We begin with short text because of its fixed length of 40
* and Enjoy
  LOOP AT YTFMAT.
    CLEAR XTLINES.
    xtlines-tdformat = format.
    WRITE YTFMAT-MAKTX TO XTLINES-tdline.
    write ytfmat-matnr to xtlines-tdline+42.
    APPEND XTLINES.
  ENDLOOP.
  refresh ytfmat.
ENDFORM.