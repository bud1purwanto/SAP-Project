*----------------------------------------------------------------------*
***INCLUDE MV45A_SEARCH_CUSTOMERF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEARCH_CUSTOMER
*&---------------------------------------------------------------------*
*       in case of new search request starts the search
*----------------------------------------------------------------------*
*  -->  search_term        search term entered by user
*----------------------------------------------------------------------*
FORM search_customer USING search_term TYPE tdd_kunag_search_term
                           search_mode TYPE c.
  IF search_term IS INITIAL AND gv_search_term_old IS NOT INITIAL.
    CLEAR gv_search_term_old.
  ENDIF.
  IF search_mode IS INITIAL AND gv_search_mode_old IS NOT INITIAL.
    CLEAR gv_search_mode_old.
  ENDIF.
  IF search_term IS NOT INITIAL AND ( gv_search_term_old <> search_term OR gv_search_mode_old <> search_mode ).
    gv_search_term_old = search_term.
    gv_search_mode_old = search_mode.
    CALL SCREEN 4750 STARTING AT 5 5.
*    leave_without_check = abap_true.
  ENDIF.
ENDFORM.                    " SEARCH_CUSTOMER