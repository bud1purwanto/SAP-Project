*----------------------------------------------------------------------*
*   INCLUDE MV50AF0S_SET_GLOBAL_DATA                                   *
*----------------------------------------------------------------------*
FORM set_global_data_mhpar_glomd  USING if_glomd TYPE t160mvl_glomd.

  gs_mhpar-glomd = if_glomd.

ENDFORM.