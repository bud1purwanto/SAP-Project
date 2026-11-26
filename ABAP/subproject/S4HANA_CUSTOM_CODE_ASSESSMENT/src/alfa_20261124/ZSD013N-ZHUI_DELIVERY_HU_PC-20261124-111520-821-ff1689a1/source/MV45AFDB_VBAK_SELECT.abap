*---------------------------------------------------------------------*
*       FORM VBAK_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundenauftragskopf lesen                                      *
*---------------------------------------------------------------------*
FORM VBAK_SELECT USING VALUE(US_VBELN)
                 CHANGING data_read_from_archive.

  data: i_borident like borident,
        xvbak like vbak occurs 0 with header line.

ENHANCEMENT-POINT VBAK_SELECT_01 SPOTS ES_SAPMV45A STATIC.
  IF BUFFERREAD_FLAG-TABLE_VBAK IS INITIAL.
ENHANCEMENT-SECTION     VBAK_SELECT_02 SPOTS ES_SAPMV45A.
    IF NOT GV_VBAK_SPECIAL_ARCHIVING IS INITIAL.
* VA03 display from archive search range / START
      IF GV_ERDAT_SEL+3(16) = 0.
        GV_ERDAT_SEL-OPTION = 'GE'.    "select all documents from archive
        SELECT SINGLE * FROM VBAK WHERE VBELN EQ US_VBELN.
      ELSEIF GV_ERDAT_SEL-HIGH IS INITIAL.
        GV_ERDAT_SEL-OPTION = 'EQ'.   "exact date has been selected
        SELECT SINGLE * FROM VBAK WHERE VBELN EQ US_VBELN AND ERDAT EQ GV_ERDAT_SEL-LOW.
      ELSE.
        GV_ERDAT_SEL-OPTION = 'BT'.   "a range has been selected
        SELECT SINGLE * FROM VBAK WHERE VBELN EQ US_VBELN AND ERDAT BETWEEN GV_ERDAT_SEL-LOW AND GV_ERDAT_SEL-HIGH.
      ENDIF.
* VA03 display from archive search range / END
    ELSE.
      SELECT SINGLE * FROM VBAK WHERE VBELN EQ US_VBELN.
    ENDIF.
END-ENHANCEMENT-SECTION.
  ELSE.
    CALL FUNCTION 'SD_VBAK_SINGLE_READ'
      EXPORTING
        I_VBELN            = US_VBELN
        I_BYPASSING_BUFFER = CHARB
      IMPORTING
        E_VBAK             = VBAK
      EXCEPTIONS
        RECORD_NOT_FOUND   = 1
        OTHERS             = 2.
  ENDIF.

  IF SY-SUBRC > 0.
    data_read_from_archive = 'X'.
    exit.
  else.
    clear data_read_from_archive.
  endif.  "ARCHIVE
  YVBAK = VBAK.

* Beleg sperren, außer wenn man beim Kopieren auf die Auswahlliste
* geht.
  IF TVCPA-AUARN = SPACE AND
     FCODE NE 'IFLU' AND
     FCODE NE 'IAEN' AND
     POSITIONSVORSCHLAG = SPACE.
    PERFORM BELEG_SPERREN USING US_VBELN
                                CHARX.
  ENDIF.

* Ratenplan zulesen
  IF NOT VBAK-RPLNR IS INITIAL.
*   Lesen Fakturierungsplan
    CALL FUNCTION 'BILLING_SCHEDULE_READ'
      EXPORTING
        FPLNR = VBAK-RPLNR
      TABLES
        ZFPLA = XFPLA
        ZFPLT = XFPLT.
  ENDIF.
* VKORG und KUNNR für Matchcodes setzen
  SET PARAMETER ID 'VKU' FIELD VBAK-VKORG.
  SET PARAMETER ID 'KUN' FIELD VBAK-KUNNR.

ENDFORM.                    "VBAK_SELECT