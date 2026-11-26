*----------------------------------------------------------------------*
*       Form  SD_LIEFERTYP_ERMITTELN
*----------------------------------------------------------------------*
*  Ermitteln des Liefertyps, so daß bei Erstellung der Lieferung
*  die korrekte Lieferart zugeordnet werden kann.
*----------------------------------------------------------------------*
form sd_liefertyp_ermitteln changing l_xlk03 like komdlgn
                                     l_xmseg like mseg.

  statics:  l_t156q like t156q.

  if not (    l_t156q-bwart   eq l_xmseg-bwart
          and l_t156q-sobkz   eq l_xmseg-sobkz
          and l_t156q-kzbew   eq l_xmseg-kzbew
          and l_t156q-kzzug   eq l_xmseg-kzzug
          and l_t156q-kzvbr   eq l_xmseg-kzvbr ).
*   Daten im Puffer passen nicht   -> Lesen der T159Q
    select single * from t156q into l_t156q
                  where  bwart   eq l_xmseg-bwart
                    and  sobkz   eq l_xmseg-sobkz
                    and  kzbew   eq l_xmseg-kzbew
                    and  kzzug   eq l_xmseg-kzzug
                    and  kzvbr   eq l_xmseg-kzvbr.
    if not sy-subrc is initial.
*   Dummy Eintrag in Puffer stellen
      move: l_xmseg-bwart  to   l_t156q-bwart,
            l_xmseg-sobkz  to   l_t156q-sobkz,
            l_xmseg-kzbew  to   l_t156q-kzbew,
            l_xmseg-kzzug  to   l_t156q-kzzug,
            l_xmseg-kzvbr  to   l_t156q-kzvbr.
    endif.
  endif.
  l_xlk03-dlvtp = l_t156q-dlvtp.
  clear l_xlk03-lfart.

endform.