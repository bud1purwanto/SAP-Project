*----------------------------------------------------------------------*
*   INCLUDE MV50AF0K_KORR_AUPSTAB_INSERT_L                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KORR_AUPSTAB_INSERT_LFGRP
*&---------------------------------------------------------------------*
*       Auftragspositionen mit Liefergruppe in aupstab sammeln.
*----------------------------------------------------------------------*
FORM korr_aupstab_insert_lfgrp TABLES aupstab TYPE vlkor_aupstab
                                      pvbap   STRUCTURE vbapvb.
  DATA: lv_lfgsa LIKE vbup-lfgsa.
  DATA: ls_vbap  LIKE xvbap.

  CLEAR aupstab.
  LOOP AT pvbap WHERE grkor > 0              AND
                      uepvw NA naturalrabatt AND
                      abgru = space.
    PERFORM korr_check_lieferrelevanz USING pvbap-vbeln pvbap-posnr
                                      CHANGING lv_lfgsa.
    CHECK NOT lv_lfgsa IS INITIAL.
    MOVE-CORRESPONDING pvbap TO aupstab.
    aupstab-lfgsa  = lv_lfgsa.
    aupstab-anzaup = 1.
    APPEND aupstab.
  ENDLOOP.


ENDFORM.                               " KORR_AUPSTAB_INSERT_LFGRP

*----- begin of AIP

*&---------------------------------------------------------------------*
*&      Form  korr_aupstab_insert_lfgrp_aip
*&---------------------------------------------------------------------*
FORM korr_aupstab_insert_lfgrp_aip
     TABLES ct_aupstab TYPE vlkor_aupstab.

  DATA         : ls_aupstab LIKE LINE OF ct_aupstab.

  FIELD-SYMBOLS: <ls_xlips>  TYPE lipsvb
               , <ls_xlips2> TYPE lipsvb
               , <ls_xlips3> TYPE lipsvb
               .

*  if the group delivery check is active, the two parameters ANZLFA and
*  ANZLFG are set to 0 and the del. group check is done later in
*  korr_aupstab_anzlfg_spe.
    ls_aupstab-anzlfa = 0.
    ls_aupstab-anzlfg = 0.

* In case of creation of unchecked deliveries
* (v50agl-create_uclief ='X') only the entries that are not to be
*  deleted, should be used for the process
  IF ( NOT v50agl-create_uclief IS INITIAL
       AND xlikp-spe_le_scenario EQ charc ) "only for SPE, orders in CRM
     OR NOT v50agl-ucdel_to_del_comb IS INITIAL.

*   get delivery groups and kit header, part of the created deliveries
*   kits that are part of a delivery group are checked as delivery group
*   substituted items may
    LOOP AT xlips ASSIGNING <ls_xlips>
                                 WHERE vbeln EQ xlikp-vbeln
                                   AND ( spe_struc GT 0 OR grkor GT 0 )
                                   AND ( ( updkz     NE updkz_delete
                                       AND updkz     NE updkz_mark_del )
                                       OR  (     uepvw     EQ charr
                                             AND lfimg     EQ 0 ) ).
      CLEAR ls_aupstab.

      ls_aupstab-vbeln      = <ls_xlips>-vgbel.
      ls_aupstab-posnr      = <ls_xlips>-vgpos.
      ls_aupstab-grkor      = <ls_xlips>-grkor.
      ls_aupstab-uepvw      = <ls_xlips>-uepvw.
      ls_aupstab-uepos      = <ls_xlips>-uepos.
      ls_aupstab-spe_struc  = <ls_xlips>-spe_struc.
      APPEND ls_aupstab TO ct_aupstab.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " korr_aupstab_insert_lfgrp_aip


*----- end   of AIP