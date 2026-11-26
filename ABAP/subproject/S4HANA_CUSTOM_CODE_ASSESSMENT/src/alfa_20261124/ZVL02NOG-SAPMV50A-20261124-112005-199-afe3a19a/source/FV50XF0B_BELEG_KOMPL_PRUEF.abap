***INCLUDE FV50XF0B_BELEG_KOMPL_PRUEF.
*---------------------------------------------------------------------*
*       FORM BELEG_KOMPLETTLIEFERUNG_PRUEF                            *
*---------------------------------------------------------------------*
*                                                                     *
*       Alle betroffenen Aufträge werden überprüft, ob für sie        *
*       Komplettlieferung vorliegt.                                   *
*       . im Falle der normalen lieferbearbeitung sind es alle        *
*         Aufträge                                                    *
*       . im Falle des Sammelgangs alle Aufträge zu dieser Lieferung  *
*---------------------------------------------------------------------*
form beleg_komplettlieferung_pruef using bkp_subrc like sy-subrc.

  data: bkp_vbeln like likp-vbeln.

  bkp_subrc = 0.

  if v50agl-sammelgang = space.
*   VL01 und VL02
    loop at xvbuk where vbtyp ca vbtyp_verk.
*    IF XVBUK-LFGSK NE CHARC.                             "DEL 31G
      if ( xvbuk-lfgsk ne charc and xvbuk-lfstk ne charc ). "INS 31G
        perform message_handling using 0                     "v_n_576929
                                 '049'
                                 'W'
                                 'VL'
                                 space
                                 space
                                 space
                                 space.
*       lines deleted                           "n_317572old "^_n_576929
        exit.
      endif.
    endloop.
  else.
*   Sammelgang
*   prüfen ob Vollieferung für einen beteiligten Auftrag verletzt
    loop at cvbls where vbeln_lif eq xlikp-vbeln.
      vbukkey-mandt = xlikp-mandt.
      vbukkey-vbeln = cvbls-vbeln.
      read table xvbuk with key vbukkey binary search.
*    IF XVBUK-LFGSK NE CHARC.                             "DEL 31G
      if ( xvbuk-lfgsk ne charc and xvbuk-lfstk ne charc ). "INS 31G
        bkp_vbeln = xvbuk-vbeln.
        bkp_subrc = 4.
        exit.
      endif.
      if tvshp-kzautlf = space.
*   Auftrag soll nicht in mehrere Lieferungen gesplittet sein:
*   Ist der Auftrag auch in einer anderen Lieferung ?
        loop at cvbls where vbeln eq cvbls-vbeln
                   and vbeln_lif ne xlikp-vbeln.
          bkp_vbeln = cvbls-vbeln.
          bkp_subrc = 8.
          exit.
        endloop.
        check bkp_subrc ne 8.
      endif.
    endloop.
    if bkp_subrc gt 0.
*   bei VL04 wurde eine Verletzung der Komplettlieferung gefunden
*   Hinweis auf alle Aufträge
      loop at cvbls where vbeln_lif eq xlikp-vbeln.
        cvbak-vbeln = cvbls-vbeln.     "Auftragsnr fuer Protokoll
        if cvbls-vbeln eq bkp_vbeln.
          perform message_handling           using posnr_low
                                                '049'
                                                'E'
                                                'VL'
                                                space
                                                space
                                                space
                                                space.
        else.
          perform message_handling           using posnr_low
                                                '117'
                                                'E'
                                                'VL'
                                                bkp_vbeln
                                                space
                                                space
                                                space.
        endif.
      endloop.
*   der komplette Vorgang ist zu löschen
      refresh ilips.
      likp = xlikp.
      loop at xlips where updkz ne updkz_delete  and
                          vbeln eq xlikp-vbeln.
        lips = xlips.                                       "46A
        perform xlips_loeschen(sapfv50p) using charx sy-tabix.
      endloop.
      perform lieferkopf_loeschen(saplv50s).
      bkp_subrc = 0.

    endif.
  endif.

endform.