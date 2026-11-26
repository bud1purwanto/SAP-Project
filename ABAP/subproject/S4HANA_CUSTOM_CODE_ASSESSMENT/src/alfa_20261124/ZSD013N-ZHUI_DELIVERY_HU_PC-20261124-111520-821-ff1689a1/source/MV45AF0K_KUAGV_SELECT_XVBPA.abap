*---------------------------------------------------------------------*
*       FORM KUAGV_SELECT_XVBPA                                        *
*---------------------------------------------------------------------*
*       Auftraggeber aus Partnertabelle lesen                         *
*---------------------------------------------------------------------*
FORM KUAGV_SELECT_XVBPA.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'AG'
                                      POSNR_LOW
                                      XVBPA_AKTIND.
  IF XVBPA-PARVW = 'AG'.
* Auftraggeber gefunden
    IF NOT XVBPA-ADRNR IS INITIAL AND
       XVBPA-ADRNR = XVBADR-ADRNR.
      MOVE-CORRESPONDING XVBADR TO KUAGV.
      PERFORM KUAGV-TXTPA_ERMITTELN.
    ENDIF.
    IF VTCOMAG-KUNNR NE XVBPA-KUNNR OR
       VTCOMAG-VKORG NE VBAK-VKORG OR
       VTCOMAG-VTWEG NE VBAK-VTWEG OR
       VTCOMAG-SPART NE VBAK-SPART.
      CLEAR VTCOMAG.
      VTCOMAG-KUNNR = XVBPA-KUNNR.
      VTCOMAG-VKORG = VBAK-VKORG.
      VTCOMAG-VTWEG = VBAK-VTWEG.
      VTCOMAG-SPART = VBAK-SPART.
      VTCOMAG-AUART = VBAK-AUART.

      CALL FUNCTION 'VIEW_KUAG2'
           EXPORTING
                COMWA  = VTCOMAG
                INIT_KUAGV = CHARX
           IMPORTING
                AGWA   = KUAGV
           EXCEPTIONS
                OTHERS = 1.
      IF SY-SUBRC <> 0.
*     Damit bei Enter nach einer Fehlermeldung die Meldung erneut kommt
        IF SY-MSGTY EQ CHARE.
          CLEAR VTCOMAG.
        ENDIF.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
      IF NOT XVBPA-ADRNR IS INITIAL AND
         XVBPA-ADRNR = XVBADR-ADRNR.
        MOVE-CORRESPONDING XVBADR TO KUAGV.
      ENDIF.
      PERFORM KUAGV-TXTPA_ERMITTELN.

    ENDIF.
  ENDIF.

ENDFORM.