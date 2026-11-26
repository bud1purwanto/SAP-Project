***INCLUDE MV50AF0F_FCODE_RAUF .
*---------------------------------------------------------------------*
*       FORM FCODE_RAUF                                               *
*---------------------------------------------------------------------*
*       Ein Auftrag soll kopiert werden.                              *
*---------------------------------------------------------------------*
form fcode_rauf using t185f t185 t185v.
* Prüfungen
* Nach Warenausgang keine neuen Positionen
  if xvbuk-wbstk = charc.
    message i121.
    exit.
  endif.

* Nach Faktura keine neuen Positionen
  if xvbuk-fkstk = charc.
    message i186.
    exit.
  endif.

  if status_transport eq 2 or
     status_transport eq 3.
    message i294(vw).
    exit.
  endif.

  call screen 105
       starting at 25 07
       ending   at 78 12.

endform.                    "FCODE_RAUF