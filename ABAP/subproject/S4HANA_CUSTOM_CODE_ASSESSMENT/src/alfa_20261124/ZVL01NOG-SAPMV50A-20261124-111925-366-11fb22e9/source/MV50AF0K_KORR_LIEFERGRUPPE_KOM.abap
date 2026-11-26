*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_LIEFERGRUPPE_KOM                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_LIEFERGRUPPE_KOMPLETT                               *
*---------------------------------------------------------------------*
*       Beim Sichern einer Lieferung wird geprüft, ob die vorhandenen *
*       Liefergruppen komplett beliefert sind                         *
*  <--  cf_subrc = 0, wenn nach der Korrelation die Lieferung noch exist
*  <--  cf_subrc = 1, wenn nach der Korrelation die LF gelöscht ist.
*---------------------------------------------------------------------*
FORM korr_liefergruppe_komplett  CHANGING cf_subrc.

*  Aupstab enthält alle lieferrelevanten Auftragspositionen, die einer
*  gemeinsamen Prüfung mit anderen Auftragspositionen bedürfen
*  Liefergruppen, Naturalrabatt.
  DATA: aupstab  TYPE vlkor_aupstab WITH HEADER LINE,
        augrtab  TYPE vlkor_augrtab WITH HEADER LINE,
        lt_items TYPE vlkor_t_items WITH HEADER LINE,
        dv_rule  LIKE vbap-uepvw,
        lv_lfsta LIKE vbup-lfsta.

  CHECK v50agl-no_grkor_check   IS INITIAL.                        "AIP

  CLEAR:   lt_items, aupstab, augrtab.
  REFRESH: lt_items, aupstab, augrtab.
  lt_items-sign   = 'I'.
  lt_items-option = 'EQ'.

  CLEAR cf_subrc.

* bei Vorgänger Bestellbezug ist gewährleistet, daß die (Leergut)-
* Stücklisten immer komplett sind, sodaß hier keine weitere
* Verarbeitung erfolgen muß
  READ TABLE xlips INDEX 1.
  IF sy-subrc = 0 AND xlips-vgtyp CA vbtyp_bestell.
    EXIT.
  ENDIF.

* Liefergruppen-Auftragspositionen in aupstab aufnehmen
  IF xlips-vgsys IS INITIAL.                                       "AIP
    IF v50agl-sammelgang = space.
      PERFORM korr_aupstab_insert_lfgrp  TABLES aupstab xvbap.
    ELSE.
      PERFORM korr_aupstab_insert_lfgrp  TABLES aupstab cvbap.
    ENDIF.
  ELSE.                                                            "AIP
*   SPE OUTB add delivery group and kit items to aupstab
    PERFORM korr_aupstab_insert_lfgrp_aip TABLES aupstab.          "AIP
  ENDIF.                                                           "AIP


  READ TABLE aupstab INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
*   L I E F E R G R U P P E N P R U E F U N G
*   Anzahl Positionen bestimmen
    IF xlips-vgsys IS INITIAL.                                     "AIP
      IF v50agl-sammelgang = space.
        PERFORM korr_aupstab_anzlfg TABLES aupstab xvbap.
      ELSE.
        PERFORM korr_aupstab_anzlfg TABLES aupstab cvbap.
      ENDIF.
    ELSE.
*     SPE OUTB Check delivery group for unchecked deliveries
      PERFORM korr_aupstab_anzlfg_spe TABLES aupstab.
    ENDIF.                                                         "AIP

*   Lieferpositionen kumulieren
    PERFORM korr_augrtab_lfgrp TABLES aupstab augrtab.

*   Unvollständige Liefergruppen löschen, wenn nötig
    LOOP AT augrtab WHERE   anzlfa > 0.
      CHECK augrtab-anzaup > augrtab-anzlfg.

*     SPE OUTB remove items from xlips, not mark for deletion
      IF NOT v50agl-ucdel_to_del_comb IS INITIAL.
        v50agl-no_xlips_loeschen = space.
      ENDIF.

*     delivery group incomplete
      IF NOT augrtab-grkor IS INITIAL.
        IF v50agl-sammelgang = space.
*         MESSAGE I089(VL).
          PERFORM message_handling(sapmv50a)
                  USING posnr_low '089' 'I' 'VL'
                        augrtab-grkor space space space.
        ELSE.
          cvbak-vbeln = augrtab-vbeln.
*         MESSAGE E123(VL).
          PERFORM message_handling(sapmv50a)
                  USING posnr_low '123' 'E' 'VL'
                        augrtab-grkor space space space.
          PERFORM korr_delete_lfgrp TABLES lt_items
                                    USING  augrtab-vbeln augrtab-grkor.
        ENDIF.

      ELSE.                                    "SPE OUTB kit incomplete
        IF v50agl-sammelgang = space.
*         no kits in dialog
        ELSE.
*         SPE OUTB check completeness of kits in one delivery, CD or UC
*         kits are so far only part of SPM, not of ERP orders
          cvbak-vbeln = augrtab-vbeln.

          IF v50agl-ucdel_to_del_comb IS INITIAL.
*           Kit & is not complete (kit will be deleted)
            IF 1 = 2. MESSAGE e051(/spe/vl). ENDIF.
            PERFORM message_handling(sapmv50a)
                    USING posnr_low '051' 'E' '/spe/VL'
                          augrtab-spe_struc space space space.
          ELSE.
*           Kit & is not complete (kit will not be converted)
            IF 1 = 2. MESSAGE e054(/spe/vl). ENDIF.
            PERFORM message_handling(sapmv50a)
                    USING posnr_low '054' 'E' '/spe/VL'
                          augrtab-spe_struc space space space.
          ENDIF.

*         delete related items of kit grkor = space
          PERFORM spe_delete_struc TABLES lt_items
                                   USING  augrtab-vbeln
                                          augrtab-spe_struc.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Naturalrabatt Prüfungen mit Korrelation zwischen Unter + Hauptposition
  IF v50agl-sammelgang = space.
    PERFORM naturalrabatt_pruefen TABLES xvbap lt_items.
  ELSE.
    PERFORM naturalrabatt_pruefen TABLES cvbap lt_items.
  ENDIF.

  PERFORM korr_dependent_items_delete TABLES lt_items
                                      USING  xlikp-vbeln.

* If delivery items will be deleted serial numbers must not be updated
  PERFORM sn_update_deactivation.

* Leeren Lieferungskopf löschen
  PERFORM korr_delete_leeren_kopf CHANGING cf_subrc.

ENDFORM.
*eject