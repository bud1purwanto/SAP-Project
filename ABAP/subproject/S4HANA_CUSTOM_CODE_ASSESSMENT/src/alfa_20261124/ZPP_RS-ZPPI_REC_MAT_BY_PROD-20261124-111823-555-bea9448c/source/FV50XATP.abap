*----------------------------------------------------------------------*
*   INCLUDE FV50XATP                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LES_ATP_COMMONDATA_GET_1
*&---------------------------------------------------------------------*

FORM les_atp_commondata_get_1
                  TABLES
                         ct_cvbap STRUCTURE vbapvb
                         ct_cvbpa STRUCTURE vbpavb
                  CHANGING
                         cs_cvbak TYPE vbak.

  cs_cvbak = cvbak.

  ct_cvbap = cvbap.
  ct_cvbap[] = cvbap[].

  ct_cvbpa = cvbpa.
  ct_cvbpa[] = cvbpa[].


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  LES_ATP_COMMONDATA_GET_2
*&---------------------------------------------------------------------*

FORM les_atp_commondata_get_2
                  TABLES
                         ct_xvbep STRUCTURE vbepvb.
  ct_xvbep   = xvbep.
  ct_xvbep[] = xvbep[].

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LES_ATP_COMMONDATA_GET_3
*&---------------------------------------------------------------------*

FORM les_atp_commondata_get_3
                  TABLES
                         ct_xvbpa STRUCTURE vbpavb
                  CHANGING
                         cf_posgenerieren          TYPE c
                         cf_kz_chsp_posdetailbild  TYPE c
                         cf_kommirueckmeldung      TYPE c
                         cf_t180_trtyp             LIKE t180-trtyp
                         cf_save_287_menge         LIKE lips-lfimg
                         cf_save_287_menge_flo     LIKE lips-lfimg_flo
                         cf_kclips_lfimg           LIKE lips-lfimg
                         cf_kclips_lgmng           LIKE lips-lgmng
                         cf_kclips_lfimg_old       LIKE lips-lfimg
                         cf_kclips_lgmng_old       LIKE lips-lgmng.


  ct_xvbpa = xvbpa.
  ct_xvbpa[] = xvbpa[].

  cf_posgenerieren         = positionsgenerieren.
  cf_kz_chsp_posdetailbild = kz_chsp_posdetailbild.
  cf_kommirueckmeldung     = v50agl-kommirueckmeldung.
  cf_t180_trtyp            = t180-trtyp.
  cf_save_287_menge        = save_287_menge.
  cf_save_287_menge_flo    = save_287_menge_flo.
  cf_kclips_lfimg          = kclips-lfimg.
  cf_kclips_lgmng          = kclips-lgmng.
  cf_kclips_lfimg_old      = kclips-lfimg_old.
  cf_kclips_lgmng_old      = kclips-lgmng_old.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LES_ATP_COMMONDATA_PUT
*&---------------------------------------------------------------------*

FORM les_atp_commondata_put
                      USING
                         uf_cvbak_vbtyp LIKE vbak-vbtyp.

  cvbak-vbtyp = uf_cvbak_vbtyp.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  LES_ATP_COMMONDATA_PUT_2
*&---------------------------------------------------------------------*

FORM les_atp_commondata_put_2
                  TABLES
                         ut_xvbep STRUCTURE vbepvb.
  xvbep   = ut_xvbep.
  xvbep[] = ut_xvbep[].

ENDFORM.