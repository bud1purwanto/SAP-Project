*----------------------------------------------------------------------*
*   INCLUDE LMIGOKP4                                                   *
*----------------------------------------------------------------------*
* pipeline methods                                                     *
************************************************************************

METHOD pipe_supplier_get.

* this method will read the supplier for a pipeline material. This
* supplier should be filled in lifnr and as well in mat_lifnr because
* thte method is called in line_check after the moves.

  DATA: l_pipeline_indicator, l_consignment_indicator.
  DATA: ls_pipe_supp_imp TYPE bqpim,  "import structure for supplier get
        ls_pipe_supp_exp TYPE bqpex.  "export structure for supplier get


*---- Struktur für Pipeline-Orderbuch
  TYPES: ls_ord TYPE eord.

  DATA:  lt_ord TYPE TABLE OF ls_ord.

  CLEAR: ls_pipe_supp_imp, ls_pipe_supp_exp.

  IF cs_goitem-sobkz = p.
     l_pipeline_indicator = x.
  ELSEIF cs_goitem-sobkz = k.
*   For future use: Automatic determination of consignment vendor.
    l_consignment_indicator = x.
  ENDIF.

  CALL FUNCTION 'ME_SELECT_EKORG_FOR_PLANT'
      EXPORTING
             i_werks = cs_goitem-werks
             i_pipel = l_pipeline_indicator
             i_konsi = l_consignment_indicator
      IMPORTING
             e_ekorg = ls_pipe_supp_imp-ekorg
      EXCEPTIONS
             more_than_one_organization = 01
             no_entry_found             = 02
             no_default_found           = 03.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.



  ls_pipe_supp_imp-matnr = cs_goitem-matnr.
  ls_pipe_supp_imp-werks = cs_goitem-werks.
  ls_pipe_supp_imp-flief = cs_goitem-lifnr.
  ls_pipe_supp_imp-lifnr = cs_goitem-lifnr.
  ls_pipe_supp_imp-nedat = is_gohead-budat.
  ls_pipe_supp_imp-bstyp = b.
  ls_pipe_supp_imp-pstyp = p.
  ls_pipe_supp_imp-vorga = b.
  ls_pipe_supp_imp-noqul = x.
  ls_pipe_supp_imp-noquu = x.
  ls_pipe_supp_imp-novrt = x.
  ls_pipe_supp_imp-liste = space.
* no pop_up during process
  ls_pipe_supp_imp-noaus = space. " no popUp with supplier
  ls_pipe_supp_imp-bqpra = 1. " selection of supplier with less price
  ls_pipe_supp_imp-nemng = 1. " price selection with quantity 1.
*
  CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY'
     EXPORTING
        comim        = ls_pipe_supp_imp
     IMPORTING
        comex        = ls_pipe_supp_exp
     TABLES
        uequp        = lt_ord
        uord         = lt_ord.

  IF NOT ls_pipe_supp_exp-flief IS INITIAL.
    MOVE ls_pipe_supp_exp-flief TO cs_goitem-lifnr.
    MOVE ls_pipe_supp_exp-flief TO cs_goitem-mat_lifnr.
  ENDIF.

ENDMETHOD.