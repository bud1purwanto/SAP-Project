*##ngr-saend
*&---------------------------------------------------------------------*
*&      Form  VKBELEG_ANZEIGEN
*&---------------------------------------------------------------------*
* Es wird in den Funktionsbaustein zur Anzeige der Verkaufswert-
* änderungsbelege gesprungen.
*----------------------------------------------------------------------*
FORM VKBELEG_ANZEIGEN.


  CALL FUNCTION 'SP_REVAL_MATERIAL_DOC_DISPLAY'
       EXPORTING
            PI_MBLNR          = MSEG-MBLNR
            PI_MJAHR          = MSEG-MJAHR
       EXCEPTIONS
            NO_DOCUMENT_FOUND = 1
            SY_MESSAGE        = 2
            OTHERS            = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                               " VKBELEG_ANZEIGEN