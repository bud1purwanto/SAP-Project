*---------------------------------------------------------------------*
*       FORM DOKUMENTE_PFLEGEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten Dokumente aus Positionsebene                       *
*---------------------------------------------------------------------*
FORM DOKUMENTE_PFLEGEN USING   US_T185F
                               US_T185
                               US_T185V.

  DATA: DA_AEND.
  DATA: DA_OPCODE.
  DATA: DA_EXIST.
  CLEAR DRAD.
  DRAD-OBJKY(10) = VBAK-VBELN.
  DRAD-OBJKY+10(6) = VBAP-POSNR.

* Solange die Dokumentenverwaltung nur ein Objekt verwalten kann:
* DRAD_REFRESH = CHARX.     " Später nur im BELEG_INITIALISIEREN
  IF T180-TRTYP = CHARA.
    DA_OPCODE = CHAR3.
  ELSE.
    IF VBAPD-UPDKZ = UPDKZ_NEW.
      DA_OPCODE = CHAR2.
    ELSE.
      DA_OPCODE = CHAR2.
    ENDIF.
  ENDIF.

  DA_EXIST = CHARX.
  CALL FUNCTION 'DOCUMENT_ASSIGNMENT'
       EXPORTING
            CHECK_EXIST     = DA_EXIST
            DOKOB           = 'VBAP'
            DOKOB_VORLAGE   = ' '
            OBJKY           = DRAD-OBJKY
            OBJKY_VORLAGE   = ' '
            OBJTXT          = ' '
            OPCODE          = DA_OPCODE
            REFRESH_FLAG    = DRAD_REFRESH
            VORSCHLAG_DOKAR = ' '
       IMPORTING
            VB_FLAG         = DA_AEND
       TABLES
            TABDRAD         = XDRAD.
  CLEAR DRAD_REFRESH.
  IF DA_AEND NE SPACE.
    R185D-DATALOSS = DA_AEND.
  ENDIF.

ENDFORM.