*---------------------------------------------------------------------*
*       FORM KUWE2_SELECT_XVBPA                                        *
*---------------------------------------------------------------------*
*       Kopf                                                          *
*       Warenempfänger aus Partnertabelle lesen                       *
*---------------------------------------------------------------------*
FORM KUWE2_SELECT_XVBPA.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'WE'
                                      POSNR_LOW
                                      XVBPA_AKTIND.

  IF XVBPA-PARVW EQ 'WE'.
* Warenempfänger gefunden
    PERFORM KUWEV_FUELLEN_VBADR.
    IF VTCOMWE-KUNNR NE XVBPA-KUNNR OR
       VTCOMWE-VKORG NE VBAK-VKORG OR
       VTCOMWE-VTWEG NE VBAK-VTWEG OR
       VTCOMWE-ABLAD NE XVBPA-ABLAD OR
       VTCOMWE-SPART NE VBAK-SPART.
* Warenempfänger mit Stammsatz
      CLEAR VTCOMWE.
      VTCOMWE-KUNNR = XVBPA-KUNNR.
      VTCOMWE-VKORG = VBAK-VKORG.
      VTCOMWE-VTWEG = VBAK-VTWEG.
      VTCOMWE-SPART = VBAK-SPART.
      VTCOMWE-ABLAD = XVBPA-ABLAD.
      VTCOMWE-NOABLAD = CHARX.
      IF VTCOMWE-KUNNR CN '0 '.        "wg. Fehlerprotokoll
        CALL FUNCTION 'VIEW_KUWEV'
             EXPORTING
                  COMWA  = VTCOMWE
             IMPORTING
                  WEWA   = KUWEV
             EXCEPTIONS
                  OTHERS = 1.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        PERFORM KUWEV_FUELLEN_VBADR.
        PERFORM KUWEV-TXTPA_ERMITTELN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.