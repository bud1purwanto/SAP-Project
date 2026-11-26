*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_GET_UEPOS
*----------------------------------------------------------------------*

FORM korr_get_uepos USING if_posnr LIKE lips-posnr
                    CHANGING cf_uepos LIKE lips-uepos.
  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

  READ TABLE xlips ASSIGNING <ls_xlips>
                   WITH KEY  vbeln = xlikp-vbeln              "n_566609
                             posnr = if_posnr.
  IF sy-subrc IS INITIAL.                                  "v_n_1059019
    LOOP AT xlips ASSIGNING <ls_xlips> FROM sy-tabix
                  WHERE vbeln = xlikp-vbeln
                  AND   posnr = if_posnr
                  AND   updkz ne updkz_delete.
      exit.
    ENDLOOP.
  ENDIF.                                                   "^_n_1059019
  CHECK <ls_xlips> IS ASSIGNED.                               "n_1502287
  IF <ls_xlips>-uepos IS INITIAL.
    cf_uepos = <ls_xlips>-posnr.
  ELSE.
    PERFORM korr_get_uepos USING    <ls_xlips>-uepos
                           CHANGING cf_uepos.
  ENDIF.

ENDFORM.