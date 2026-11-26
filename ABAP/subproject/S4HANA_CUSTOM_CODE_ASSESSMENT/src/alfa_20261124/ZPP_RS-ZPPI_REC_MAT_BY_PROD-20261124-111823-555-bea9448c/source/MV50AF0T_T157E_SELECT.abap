*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_T157E_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM T157E_SELECT                                             *
*---------------------------------------------------------------------*
*       Reason for movement (text table only)                         *
*---------------------------------------------------------------------*
FORM t157e_select USING   if_bwart LIKE t157e-bwart
                          if_grund LIKE t157e-grund
                 CHANGING cf_subrc LIKE sy-subrc.

  cf_subrc = 0.

  CHECK: if_bwart NE t157e-bwart OR
         if_grund NE t157e-grund.

  IF if_bwart EQ space OR
     if_grund EQ space.
    CLEAR: t157e.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t157e WHERE spras EQ sy-langu
                               AND bwart EQ if_bwart
                               AND grund EQ if_grund.

  IF sy-subrc NE 0.
    cf_subrc = sy-subrc.
    CLEAR t157e.
  ENDIF.

ENDFORM.                    "t157e_select