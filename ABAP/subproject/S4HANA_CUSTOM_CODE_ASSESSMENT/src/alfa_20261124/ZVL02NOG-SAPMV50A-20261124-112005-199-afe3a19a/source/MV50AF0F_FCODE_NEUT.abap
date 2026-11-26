*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_NEUT                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       FORM FCODE_NEUT                                                *
*----------------------------------------------------------------------*
*       This form routine performs the rescheduling in dialog mode.
*----------------------------------------------------------------------*
FORM fcode_neut.

  DATA: lf_subrc LIKE sy-subrc,
        ls_save_vbeln LIKE lips-vbeln,
        ls_save_posnr LIKE lips-posnr,
        ls_save_ilips LIKE ilips,
        ls_save_slips LIKE slips.

  ls_save_vbeln = lips-vbeln.
  ls_save_posnr = lips-posnr.
  ls_save_ilips = ilips.
  ls_save_slips = slips.

  PERFORM likp_bearbeiten_vorbereiten(sapfv50k).

  IF tvlk-neute NE space.
    PERFORM likp_termine_bestimmen_neu(sapfv50k)
                       USING charx
                             charx     "I_VERSANDTERMINE
                             likp      "LIKP Input
                             likp      "LIKP Output
                             xlikp-vstrm
                             xlikp-trtrm
                             lf_subrc. "Returncode
  ELSE.
    IF tvlk-aufer = charx.
      PERFORM likp_termine_bestimmen_2(sapfv50c)
               USING likp
                     likp
                     lf_subrc.
      PERFORM likp_fakturadatum_berechnen(sapfv50k) USING likp
                                                          likp.
    ENDIF.
  ENDIF.

  PERFORM likp_bearbeiten(sapfv50k).

* Restore current work areas
  LOOP AT xlips WHERE vbeln EQ ls_save_vbeln
                  AND posnr EQ ls_save_posnr
                  AND updkz NE updkz_delete.
    EXIT.
  ENDLOOP.

  MOVE-CORRESPONDING xlips TO lips.
  MOVE-CORRESPONDING xlips TO lipsd.

  ilips = ls_save_ilips.
  slips = ls_save_slips.

* Restore global workareas for dialog navigation
  IF NOT gs_lips_main IS INITIAL.
    LOOP AT xlips INTO gs_xlips_main
                  WHERE vbeln EQ gs_lips_main-vbeln
                    AND posnr EQ gs_lips_main-posnr
                    AND updkz NE updkz_delete.
      EXIT.
    ENDLOOP.
    MOVE-CORRESPONDING gs_xlips_main TO gs_lips_main.
  ENDIF.
  IF NOT gs_lips_chsp IS INITIAL.
    LOOP AT xlips INTO gs_xlips_chsp
                  WHERE vbeln EQ gs_lips_chsp-vbeln
                    AND posnr EQ gs_lips_chsp-posnr
                    AND updkz NE updkz_delete.
      EXIT.
    ENDLOOP.
    MOVE-CORRESPONDING gs_xlips_chsp TO gs_lips_chsp.
  ENDIF.

  refresh likp_dat.                                            "n_787829

ENDFORM.