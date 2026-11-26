*----------------------------------------------------------------------*
* FORM XVBPA_PARTNER_CHECK                                             *
*----------------------------------------------------------------------*
* This routine will be called from MV45AFPA_XVBPA_PRUEFEN              *
*                                                                      *
*----------------------------------------------------------------------*
form xvbpa_partner_check tables t_xvbpa structure xvbpa
                         using  us_pargr
                                us_posnr.
data: ls_sdorgdata like sdorgdata,
      lv_swo_typeid type swo_typeid,
      lv_parvw_4    type parvw_4,
        lv_parnr      type sd_partner_parnr,
        lvf_kkber2 type kkber,
        LVF_KURGV2 LIKE  KURGV,
        lvf_vtext type vtext.



     ls_sdorgdata-vkorg   = vbak-vkorg.
     ls_sdorgdata-vtweg   = vbak-vtweg.
     ls_sdorgdata-spart   = vbak-spart.
     ls_sdorgdata-doctype = vbak-auart.

     loop at t_xvbpa where posnr = us_posnr.

          lv_parvw_4 = t_xvbpa-parvw.

          case t_xvbpa-nrart.
               when 'KU'.   lv_parnr = t_xvbpa-kunnr.
               when 'LI'.   lv_parnr = t_xvbpa-lifnr.
               when 'PE'.   lv_parnr = t_xvbpa-pernr.
               when 'AP'.   lv_parnr = t_xvbpa-parnr.
               when others. lv_parnr = t_xvbpa-kunnr.
          endcase.

          call function 'SD_PCHECK_ACCOUNT_GROUP'
               exporting
                  fic_objecttype = businessobjekt
                  fic_objectkey  = lv_swo_typeid
                  fif_checktype  = chari
                  fif_msgtype    = chare
                  fif_pargr      = us_pargr
                  fif_parvw      = lv_parvw_4
                  fif_nrart      = t_xvbpa-nrart
                  fif_parnr      = lv_parnr
*             fif_rtypr     =
                  fif_posnr      = us_posnr
                  fis_sdorgdata  = ls_sdorgdata
               exceptions
                  check_error          = 1
                  parameter_incomplete = 2
                  no_authority         = 3.

          if sy-subrc ne 0.
             message id     sy-msgid
                     type   sy-msgty
                     number sy-msgno
              with   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
* BAPI case: check if kkber for item payer and header payer are equal
    If lv_parvw_4 EQ 'RG' and not us_posnr is initial and not call_bapi is initial.
* credit control area for item payer
      CALL FUNCTION 'SD_DETERMINE_KKBER'
        EXPORTING
          I_VKORG = ls_sdorgdata-vkorg
          I_VTWEG = ls_sdorgdata-vtweg
          I_SPART = ls_sdorgdata-spart
          I_KUNNR = lv_parnr
        TABLES
          XVBPA   = t_xvbpa
        CHANGING
          I_KKBER = lvf_kkber2
        EXCEPTIONS
          OTHERS  = 1.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      CALL FUNCTION 'SD_CREDIT_MASTER_DATA'
        EXPORTING
          I_KKBER = LVF_KKBER2
          I_KUNRG = lv_parnr
        CHANGING
          E_KURGV = LVF_KURGV2.

      if ( not vbak-kkber is initial or ( not lvf_kkber2 is initial and
           not vbak-knkli is initial ) )
             and ( vbak-kkber ne lvf_kkber2 ).
*   kkber´s aren´t equal, so error
        MESSAGE ID 'VPD' TYPE SY-MSGTY NUMBER '034'
            WITH LVF_VTEXT RAISING CHECK_ERROR.
      endif.
* check, if credit management is active and knkli´s are equal
      IF ( NOT vbak-KNKLI is INITIAL
           OR NOT LVF_KURGV2-KNKLI is INITIAL )
           AND ( vbak-KNKLI NE LVF_KURGV2-KNKLI ).
        MESSAGE ID 'VP' TYPE SY-MSGTY NUMBER '237'
       WITH LVF_VTEXT RAISING CHECK_ERROR.
      endif.

    ENDIF.

  endloop.
endform.                    "xvbpa_partner_check