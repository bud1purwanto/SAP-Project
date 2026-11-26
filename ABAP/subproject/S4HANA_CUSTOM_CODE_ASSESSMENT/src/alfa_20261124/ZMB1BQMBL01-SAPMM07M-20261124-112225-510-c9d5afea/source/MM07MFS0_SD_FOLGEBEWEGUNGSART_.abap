*----------------------------------------------------------------------*
*       Form  SD_FOLGEBEWEGUNGSART_ERMITTELN
*----------------------------------------------------------------------*
*      Bei Umlagerungen wird die Folgebewegungsart
*      mitgegeben (z.B. bei 303 wird 305 mitgegeben)
*----------------------------------------------------------------------*
FORM sd_folgebewegungsart_ermitteln CHANGING l_xlk03 LIKE komdlgn.

  DATA: l_xlk03_folgebewegung LIKE komdlgn,
        l_xmseg_folgebewegung LIKE mseg.

  SELECT SINGLE * FROM t156n
                 WHERE fcode = 'SU'
                   AND bwart = xmseg-bwart.
  IF sy-subrc IS INITIAL.
    l_xlk03-fobwa = t156n-bwart_next.
  ELSE.
    CLEAR l_xlk03-fobwa.
  ENDIF.

* Liefertyp der Folgebewegungsart ermitteln:
  IF NOT l_xlk03-fobwa IS INITIAL.
    CLEAR: l_xlk03_folgebewegung, l_xmseg_folgebewegung.
    l_xlk03_folgebewegung = l_xlk03.
    l_xmseg_folgebewegung = xmseg.
    l_xmseg_folgebewegung-bwart = l_xlk03-fobwa.
    PERFORM sd_liefertyp_ermitteln CHANGING l_xlk03_folgebewegung
                                            l_xmseg_folgebewegung.
    l_xlk03-fo_dlvtp = l_xlk03_folgebewegung-dlvtp.
  ENDIF.

ENDFORM.                               " SD_FOLGEBEWEGUNGSART_ERMITTELN