*&---------------------------------------------------------------------*
*&      Form  vas_bestellpos_storno
*&---------------------------------------------------------------------*
*       text: take over all vas subitems to a main item from xebefu in
*             case of a reversal
*----------------------------------------------------------------------*
FORM vas_bestellpos_storno.

  DATA:   BEGIN OF h_xekbe OCCURS 0.
          INCLUDE STRUCTURE ekbe.
  DATA:   END OF h_xekbe.
  DATA:   BEGIN OF h_xekbes OCCURS 0.
          INCLUDE STRUCTURE ekbes.
  DATA:   END OF h_xekbes.
  DATA:   BEGIN OF h_xekbez OCCURS 0.
          INCLUDE STRUCTURE ekbez.
  DATA:   END OF h_xekbez.
  DATA:   BEGIN OF h_xekbnk OCCURS 0.
          INCLUDE STRUCTURE ekbnk.
  DATA:   END OF h_xekbnk.
  DATA:   BEGIN OF h_xekbz OCCURS 0.
          INCLUDE STRUCTURE ekbz.
  DATA:   END OF h_xekbz.

* get all vas subitems from xebefu and put them to vas_mseg
  loop at xebefu where uptyp = uptyp_vas.
    clear vas_mseg.
    move-corresponding xebefu to vas_mseg.
    move: xebefu-bstme to vas_mseg-bstme,
* entry uom for subitem must be identical to that one of main item
          mseg-erfme   to vas_mseg-erfme,
          xebefu-bsmng to vas_mseg-bstmg.
* erfmg must be calculated
          clear vas_mseg-erfmg.
* get po history for subitem and calculate exact entry qty  (erfmg)
    refresh: h_xekbe, h_xekbes, h_xekbez, h_xekbnk, h_xekbz.
    CALL FUNCTION 'ME_READ_HISTORY'
         EXPORTING
              ebeln   = xebefu-ebeln
              EBELP   = xebefu-ebelp
              webre   = xebefu-webre
         tables
              xekbe   = h_xekbe
              xekbes  = h_xekbes
              xekbez  = h_xekbez
              xekbnk  = h_xekbnk
              xekbz   = h_xekbz.

    if sy-subrc is initial.
      read table h_xekbe with key belnr = mseg-smbln.
      if sy-subrc is initial.
* now I have exact qty which was posted by the relevant mat. doc.
        move h_xekbe-menge to vas_mseg-bstmg.
      endif.
    endif.

    if vas_mseg-erfme ne vas_mseg-bstme.
* convert order qty to entry qty
      perform vas_umrechnen_bstmg_erfmg.
    else.
* just take over order qty and convert to base uom
      move vas_mseg-bstmg to vas_mseg-erfmg.
      perform vas_basisme_umrechnen using vas_mseg-erfmg
                                          vas_mseg-erfme
                                          xebefu-umren
                                          xebefu-umrez.
    endif.
* take over the subitem and remember main item as vas relevant
    append vas_mseg.
    dm07m-xvash = x.

  endloop.

ENDFORM.                    " vas_bestellpos_storno