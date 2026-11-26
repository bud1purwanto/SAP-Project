*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_VL06                                        *
*----------------------------------------------------------------------*
* Aufruf des Lieferungsmonitors
form fcode_vl06.

  set parameter id 'VKO' field likp-vkorg.
  set parameter id 'VST' field likp-vstel.

endform.

*---------------------------------------------------------------------*
*       FORM fcode_vl06i                                              *
*---------------------------------------------------------------------*
form fcode_vl06i.                                           "HP_216936

  leave to transaction 'VL06I'.

endform.