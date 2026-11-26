***INCLUDE MV50AF0F_FCODE_UCSH .
*---------------------------------------------------------------------*
*       FORM FCODE_UCSH                                               *
*---------------------------------------------------------------------*
*       Show incompleteness                                           *
*---------------------------------------------------------------------*
FORM FCODE_UCSH USING P_T185F STRUCTURE T185F
                      P_T185 STRUCTURE T185
                      P_T185V STRUCTURE T185V.

  T185 = P_T185.
  T185F = P_T185F.
  T185V = P_T185V.

  DATA: DA_FCODE LIKE T185-FCODE,
     DA_ILIPS LIKE ILIPS OCCURS 0 WITH HEADER LINE.

  PERFORM UC_INITIALIZE(SAPFV50U).     "46A BEY
  PERFORM UC_NEWCALC(SAPFV50U).
  PERFORM UC_CHECK_FCODES(SAPFV50U).                        "46B
  PERFORM XVBUV_DISPLAY(SAPFV50U).

ENDFORM.