*---------------------------------------------------------------------*
*       FORM KUWEV_SELECT_POSITION                                     *
*---------------------------------------------------------------------*
*       Der Warenempfänger wird je Position nachgelesen, da sich die  *
*       Sparte in den Positionen ändern kann.                         *
*       Ferner ist erst hier das liefernde Land für den Zugriff auf   *
*       die Steuerindikatoren bekannt.                                *
*---------------------------------------------------------------------*
FORM KUWEV_SELECT_POSITION USING US_POSNR
                                 VALUE(US_ALAND)
                                 US_SPART
                                 US_ERROR
                        CHANGING CH_SUBRC.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'WE'
                                      US_POSNR
                                      XVBPA_AKTIND.
  IF XVBPA-PARVW EQ 'WE'.
* Warenempfänger mit Stammsatz
    PERFORM KUWEV_FUELLEN_VBADR.
    IF VTCOMWE-KUNNR NE XVBPA-KUNNR OR
       VTCOMWE-VKORG NE VBAK-VKORG OR
       VTCOMWE-VTWEG NE VBAK-VTWEG OR
       VTCOMWE-ABLAD NE XVBPA-ABLAD OR
       VTCOMWE-ALAND NE US_ALAND OR
       VTCOMWE-SPART NE US_SPART OR
       VTCOMWE-ADRNR NE XVBPA-ADRNR OR
       VTCOMWE-AUART NE VBAK-AUART OR
       KUWEV-KUNNR IS INITIAL.
      CLEAR VTCOMWE.
      VTCOMWE-VKORG = VBAK-VKORG.
      VTCOMWE-VTWEG = VBAK-VTWEG.
      VTCOMWE-SPART = US_SPART.
      VTCOMWE-KUNNR = XVBPA-KUNNR.
      VTCOMWE-ABLAD = XVBPA-ABLAD.
      VTCOMWE-ALAND = US_ALAND.        "Land des Werks
      VTCOMWE-NOABLAD = 'X'.
      VTCOMWE-ADRNR = XVBPA-ADRNR.
      VTCOMWE-AUART = VBAK-AUART.

      IF VTCOMWE-KUNNR CN '0 '.        "wg. Fehlerprotokoll
        CALL FUNCTION 'VIEW_KUWEV'
             EXPORTING
                  COMWA   = VTCOMWE
             IMPORTING
                  WEWA    = KUWEV
             EXCEPTIONS
                  NO_KNVV = 1.
        IF SY-SUBRC = 1.
          CLEAR VTCOMWE.
          IF NOT US_ERROR IS INITIAL.
            MESSAGE E210(VP) WITH SY-MSGV1
                                  SY-MSGV2
                                  SY-MSGV3
                                  SY-MSGV4.
          ELSE.
            CH_SUBRC = 1.
            EXIT.
          ENDIF.
        ENDIF.
        PERFORM KUWEV_FUELLEN_VBADR.
        PERFORM KUWEV-TXTPA_ERMITTELN.
      ENDIF.
      CLEAR VTCOMWE-NOABLAD.
    ENDIF.
  ENDIF.

ENDFORM.