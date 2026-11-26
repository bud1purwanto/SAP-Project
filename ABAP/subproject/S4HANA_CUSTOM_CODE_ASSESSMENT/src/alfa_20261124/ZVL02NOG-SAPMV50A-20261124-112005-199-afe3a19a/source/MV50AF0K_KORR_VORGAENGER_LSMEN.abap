*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_VORGAENGER_LSMEN                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_VORGAENGER_LSMENG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_LIPS_NATRB_VGBEL  text                                  *
*      -->P_LS_LIPS_NATRB_VGPOS  text                                  *
*      <--P_KORRTAB_UEPOS_LSMENG  text                                 *
*----------------------------------------------------------------------*
FORM korr_vorgaenger_lsmeng TABLES gt_vbap STRUCTURE vbapvb
                            USING value(if_vbtyp) LIKE vbak-vbtyp
                                  value(if_vbeln) LIKE vbap-vbeln
                                  value(if_posnr) LIKE vbap-posnr
                            CHANGING    cf_lsmeng LIKE vbap-lsmeng
                                        cf_vrkme  LIKE vbap-vrkme.

  DATA ss_vbap TYPE vabap_vbapvb_s.                         "SP_318476

  IF if_vbtyp CA vbtyp_bestell.
    PERFORM bestellmenge_lesen USING if_vbeln
                                     if_posnr
                               CHANGING cf_lsmeng.
  ELSE.
    IF ss_vbap-vbeln <> if_vbeln OR
       ss_vbap-posnr <> if_posnr.
      READ TABLE gt_vbap INTO ss_vbap
                         WITH KEY vbeln = if_vbeln
                                  posnr = if_posnr
                         TRANSPORTING VBELN POSNR LSMENG
                                      KWMENG VRKME.
      IF sy-subrc <> 0.
        CLEAR:  ss_vbap-vbeln,  ss_vbap-posnr,
                ss_vbap-lsmeng, ss_vbap-vrkme.
      ENDIF.
    ENDIF.
    IF SS_VBAP-KWMENG GT 0.
      CF_LSMENG = SS_VBAP-KWMENG.
      CF_VRKME  = SS_VBAP-VRKME.
    ELSE.
      CF_LSMENG = SS_VBAP-LSMENG.
      CF_VRKME  = SS_VBAP-VRKME.
    ENDIF.
  ENDIF.

ENDFORM.                               " KORR_VORGAENGER_LSMENG