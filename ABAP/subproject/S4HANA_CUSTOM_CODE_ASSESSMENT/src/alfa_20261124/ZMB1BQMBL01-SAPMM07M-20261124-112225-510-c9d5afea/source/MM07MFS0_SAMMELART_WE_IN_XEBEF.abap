*---------------------------------------------------------------------*
*       FORM SAMMELART_WE_IN_XEBEFU                                   *
*---------------------------------------------------------------------*
*       LT_SAWE enthält WE-Referenzen zu Sammelartikel aus            *
*       zugehörigen Zeilen.                                           *
*       XEBEFU wird in H_XEBEFU kopiert, jedoch werden Sammel-        *
*       artikelzeilen zu jedem WE aus LT_SAWE dupliziert;             *
*       anschließend wird H_XEBEFU in H_XEBEFU übertragen             *
*---------------------------------------------------------------------*
FORM SAMMELART_WE_IN_XEBEFU USING LT_SAWE TYPE T_IT_SAWE.
  DATA: H_XEBEFU LIKE XEBEFU OCCURS 0 WITH HEADER LINE.
  DATA: WA_SAWE TYPE T_SAWE.
*             * ----------------
*             * XEBEFU -> H_XEBEFU
*             * ----------------
  REFRESH: H_XEBEFU.
  CLEAR:   H_XEBEFU.

  LOOP AT XEBEFU.
*             * --- Sammelartikel
*             *      und WE-bezogene Rechnungsprüfung
    IF XEBEFU-ATTYP = ATTYP-SAM
       AND NOT XEBEFU-WEBRE IS INITIAL.

       MOVE-CORRESPONDING XEBEFU TO H_XEBEFU.
*
       LOOP AT LT_SAWE INTO WA_SAWE
            WHERE UEBPO = XEBEFU-EBELP.
          H_XEBEFU-LFBNR = WA_SAWE-LFBNR.
          H_XEBEFU-WESBS = WA_SAWE-WESBS.
          H_XEBEFU-BPWES = WA_SAWE-BPWES.
          H_XEBEFU-WEMNG = WA_SAWE-WEMNG.
          H_XEBEFU-BPWEM = WA_SAWE-BPWEM.
          H_XEBEFU-WEWRT = WA_SAWE-WEWRT.
          H_XEBEFU-WEWWR = WA_SAWE-WEWWR.
          H_XEBEFU-REMNG = WA_SAWE-REMNG.
          H_XEBEFU-BPREM = WA_SAWE-BPREM.
          H_XEBEFU-REWRT = WA_SAWE-REWRT.
          H_XEBEFU-REWWR = WA_SAWE-REWWR.
          H_XEBEFU-AREWR = WA_SAWE-AREWR.
          H_XEBEFU-AREWW = WA_SAWE-AREWW.
          APPEND H_XEBEFU.
       ENDLOOP.
    ELSE.
*             * nicht-Sammelartikel-Zeile können sofort kopiert werden
       MOVE-CORRESPONDING XEBEFU TO H_XEBEFU.
       APPEND H_XEBEFU.
       CLEAR: H_XEBEFU.
    ENDIF.
  ENDLOOP.
*             * ----------------
*             * H_XEBEFU -> XEBEFU  zurückschreiben
*             * ----------------
  REFRESH: XEBEFU.
  LOOP AT H_XEBEFU.
       MOVE-CORRESPONDING H_XEBEFU TO XEBEFU.
       APPEND XEBEFU.
  ENDLOOP.
  FREE: H_XEBEFU.
ENDFORM.