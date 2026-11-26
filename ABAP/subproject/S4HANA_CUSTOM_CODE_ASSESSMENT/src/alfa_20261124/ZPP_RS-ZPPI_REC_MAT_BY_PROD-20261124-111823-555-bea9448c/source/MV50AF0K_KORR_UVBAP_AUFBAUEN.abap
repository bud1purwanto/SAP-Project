*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_UVBAP_AUFBAUEN                               *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM KORR_UVBAP_AUFBAUEN                                       *
*---------------------------------------------------------------------*
*       Aufbauen der Tabelle der übergeordneten Positionen            *
*---------------------------------------------------------------------*
FORM KORR_UVBAP_AUFBAUEN.

  data: ls_save_xlips like line of xlips.                    "v_n_740405

  ls_save_xlips = xlips.                                     "^_n_740405

  REFRESH UVBAP.

* UVBAP aufbauen
  LOOP AT XLIPS WHERE UPDKZ NE UPDKZ_DELETE  AND
                      UECHA IS INITIAL       AND
                      VBELN EQ LIKP-VBELN.
    UVBAP-POSNR = XLIPS-POSNR.

    WHILE XLIPS-UEPOS NE SPACE AND
          XLIPS-UEPOS <> XLIPS-POSNR AND
          XLIPS-UPDKZ NE UPDKZ_DELETE.                        "n_1385640

      UVBAP-UEPOS = XLIPS-UEPOS.

      IF UVBAP-POSNR NE UVBAP-UEPOS.
        APPEND UVBAP.
      ELSE.
        PERFORM MESSAGE_HANDLING(SAPMV50A)
                                USING POSNR_LOW '506' 'E' 'VL'
                                      LIKP-VBELN
                                      XLIPS-POSNR
                                      SPACE SPACE.
      ENDIF.

      PERFORM XLIPS_LESEN_DIREKT_NO_MSG(SAPFV50P) USING    LIKP-VBELN
                                                           XLIPS-UEPOS
                                                  CHANGING SY-TABIX.
    ENDWHILE.

  ENDLOOP.

  xlips = ls_save_xlips.                                       "n_740405

ENDFORM.