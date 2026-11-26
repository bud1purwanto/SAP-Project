*&---------------------------------------------------------------------*
*&  Include           MV50AF0F_FCODE_COMP_T
*&---------------------------------------------------------------------*
FORM fcode_comp_t USING h185f STRUCTURE t185f
                        h185  STRUCTURE t185
                        h185v STRUCTURE t185v.

  " -----------------------------------------------------
  " Handle OK_CODE 'COMP_T' for the 'Comnponents' button
  " -----------------------------------------------------

  DATA:
    lo_comp TYPE REF TO cl_shp_lecomp.

  BREAK-POINT ID le_comp.

  lo_comp = cl_shp_lecomp_control=>get_components( ).
  CHECK lo_comp IS BOUND.

  lo_comp->display( if_vbeln  = lips-vbeln
                    if_posnr  = lips-posnr
                    if_trtyp  = t180-trtyp ).

ENDFORM.                    "FCODE_COMP_T