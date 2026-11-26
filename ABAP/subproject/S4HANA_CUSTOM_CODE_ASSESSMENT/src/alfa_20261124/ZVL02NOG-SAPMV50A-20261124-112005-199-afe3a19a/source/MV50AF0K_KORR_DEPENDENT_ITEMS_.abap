*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_DEPENDENT_ITEMS_                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  korr_dependent_items_delete
*&      Löschen von noch nicht gelöschte Splitpositionen zu bereits
*&      gelöschten Chargenhauptpositionen in it_items
*&---------------------------------------------------------------------*
FORM KORR_DEPENDENT_ITEMS_DELETE TABLES IT_ITEMS TYPE VLKOR_T_ITEMS
                                 USING  IF_VBELN LIKE LIKP-VBELN.

  DATA: LS_SAVE_LIPS TYPE LIPS.                             "46A
  DATA: ls_save_lipsd like lipsd,
        ls_save_xlips like lipsvb,
        ls_save_ilips like ilips,
        ls_save_slips like slips.

  READ TABLE IT_ITEMS INDEX 1 TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    LS_SAVE_LIPS = LIPS.                                    "46A
    ls_save_lipsd = lipsd.
    ls_save_xlips = xlips.
    ls_save_ilips = ilips.
    ls_save_slips = slips.

    LOOP AT XLIPS WHERE UPDKZ <> UPDKZ_DELETE
                  AND   VBELN =  IF_VBELN
                  AND   UECHA IN IT_ITEMS.
      LIPS = XLIPS.                                         "46A
      PERFORM XLIPS_LOESCHEN(SAPFV50P) USING CHARX SY-TABIX.

      MOVE-CORRESPONDING LIKP TO XLIKP.
      IF V50AGL-SAMMELGANG = CHARX.
        MODIFY XLIKP.
      ENDIF.
    ENDLOOP.
    CLEAR   IT_ITEMS.
    REFRESH IT_ITEMS.
    LIPS = LS_SAVE_LIPS.                                    "46A
    lipsd = ls_save_lipsd.
    xlips = ls_save_xlips.
    ilips = ls_save_ilips.
    slips = ls_save_slips.
  ENDIF.
ENDFORM.