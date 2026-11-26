*----------------------------------------------------------------------*
*       Form  SD_FEHLENDE_DATEN
*----------------------------------------------------------------------*
*  Anlegen einer Lieferung:
*  Kontrolle, ob Felder bzw. Daten vorliegen, die an die Lieferung
*  nicht übergeben werden können.
*----------------------------------------------------------------------*
form sd_fehlende_daten.

* Serialnummern wurden erfaßt, bevor XDELIV gesetzt werden konnte.
  if not upd_seri is initial.
    message w451.
  endif.

* Frachlieferant wurde verändert (wird nicht unterstützt)
  if not upd_fralief is initial.
    message e452.
  endif.

* Not necessary anymore:
** Es soll Anlieferung mit Bezug zu einer Anlieferung angelegt werden.
*  if not upd_anlief is initial.
*    message e455.
*  endif.

endform.                               " SD_FEHLENDE_DATEN