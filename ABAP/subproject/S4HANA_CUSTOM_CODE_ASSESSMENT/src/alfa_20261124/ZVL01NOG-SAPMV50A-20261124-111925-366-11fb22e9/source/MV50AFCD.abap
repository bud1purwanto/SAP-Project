*----------------------------------------------------------------------*
*   INCLUDE MV50AFCD                                                   *
*----------------------------------------------------------------------*

*-----------------------------------------------------------------------
*   FORM BELEG_CHANGE_DOCUMENTS                                        *
*-----------------------------------------------------------------------
*   Erzeugung von Änderungsbelegen in der Lieferung.
*   Änderungsbelege werden für alle Datenelemente der Tabellen LIKP,
*   LIPS, VBUK und VBPA erstellt, bei denen das Änderungsbelegkenn-
*   zeichen gesetzt ist. Anzeigereport: WSCDSHOW
*   Der Aufruf sollte nur im Änderungsmodus erfolgen (t180-trtyp = V)
*-----------------------------------------------------------------------
FORM beleg_change_documents.

* ----- Variablen
  DATA: lf_aenderungsobjekt LIKE cdhdr-objectid,
        lf_upd_lips LIKE cdpos-chngind,
        lf_upd_likp LIKE cdpos-chngind,
        lf_upd_vbpa LIKE cdpos-chngind,
        lf_upd_vbuk LIKE cdpos-chngind,
        lf_upd_icdtxt_lieferung LIKE cdpos-chngind.
* ----- Strukturen
  DATA: ls_xlikp LIKE xlikp,
        ls_ylikp LIKE ylikp,
        ls_xvbuk LIKE xvbuk,
        ls_yvbuk LIKE yvbuk,
        ls_lipsvb_wa LIKE lipsvb,
        ls_vbpavb_wa LIKE vbpavb,
        ls_new_likp LIKE likp,
        ls_old_likp LIKE likp,
        ls_new_vbuk LIKE vbuk,
        ls_old_vbuk LIKE vbuk,
        ls_ulips_wa LIKE ulips,
        ls_uvbpa_wa LIKE uvbpa.
* ----- Interne Tabellen
  DATA: lt_cd_xlips LIKE ulips OCCURS 0,
        lt_cd_ylips LIKE ulips OCCURS 0,
        lt_cd_xvbpa LIKE uvbpa OCCURS 0,
        lt_cd_yvbpa LIKE uvbpa OCCURS 0,
        lt_icdtxt_lief LIKE cdtxt OCCURS 0.

  DATA: modified LIKE leshpmd-splidl.

  FIELD-SYMBOLS:                                               "n_1148799
    <ls_cd_lips> TYPE ulips.                                   "n_1148799


  CHECK t180-trtyp NE charh AND
        t180-trtyp NE chara.

* ----- Write change documents only for updated deliveries
  LOOP AT xlikp INTO ls_xlikp WHERE updkz EQ updkz_update
                                 OR updkz EQ updkz_delete.

    lf_upd_likp = ls_xlikp-updkz.
    MOVE-CORRESPONDING ls_xlikp TO ls_new_likp.
    CLEAR ls_old_likp.
    READ TABLE ylikp INTO ls_ylikp
                     WITH KEY vbeln = ls_xlikp-vbeln.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING ls_ylikp TO ls_old_likp.
    ELSE.
      MOVE-CORRESPONDING ylikp TO ls_old_likp.
    ENDIF.

*   ----- Copy internal tables for call of CD function module
*   1. Delivery items
    CLEAR ls_lipsvb_wa.
    REFRESH lt_cd_xlips.
    lf_upd_lips = updkz_old.
    LOOP AT xlips INTO ls_lipsvb_wa
                  WHERE vbeln EQ ls_xlikp-vbeln.
      IF ls_lipsvb_wa-updkz EQ updkz_delete AND
         lf_upd_lips EQ updkz_old.
        lf_upd_lips = updkz_delete.
      ENDIF.
*     ----- Take over only changed items in copy of XLIPS
      IF ls_lipsvb_wa-updkz NE updkz_old AND
         ls_lipsvb_wa-updkz NE updkz_delete.
        CLEAR ls_ulips_wa.
        MOVE-CORRESPONDING ls_lipsvb_wa TO ls_ulips_wa.
        ls_ulips_wa-kz = ls_lipsvb_wa-updkz.
        APPEND ls_ulips_wa TO lt_cd_xlips.
        lf_upd_lips = updkz_update.
      ENDIF.
    ENDLOOP.
*   lf_upd_lips is equal updkz_delete only if one or more items
*   have been deleted and there have been no changes on item level

    CLEAR ls_lipsvb_wa.
    REFRESH lt_cd_ylips.
    LOOP AT ylips INTO ls_lipsvb_wa
                  WHERE vbeln EQ ls_xlikp-vbeln.
      CLEAR ls_ulips_wa.
      MOVE-CORRESPONDING ls_lipsvb_wa TO ls_ulips_wa.
      ls_ulips_wa-kz = ls_lipsvb_wa-updkz.
      APPEND ls_ulips_wa TO lt_cd_ylips.
    ENDLOOP.

    SORT lt_cd_xlips BY vbeln posnr.
    SORT lt_cd_ylips BY vbeln posnr.

