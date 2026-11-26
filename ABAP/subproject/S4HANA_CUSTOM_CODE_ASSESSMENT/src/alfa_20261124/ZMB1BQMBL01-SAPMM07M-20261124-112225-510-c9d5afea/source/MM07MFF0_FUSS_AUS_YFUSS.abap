*eject
*---------------------------------------------------------------------*
*       FORM FUSS_AUS_YFUSS                                           *
*---------------------------------------------------------------------*
*       Die interne Tabelle FUSS wird aus der vorläufigen YFUSS       *
*       gefüllt, die nur geprüfte Positionen enthält.                 *
*---------------------------------------------------------------------*
FORM fuss_aus_yfuss.

  DATA zeile_diff      LIKE f_zeile.
* line number of structured article (HEAD)                "note 631750
  DATA strukt_kopf_zeile LIKE mseg-zeile.                 "note 631750
  DATA ls_parent_fuss  LIKE fuss.
  LOOP AT yfuss.
    fuss = yfuss.
    f_zeile = f_zeile + 1.
    IF T158-kzbew = o AND NOT xmbwl is initial.
*     Renumber of lines does not work in case of subsequent
*     adjustment process via MB_CREATE as one can choose the items
*     before MB_CREATE has been called. But the former source
*     intends to have a complete document.
*     To ensure that MB04 and other MB* transactions are not
*     distroyed by this correction, we use the new logic only
*     in the known case although the following might as well
*     be correct for all processes.
      IF fuss-urzei IS INITIAL.
*       Do not allow to process e.g. cancel 30D documents of
*       subsequent adjustment with MB_CREATE as this would
*       lead to wrong documents with respect to valuation and
*       URZEI.
        message e378.
      ENDIF.
      IF fuss-parent_id IS INITIAL.
*       Parent
        fuss-urzei = f_zeile.
      ELSE.
*       Child
        READ TABLE fuss INTO ls_parent_fuss
                        WITH KEY line_id = fuss-parent_id.
        IF sy-subrc IS INITIAL.
*         Same URZEI as the parent of this child
          fuss-urzei = ls_parent_fuss-zeile.
        ELSE.
*         Inconsitent document structure
          message e381.
        ENDIF.
      ENDIF.
      fuss-zeile = f_zeile.
    ELSE.
*     Old renumber logic:
      IF NOT fuss-urzei IS INITIAL.
        IF fuss-urzei < fuss-zeile.
          zeile_diff = fuss-zeile - fuss-urzei.
          fuss-urzei = f_zeile + m_zeile - zeile_diff.
        ELSE.
          zeile_diff = fuss-urzei - fuss-zeile.
          fuss-urzei = f_zeile + m_zeile + zeile_diff.
        ENDIF.
      ENDIF.
      fuss-zeile = f_zeile + m_zeile.
*** begin of oss note 631750
      IF ( fuss-attyp = attyp-lot   OR  fuss-attyp = attyp-vks OR
           fuss-attyp = attyp-dis ) AND fuss-xauto IS INITIAL  AND
           fuss-xstor = 2.
* keep in mind line number of structured article (head)
        strukt_kopf_zeile = fuss-zeile.
      ELSEIF ( fuss-urzei IS INITIAL OR
               fuss-urzei <> strukt_kopf_zeile )
         AND ( fuss-xauto = S        OR fuss-xauto = U )
         AND   fuss-xstor = 2.
* set urzei for the components of a structured article
        fuss-urzei = strukt_kopf_zeile.
      ENDIF.
*** end of oss note 631750
    ENDIF.
* keep in mind line number of full product
    IF fuss-upvor CA uptyp_lg.
      PERFORM kopfzeile_merken USING FUSS-LFBNR
                                     fuss-ebeln
                                     fuss-ebelp
                                     fuss-zeile
                                     yfuss-zeile.
    ENDIF.
* correlation of quantity with an empty
    IF fuss-uptyp CA c_mekor.
* vsa_lg anfang
* if its a reversal -> take over xauto from original doc.
      IF fuss-xstor NE zwei.
        fuss-xauto = l.
      ENDIF.
* vsa_lg ende
      PERFORM leerg_abw_pruefen(sapfm07m).
      fuss-mekor = x.
* get zeile of full product and assign it to urzei of the empty
      if not fuss-ebeln is initial and
         fuss-urzei is initial.
        perform leerg_ermittle_urzei using fuss-ebeln
                                           fuss-uebpo
                                           fuss-lfbnr
                                  changing fuss-urzei.
      endif.

* Begin Of Note 498680
*      IF fuss-urzei IS INITIAL  AND  yfuss-urzei = sl_kopf-yzeile.
* when doing a reversal via MBST (e.g. to a transfer with 301) urzei
* of the empty might be unpopulated -> fill it in here
*        fuss-urzei = sl_kopf-zeile.
*      ENDIF.
      IF  fuss-urzei IS INITIAL
           OR   ( not fuss-urzei IS INITIAL   AND
                     fuss-xstor  EQ zwei      AND
*                     fuss-ebeln  IS INITIAL
                   ( fuss-ebeln  IS INITIAL OR              "559567
                     ( not fuss-ebeln is initial and        "559567
                       fuss-kzbew = L ) )                   "559567
* because of VL09 after note 549736                         "559567
                   )
          AND  yfuss-urzei EQ sl_kopf-yzeile.
* when doing a reversal via MBST (e.g. to a transfer with 301) urzei
* of the empty might be unpopulated -> fill it in here
        fuss-urzei = sl_kopf-zeile.
      ENDIF.
* End Of Note 498680
    ENDIF.
    APPEND fuss.
  ENDLOOP.
  REFRESH yfuss.

ENDFORM.