*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BESTELLUNG_EKBE_FUELL                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_EKBE_FUELLEN                                  *
*---------------------------------------------------------------------*
*       Aus der Lieferung wird die bestellung via EKBE informiert    *
*---------------------------------------------------------------------*
form bestellung_ekbe_fuellen.
* Int.Tab.
  data: xekbe like ekbe occurs 0.

* No PO history for subsequent cross-docking deliveries
  if xlikp-spe_cd_process ne space and
     xlikp-vbtyp eq vbtyp_lino.
    call method /spe/cl_cd_docflow=>read_predecessor
      exporting
        if_delivery    = xlikp-vbeln
      exceptions
        no_cd_process  = 1
        no_predecessor = 2
        others         = 3.
    if sy-subrc eq 0.
      return.
    endif.
  endif.

* Zurücksetzen den Bestellentwicklung
  refresh xekbe.

* Hinzufügen oder Ändern?
  if t180-trtyp ne charh.
*   Ändern
*   Schleife über alle alten Pos. mit Vorgänger=Bestellung
    loop at ylips where vbeln eq xlikp-vbeln
                  and   vgtyp eq charv
                  and   updkz eq updkz_delete.
      perform best_ekbe_aus_lips tables xekbe
                                 using  ylips.
    endloop.
  endif.                               "Hinzufügen oder Ändern?

* Schleife über alle neuen Lieferpos. mit Vorgänger=Best.
  loop at xlips where vbeln eq xlikp-vbeln
                and   vgtyp eq charv
                and ( updkz eq updkz_new    or
                      updkz eq updkz_update ).
    perform best_ekbe_aus_lips tables xekbe
                               using  xlips.
  endloop.                             "xlips

* Falls notwendg, wird die Bestellentwicklung verbucht
  describe table xekbe lines sy-tfill.
  if sy-tfill > 0.
    call function 'ME_STATISTICS_LF_EKBE_LIS'
      tables
        t_ekbe = xekbe.
  endif.
endform.                               "bestellung_ekbe_fuellen