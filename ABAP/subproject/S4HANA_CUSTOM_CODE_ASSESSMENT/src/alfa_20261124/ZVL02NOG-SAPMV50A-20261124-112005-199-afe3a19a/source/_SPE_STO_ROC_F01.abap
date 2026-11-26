*&---------------------------------------------------------------------*
*&  Include           /SPE/STO_ROC_F01                                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form /spe/add_filter_criteria
*&---------------------------------------------------------------------*
*       Add additional filter criteria for ROC/BOP in STO scenario
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM /spe/add_filter_criteria
   TABLES   et_sdfields   STRUCTURE atpfield
   USING    vbeln         TYPE vbeln
            posnr         TYPE posnr.



  et_sdfields-delnr = vbeln.
  et_sdfields-delps = posnr.
  et_sdfields-kfdna = 'DLV_INSMK'.
  et_sdfields-value = xlips-insmk.
  APPEND et_sdfields.

  et_sdfields-delnr = vbeln.
  et_sdfields-delps = posnr.
  et_sdfields-kfdna = 'DLV_LFART'.
  et_sdfields-value = xlikp-lfart.
  APPEND et_sdfields.

  IF ( xlips-insmk IS NOT INITIAL )
   	AND ( xlips-insmk <> 'F' ).
    et_sdfields-delnr = vbeln.
    et_sdfields-delps = posnr.
    et_sdfields-kfdna = 'NO_ROC'.
    et_sdfields-value = 'X'.
    APPEND et_sdfields.
  ENDIF.



ENDFORM.                    "/spe/add_filter_criteria