* status change on hold=>real                                "v_n_1148799
    LOOP AT xlips INTO ls_lipsvb_wa
                  WHERE vbeln EQ ls_xlikp-vbeln
                  AND   updkz EQ updkz_new.
      READ TABLE xlips WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                posnr = ls_lipsvb_wa-posnr
                                updkz = updkz_delete.
      CHECK sy-subrc = 0.
      READ TABLE ylips WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                posnr = ls_lipsvb_wa-posnr
                                updkz = updkz_delete.
      CHECK sy-subrc = 0.
      READ TABLE xvbup WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                posnr = ls_lipsvb_wa-posnr
                                updkz = updkz_new.
      CHECK sy-subrc = 0.
      READ TABLE yvbup WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                posnr = ls_lipsvb_wa-posnr
                                updkz = updkz_delete.
      CHECK sy-subrc = 0.
      CHECK xvbup-hdall = ' ' and yvbup-hdall = 'X'.
      READ TABLE lt_cd_xlips ASSIGNING <ls_cd_lips>
                             WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                      posnr = ls_lipsvb_wa-posnr
                             BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_cd_lips>-kz = updkz_new.
        <ls_cd_lips>-kz = updkz_update.
      ENDIF.
      READ TABLE lt_cd_ylips ASSIGNING <ls_cd_lips>
                             WITH KEY vbeln = ls_lipsvb_wa-vbeln
                                      posnr = ls_lipsvb_wa-posnr
                             BINARY SEARCH.
      IF sy-subrc = 0 AND <ls_cd_lips>-kz = updkz_delete.
        <ls_cd_lips>-kz = updkz_old.
      ENDIF.
    ENDLOOP.                                                 "^_n_1148799

*   2. Partners
    CLEAR ls_vbpavb_wa.
    REFRESH lt_cd_xvbpa.
    lf_upd_vbpa = updkz_old.
    LOOP AT xvbpa INTO ls_vbpavb_wa
                  WHERE vbeln EQ ls_xlikp-vbeln.
*     lines deleted                                            "n_715020
*     ----- Take over only changed entries
      IF ls_vbpavb_wa-updkz NE updkz_old AND
         ls_vbpavb_wa-updkz NE updkz_delete.
        CLEAR ls_uvbpa_wa.
        MOVE-CORRESPONDING ls_vbpavb_wa TO ls_uvbpa_wa.
        ls_uvbpa_wa-kz = ls_vbpavb_wa-updkz.
        APPEND ls_uvbpa_wa TO lt_cd_xvbpa.
        lf_upd_vbpa = updkz_update.
      ENDIF.
    ENDLOOP.

    CLEAR ls_vbpavb_wa.
    REFRESH lt_cd_yvbpa.
    LOOP AT yvbpa INTO ls_vbpavb_wa
                  WHERE vbeln EQ ls_xlikp-vbeln.
      CLEAR ls_uvbpa_wa.
      MOVE-CORRESPONDING ls_vbpavb_wa TO ls_uvbpa_wa.
      ls_uvbpa_wa-kz = ls_vbpavb_wa-updkz.
      APPEND ls_uvbpa_wa TO lt_cd_yvbpa.
      IF ls_vbpavb_wa-updkz EQ updkz_delete AND              "v_n_715020
         lf_upd_vbpa EQ updkz_old.
        lf_upd_vbpa = updkz_delete.
      ENDIF.                                                 "^_n_715020
    ENDLOOP.

    SORT lt_cd_xvbpa BY vbeln posnr parvw.
    SORT lt_cd_yvbpa BY vbeln posnr parvw.

*   3. Header status
    CLEAR: lf_upd_vbuk.
    CLEAR: ls_new_vbuk, ls_old_vbuk.
    READ TABLE xvbuk INTO ls_xvbuk
                     WITH KEY vbeln = ls_xlikp-vbeln
                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      lf_upd_vbuk = ls_xvbuk-updkz.                           "HP 357717
      MOVE-CORRESPONDING ls_xvbuk TO ls_new_vbuk.
    ENDIF.
    READ TABLE yvbuk INTO ls_yvbuk
                     WITH KEY vbeln = ls_xlikp-vbeln
                     BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING ls_yvbuk TO ls_old_vbuk.
    ENDIF.

    lf_aenderungsobjekt = ls_xlikp-vbeln.
ENHANCEMENT-POINT BELEG_CHANGE_DOCUMENTS_01 SPOTS ES_SAPMV50A.

*   SPE INB RG 18.11.2004 TMPID
*   No CDHDR lines will be created for the temporary deliveries.
    check xvbuk-spe_tmpid = space.
    CALL FUNCTION 'LIEFERUNG_WRITE_DOCUMENT' IN UPDATE TASK
         EXPORTING
              objectid                = lf_aenderungsobjekt
              tcode                   = sy-tcode
              utime                   = sy-uzeit
              udate                   = sy-datum
              username                = sy-uname
*             PLANNED_CHANGE_NUMBER   = ' '
*             OBJECT_CHANGE_INDICATOR = 'U'
*             PLANNED_OR_REAL_CHANGES = ' '
*             ICDTXT_LIEFERUNG        = ' '
              n_likp                  = ls_new_likp
              o_likp                  = ls_old_likp
              upd_likp                = lf_upd_likp
              upd_lips                = lf_upd_lips
              upd_vbpa                = lf_upd_vbpa
              n_vbuk                  = ls_new_vbuk
              o_vbuk                  = ls_old_vbuk
              upd_vbuk                = lf_upd_vbuk
         TABLES
              icdtxt_lieferung        = lt_icdtxt_lief
              xlips                   = lt_cd_xlips
              ylips                   = lt_cd_ylips
              xvbpa                   = lt_cd_xvbpa
              yvbpa                   = lt_cd_yvbpa
         EXCEPTIONS
              OTHERS                  = 0.

ENHANCEMENT-POINT BELEG_CHANGE_DOCUMENTS_02 SPOTS ES_SAPMV50A.
  ENDLOOP.

ENDFORM.