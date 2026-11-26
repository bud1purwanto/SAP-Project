*&---------------------------------------------------------------------*
*&      Form  vas_bestellentwicklung_upos
*&---------------------------------------------------------------------*
*       text: fill table vas_ekbe for those subitems which shall be
*             posted in ekbe
*----------------------------------------------------------------------*
FORM vas_bestellentwicklung_upos.

* po history for subitems just in case qty of main item ne po qty
  if zdm07m-bsmng ne xekbe-menge.
    move: xekbe-vgabe to vas_ekbe-vgabe,
          xekbe-bewtp to vas_ekbe-bewtp,
          xekbe-budat to vas_ekbe-budat.
* get relevant subitems from vas_mseg and put them into vas_ekbe
    loop at vas_mseg where ebeln = xekbe-ebeln and
                           uebpo = xekbe-ebelp.
      move-corresponding vas_mseg to vas_ekbe.
      move vas_mseg-bstmg to vas_ekbe-menge.
      move: xekbe-bwart to vas_ekbe-bwart,
            xekbe-gjahr to vas_ekbe-gjahr,
            xekbe-shkzg to vas_ekbe-shkzg.
      append vas_ekbe.
    endloop.
  endif.

ENDFORM.                    " vas_bestellentwicklung_upos