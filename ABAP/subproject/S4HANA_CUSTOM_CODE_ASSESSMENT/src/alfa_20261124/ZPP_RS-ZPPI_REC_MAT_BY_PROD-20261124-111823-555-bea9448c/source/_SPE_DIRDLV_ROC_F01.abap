*&---------------------------------------------------------------------*
*&  Include           /SPE/DIRDLV_ROC_F01
*&---------------------------------------------------------------------*
FORM /spe/dirdlv_add_filter_crit
   TABLES   et_sdfields   STRUCTURE atpfield
   USING    if_vbeln      TYPE vbeln
            if_posnr      TYPE posnr.                       "#EC CALLED

  et_sdfields-delnr = if_vbeln.
  et_sdfields-delps = if_posnr.
  et_sdfields-kfdna = 'NO_ROC'.
  et_sdfields-value = 'X'.
  APPEND et_sdfields.

ENDFORM.                    "/spe/dirdlv_add_filter_criteria