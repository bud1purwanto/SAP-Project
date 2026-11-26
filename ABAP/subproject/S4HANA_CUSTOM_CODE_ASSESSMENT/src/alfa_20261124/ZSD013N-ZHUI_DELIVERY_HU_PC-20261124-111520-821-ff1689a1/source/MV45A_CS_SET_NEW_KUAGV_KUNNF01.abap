*----------------------------------------------------------------------*
***INCLUDE MV45A_CS_SET_NEW_KUAGV_KUNNF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CS_SET_NEW_KUAGV_KUNNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cs_set_new_kuagv_kunnr .

  IF gv_kunnr_from_search IS NOT INITIAL AND gv_kunnr_from_search <> kuagv-kunnr.
    IF gv_set_kunnr EQ 'X'.
      kuagv-kunnr = gv_kunnr_from_search.
      CLEAR gv_set_kunnr.
    ENDIF.
  ENDIF.

ENDFORM.                    " CS_SET_NEW_KUAGV_KUNNR