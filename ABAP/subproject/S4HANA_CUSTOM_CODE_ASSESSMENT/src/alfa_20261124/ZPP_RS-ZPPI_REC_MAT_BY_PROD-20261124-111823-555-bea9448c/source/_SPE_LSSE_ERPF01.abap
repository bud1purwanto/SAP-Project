*&---------------------------------------------------------------------*
*&  Include           /SPE/LSSE_ERPF01
*&---------------------------------------------------------------------*

FORM /spe/sse_append_scrap_ind TABLES ET_SDFIELDS STRUCTURE ATPFIELD
                          USING I_VBELN        TYPE VBELN
                                I_POSNR        TYPE POSNR
                                I_SCRAP_IND    TYPE LIPS-SPE_SCRAP_IND.

* This subroutine appends the scrap indicator to the field catalog
* table so that the scrap indicator is sent back to the APO during key
* completion.

CONSTANTS: kz_spe_scrap_ind TYPE atpfield-kfdna VALUE 'SPE_SCRAP_IND'.
  et_sdfields-delnr = i_vbeln.
  et_sdfields-delps = i_posnr.
  et_sdfields-kfdna = kz_spe_scrap_ind.
  et_sdfields-value = I_SCRAP_IND.
  append et_sdfields.
ENDFORM.