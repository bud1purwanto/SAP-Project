*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_ABEL                                        *
*----------------------------------------------------------------------*
*   Read current order number for the initial screen of VL01
*   (for example if orders are processed in a different session)
*----------------------------------------------------------------------*
FORM FCODE_ABEL.

  GET PARAMETER ID 'AUF' FIELD LV50C-VBELN.

ENDFORM.