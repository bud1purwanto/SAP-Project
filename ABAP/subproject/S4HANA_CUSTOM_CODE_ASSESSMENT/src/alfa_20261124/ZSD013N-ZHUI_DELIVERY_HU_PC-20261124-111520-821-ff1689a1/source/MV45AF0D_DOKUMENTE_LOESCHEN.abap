*---------------------------------------------------------------------*
*       FORM DOKUMENTE_LOESCHEN                                       *
*---------------------------------------------------------------------*
*       Löschen Dokumentzuordnung zu einer Position                   *
*---------------------------------------------------------------------*
FORM DOKUMENTE_LOESCHEN USING US_POSNR.

  CLEAR DRAD.
  DRAD-OBJKY(10) = VBAK-VBELN.
  DRAD-OBJKY+10(6) = US_POSNR.

  CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
       EXPORTING
            KEY           = DRAD-OBJKY
            OBJEKT        = 'VBAP'
       TABLES
            DOKTAB        = YDRAD
       EXCEPTIONS
            KEIN_DOKUMENT = 1
            OTHERS        = 2.
  CHECK SY-SUBRC = 0.

  LOOP AT YDRAD WHERE OBJKY = DRAD-OBJKY.
    CLEAR YDRAD-OBJKY.
    CALL FUNCTION 'DOCUMENT_ASSIGNS_CHANGE'
         EXPORTING
              DOKAR     = YDRAD-DOKAR
              DOKNR     = YDRAD-DOKNR
              DOKOB     = YDRAD-DOKOB
              DOKVR     = YDRAD-DOKVR
              OBJKY_NEW = YDRAD-OBJKY
              OBJKY_OLD = DRAD-OBJKY
              TLDOK     = YDRAD-DOKTL.
  ENDLOOP.

  CLEAR XDRAD.
  LOOP AT XDRAD WHERE OBJKY = DRAD-OBJKY.
    DELETE XDRAD.
  ENDLOOP.

ENDFORM.