*---------------------------------------------------------------------*
*       FORM VBUK_SELECT_PROBE                                        *
*---------------------------------------------------------------------*
*       Vertriebsbelegkopf probelesen bei externer Nummernvergabe     *
*---------------------------------------------------------------------*
FORM VBUK_SELECT_PROBE USING US_VBELN.

* Probelesen auf Vertriebsbelegkopf

  CALL FUNCTION 'SD_VBUK_SELECT'
       EXPORTING
            I_DOCUMENT_NUMBER  = US_VBELN
       IMPORTING
            E_VBUK             = VBUK
       EXCEPTIONS
            DOCUMENT_NOT_FOUND = 01.

  IF SY-SUBRC = 0.
    PERFORM BELEG_ENTSPERREN(SAPMV45A) USING US_VBELN.
    CLEAR VBUK.
    MESSAGE E319 WITH US_VBELN.
  ENDIF.

ENDFORM.