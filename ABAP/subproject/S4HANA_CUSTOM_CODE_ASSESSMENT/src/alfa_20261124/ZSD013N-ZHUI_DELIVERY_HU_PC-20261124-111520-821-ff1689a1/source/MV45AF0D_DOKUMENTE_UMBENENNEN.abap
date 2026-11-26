*---------------------------------------------------------------------*
*       FORM DOKUMENTE_UMBENENNEN                                     *
*---------------------------------------------------------------------*
*       Dokumentzuordnung mit entgültiger Nummer versehen             *
*---------------------------------------------------------------------*
FORM DOKUMENTE_UMBENENNEN.
* Dokumentzuordnung mit der entgültigen Belegnummer versehen.

  IF T180-TRTYP = CHARH.
    CALL FUNCTION 'DRAD_UPDATES_GET'
         TABLES NEW_DRAD_ENTRIES = XDRAD.
    LOOP AT XDRAD.
      DRAD = XDRAD.
      IF XDRAD-OBJKY(10) = SPACE.
        XDRAD-OBJKY(10) = VBAK-VBELN.
        CALL FUNCTION 'DOCUMENT_ASSIGNS_CHANGE'
             EXPORTING
                  DOKAR     = XDRAD-DOKAR
                  DOKNR     = XDRAD-DOKNR
                  DOKOB     = XDRAD-DOKOB
                  DOKVR     = XDRAD-DOKVR
                  OBJKY_NEW = XDRAD-OBJKY
                  OBJKY_OLD = DRAD-OBJKY
                  TLDOK     = XDRAD-DOKTL.

      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.