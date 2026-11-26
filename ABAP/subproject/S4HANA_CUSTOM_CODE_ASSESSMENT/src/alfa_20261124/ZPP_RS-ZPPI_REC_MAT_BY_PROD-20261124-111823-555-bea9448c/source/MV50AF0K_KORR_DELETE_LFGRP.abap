*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_DELETE_LFGRP                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_DELETE_LFGRP
*&---------------------------------------------------------------------*
*       löscht die Lieferpositionen zur Liefergruppe  p_grkor
*                                   im Vorgängerbeleg p_vgbel
*       und sammelt die Position wenn es eine Charge ist,
*       zum späteren Löschen der Splitpositionen
*----------------------------------------------------------------------*
FORM korr_delete_lfgrp TABLES items TYPE vlkor_items
                       USING p_vgbel LIKE lips-vgbel
                             p_grkor LIKE vbap-grkor.

  DATA: lf_tabix LIKE sy-tabix.

* löschen der Lieferpositionen der Gruppe
  REFRESH ilips.
  likp = xlikp.
  LOOP AT xlips WHERE updkz NE updkz_delete
                AND   vbeln EQ xlikp-vbeln
                AND   vgbel EQ p_vgbel
                AND   grkor EQ p_grkor.
    lf_tabix = sy-tabix.
    PERFORM korr_check_chp_collect TABLES items
                                   USING  xlips.
    lips = xlips.                                           "46A
    PERFORM xlips_loeschen(sapfv50p) USING charx lf_tabix.

    MOVE-CORRESPONDING likp TO xlikp.
    IF v50agl-sammelgang = charx.
      MODIFY xlikp.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " KORR_DELETE_LFGRP