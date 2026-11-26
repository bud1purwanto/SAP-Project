*----------------------------------------------------------------------*
*       Form  SD_FILL_VBSK
*----------------------------------------------------------------------*
*  Füllen der VBSK und Vergabe einer Nummer für den Sammelgang
*----------------------------------------------------------------------*
form sd_fill_vbsk changing l_vbsk like vbsk.                "HUM

  data: l_numki like inri-nrrangenr.

  clear l_vbsk.
  l_vbsk-mandt = sy-mandt.
  l_vbsk-ernam = sy-uname.
  l_vbsk-erdat = sy-datum.
  l_vbsk-uzeit = sy-uzeit.
  l_vbsk-smart = 'L'.

*- Nummer VBSK für Sammelgang vergeben
  select single * from tvsa where smart = l_vbsk-smart.
  if sy-subrc eq 0.
    l_numki = tvsa-numki.
    call function 'NUMBER_GET_NEXT'
         exporting
              nr_range_nr = l_numki
              object      = 'RV_SAMMG'
         importing
              number      = l_vbsk-sammg.
  else.
    clear l_vbsk.
  endif.

endform.                               " SD_FILL_VBSK