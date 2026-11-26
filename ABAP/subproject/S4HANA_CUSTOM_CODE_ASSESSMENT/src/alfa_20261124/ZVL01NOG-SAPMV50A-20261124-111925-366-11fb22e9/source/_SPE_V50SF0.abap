*----------------------------------------------------------------------*
***INCLUDE /SPE/V50SF0 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ship_data_to_atpfield
*&---------------------------------------------------------------------*
FORM spe_ship_data_to_atpfield
   TABLES   et_sdfields   STRUCTURE atpfield
   USING    vbeln         TYPE vbeln
            posnr         TYPE posnr.

  CHECK v50agl-bop_guid IS NOT INITIAL.

* bop_guid
  et_sdfields-delnr = vbeln.
  et_sdfields-delps = posnr.

  et_sdfields-kfdna = 'BOP_TRGUID'.
  et_sdfields-value = v50agl-bop_guid.
  APPEND et_sdfields.

* WM FROM QTY
  et_sdfields-delnr = vbeln.
  et_sdfields-delps = posnr.

  et_sdfields-kfdna = 'WM_FROM_QTY'.
  et_sdfields-value = xlips-spe_dlv_qty_from.
  APPEND et_sdfields.

* ROC
* Structure (Kit, e.g.) should not be part of a ODL (for ROC, e.g.)
* due to partial roc -> do not allow roc for delivery groups, full del.
  IF   NOT xlips-spe_struc IS INITIAL
    OR NOT xlips-grkor     IS INITIAL
    OR NOT xlikp-autlf     IS INITIAL.
    et_sdfields-kfdna = 'NO_ROC'.
    et_sdfields-value = charx.
    APPEND et_sdfields.
  ENDIF.


ENDFORM.                    " ship_data_to_atpfield