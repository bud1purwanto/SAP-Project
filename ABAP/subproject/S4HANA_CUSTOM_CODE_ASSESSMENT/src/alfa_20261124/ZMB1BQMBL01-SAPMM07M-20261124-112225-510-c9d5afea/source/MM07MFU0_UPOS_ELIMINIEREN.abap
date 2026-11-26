*eject
*---------------------------------------------------------------------*
*       FORM UPOS_ELIMINIEREN                                         *
*---------------------------------------------------------------------*
*       Nach Ermitteln von Bestellpositionen über ME_READ_ITEM_GOODS_ *
*       RECEIPT werden Naturalrabattpositionen inkl. ihrer Leergut-   *
*       positionen eliminiert, falls der Einstieg über einen Vorgänger*
*       beleg erfolgte (Avis, Grob-WE), da dort bereits entschieden   *
*       wurde, ob Naturalrabatt übernommen wird oder nicht.           *
*---------------------------------------------------------------------*
FORM upos_eliminieren.
  DATA: leerg_loeschen.

  LOOP AT xebefu.
    IF ( xebefu-uptyp = uptyp_nre OR
         xebefu-uptyp = uptyp_nra ) AND
       sy-tabix > 1.
      DELETE xebefu.
      leerg_loeschen = x.
    ELSEIF xebefu-uptyp = uptyp_lg AND
           leerg_loeschen = x.
      DELETE xebefu.
    ELSE.
      CLEAR leerg_loeschen.
    ENDIF.
  ENDLOOP.

ENDFORM.