*---------------------------------------------------------------------*
*       FORM FCODE_TCEN                                               *
*---------------------------------------------------------------------*
*       entsperrt den Text Edit Control                               *
*---------------------------------------------------------------------*
FORM FCODE_TCEN.

  DATA: DA_TABIX LIKE SY-TABIX.

* Steuerdaten des Textes holen
  LOOP AT XTHEAD WHERE TDID = TVAK-TDID
                   AND TDOBJECT = 'VBBK'
                   AND ( TDSPRAS = SY-LANGU OR
                         TDSPRAS = SPACE OR
                         TDSPRAS = CHAR* )
                   AND UPDKZ NE UPDKZ_DELETE.
    DA_TABIX = SY-TABIX.
  ENDLOOP.
  CHECK SY-SUBRC EQ 0.

* Datenverlust droht
  R185D-DATALOSS = CHARX.

  CLEAR: XTHEAD-TDREFOBJ,
         XTHEAD-TDREFNAME,
         XTHEAD-TDREFID.
  MODIFY XTHEAD INDEX DA_TABIX.
  MOVE-CORRESPONDING XTHEAD TO THEAD.
* Text in das Verbuchungsmemory schreiben
  CALL FUNCTION 'SAVE_TEXT'
       EXPORTING
            HEADER        = THEAD
*               INSERT        = ' '
       IMPORTING
            FUNCTION      = TXTFUNCTION
            NEWHEADER     = THEAD
       TABLES
            LINES         = TLINETAB
       EXCEPTIONS
            ID            = 1
            LANGUAGE      = 2
            NAME          = 3
            OBJECT        = 5.

* Eingabebereitschaft des Text Edit Control setzen
  CLEAR TEXT_CONTROL_REFERIERT.
  TEXT_CONTROL_READY_FOR_INPUT = CHARX.

ENDFORM.