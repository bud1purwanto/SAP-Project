*eject
*---------------------------------------------------------------------*
*       FORM RESERVIERUNG_LESEN                                       *
*---------------------------------------------------------------------*
*       Lesen und ergänzen der Reservierung.                          *
*---------------------------------------------------------------------*
FORM reservierung_lesen.
  DATA: old_rsnum LIKE rm07m-rsnum.
  DATA: l_autyp   like aufk-autyp.                          "note 617725
ENHANCEMENT-POINT RESERVIERUNG_LESEN_01 SPOTS ES_SAPMM07M STATIC.
  IF t158-kzbew IS INITIAL.
    DESCRIBE TABLE seltab1 LINES index_a.
    CLEAR index_k.
    seltab2[] = seltab1[].
    LOOP AT seltab1.
      index_k = index_k + 1.
      IF seltab1-rsnum NE old_rsnum.
        old_rsnum = seltab1-rsnum.
        REFRESH: xrkpf,
                 xrbefu.
        CLEAR: xrkpf,
               xrbefu.
        REFRESH xrkpf.
        rm07m-rsnum = seltab1-rsnum.
        CALL FUNCTION 'MB_READ_RESERVATION_HEADER'
             EXPORTING
                  rsnum         = rm07m-rsnum
                  trtyp         = t158-trtyp
                  xrese         = space
             IMPORTING
                  kopf          = xrkpf
             EXCEPTIONS
                  RES_NOT_FOUND   = 1
                  foreign_lock    = 2
                  enqueue_failure = 3
                  ref_auto_res    = 4
                  change_auto_res = 5 .
        IF SY-SUBRC <> 0.
          case sy-subrc.
            when 1.
              MESSAGE E520 WITH rm07m-rsnum.
            when 2.
              MESSAGE E112 WITH SY-MSGV1 rm07m-rsnum.
            when 3.
              MESSAGE E110.
            when 4.
              MESSAGE E527.
            when 5.
              MESSAGE E522.
            when others.
              MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          endcase.
          continue.
        ENDIF.
*       Bei Fertigungsauftrag, Kopf auf '+' prüfen          note 617725
        if not xrkpf-aufnr is initial.
          select single autyp into l_autyp from aufk
                              where aufnr = xrkpf-aufnr.
          if l_autyp = '10'.
            call function 'CO_SF_HEADER_GOODS_ISSUE'
                 exporting aufnr = xrkpf-aufnr.
          endif.
        endif.                                      "end of note 617725
        IF NOT rm07m-xausw IS INITIAL.
          IF rm07m-solmg IS INITIAL.
            rm07m-solmg = 100000.
          ENDIF.
          IF t063c-ccode_next IS INITIAL.
            ccode = ccode_next.
          ELSE.
            ccode = t063c-ccode_next.
            ccode_next = ccode.
            CLEAR t063c-ccode_next.
          ENDIF.
          IF t156b-bwart NE xrkpf-bwart.
            SELECT SINGLE * FROM t156b WHERE bwart = xrkpf-bwart
                                       AND   sobkz = space.
            IF NOT sy-subrc IS INITIAL.
              MESSAGE e001 WITH 'T156B' xrkpf-bwart.
            ENDIF.
          ENDIF.
          PERFORM erweiterte_auswahl.
          IF abbrechen = x.
            CLEAR abbrechen.
            MESSAGE e015.
          ELSE.
            CLEAR t063c.
          ENDIF.
        ELSE.
          CLEAR rm07m-bdter.
          CLEAR rm07m-istmg.
          CLEAR rm07m-wempf_vor.
          CLEAR rm07m-lifnr.
        ENDIF.
ENHANCEMENT-SECTION     RESERVIERUNG_LESEN_02 SPOTS ES_SAPMM07M.
        mseg-bwart = xrkpf-bwart.
END-ENHANCEMENT-SECTION.
        CLEAR t156n.
        IF NOT fcausw-xnbwa IS INITIAL.
          SELECT SINGLE * FROM t156n WHERE fcode = fcausw-fcode
                                      AND  bwart = mseg-bwart.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH '156N' mseg-bwart.
          ENDIF.
          mseg-bwart = t156n-bwart_next.
        ENDIF.
ENHANCEMENT-POINT RESERVIERUNG_LESEN_03 SPOTS ES_SAPMM07M.
        PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                     mseg-xauto.
        IF NOT rm07m-sobkz IS INITIAL.
          PERFORM bildauswahl_pruefen(sapfm07m) USING mseg-bwart
                                                      rm07m-sobkz.
        ENDIF.
        shkzg = t156-shkzg.
        CLEAR: mseg-bwart,
               rm07m-rspos.
        IF NOT seltab1-xexpl IS INITIAL.
          rm07m-rspos = seltab1-rspos.
        ENDIF.
        IF NOT am07m-kzneb IS INITIAL AND rm07m-kzneb IS INITIAL.
          rm07m-kzneb = am07m-kzneb.
        ENDIF.
        IF NOT sy-binpt IS INITIAL.
* wrong reservation position will be proposed in case of batch   "945429
* processing in reference to aufnr when the reservation includes "945429
* RSART = 1                                                      "945429
         IF rm07m-rsnum <> SPACE and rm07m-aufnr <> SPACE.       "945429
          CALL FUNCTION 'MB_READ_RESERVATION_POS_WA'             "945429
               EXPORTING                                         "945429
                    rsnum    = rm07m-rsnum                       "945429
                    rspos    = rm07m-rspos                       "945429
                    rsart    = rm07m-rsart                       "945429
                    shkzg    = shkzg                             "945429
                    bwart    = xrkpf-bwart                       "945429
                    kzneb    = rm07m-kzneb                       "945429
               TABLES                                            "945429
                    i_iooper = oper_tab                          "945429
                    seqtab   = xrbefu.                           "945429
         ELSE.                                                   "945429
          CALL FUNCTION 'MB_READ_RESERVATION_POS_WA'
               EXPORTING
                    rsnum    = rm07m-rsnum
                    rspos    = rm07m-rspos
                    rsart    = rm07m-rsart
                    shkzg    = shkzg
                    xrsart   = x
                    bwart    = xrkpf-bwart
                    kzneb    = rm07m-kzneb
               TABLES
                    i_iooper = oper_tab
                    seqtab   = xrbefu.
         ENDIF.                                                  "945429
        ELSE.
          CALL FUNCTION 'MB_READ_RESERVATION_POS_WA'
               EXPORTING
                    rsnum    = rm07m-rsnum
                    rspos    = rm07m-rspos
                    shkzg    = shkzg
                    bwart    = xrkpf-bwart
                    kzneb    = rm07m-kzneb
               TABLES
                    i_iooper = oper_tab
                    seqtab   = xrbefu.
        ENDIF.

ENHANCEMENT-POINT EHP605_MM07MFR0_RESERVIERUNG_1 SPOTS ES_SAPMM07M .

        PERFORM res_positionen_uebernehmen.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF xconfirm IS INITIAL.
    IF t158-trtyp = h.
      xconfirm = x.
    ENDIF.
  ENDIF.
  CLEAR: seltab1, index_a, index_k.
  REFRESH seltab1.
ENDFORM.