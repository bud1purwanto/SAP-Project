*----------------------------------------------------------------------*
*   INCLUDE LMIGOKA1                                                   *
*   Authority checks
*----------------------------------------------------------------------*

* MIGO showed items although the user has no authorization  "n560086

* separate time depending authorization for tax auditor     "n486477

METHOD line_add_authority_check.

  DATA: l_object TYPE xuobject.
  DATA: ls_werks TYPE goitem-werks,
        ls_lgort TYPE goitem-lgort,
        ls_times TYPE i.
  data: ls_bustr type ty_s_goitem-bwart.                    "718771

* in case of lacking authorization this flag will be set to "n560086
* abap_false before leaving the do-loop                     "n560086
  r_ok = abap_true.                                         "n560086
  CLEAR ls_bustr.                                           "718771
  CLEAR ls_times.
  IF is_goitem-umwrk IS INITIAL.
    ls_times = 1.
  ELSE.

  select single bustr into ls_bustr from t156               "718771
    where bwart = is_goitem-bwart.                          "718771
    if sy-subrc eq 0.                                       "718771
     case ls_bustr.                                         "718771
      when '303'.                                           "718771
       ls_times = 1.                                        "718771
      when others.                                          "718771
       ls_times = 2.                                        "718771
      endcase.                                              "718771
    else.                                                   "718771
        ls_times = 2.
    endif.                                                  "718771

  ENDIF.
  CLEAR: ls_werks, ls_lgort.
  ls_werks = is_goitem-werks.
  ls_lgort = is_goitem-lgort.
*   In 2nd Do check also transfer plant and storage location
  DO ls_times TIMES.

* In display mode, we check the authorization objects M_MSEG_WMB,
* M_MSEG_BMB and M_MSEG_LGO.
    IF s_action-display = abap_true.

*     Plant
      IF NOT cl_mmim_auth=>check( i_object = 'M_MSEG_WMB'
                                 i_actvt  = '03'
                                 i_value1 = ls_werks ) IS INITIAL.
        def_msg_add oref_doc_log e 'M7' '120' ls_werks
                                              space space space.
        r_ok = abap_false.  "sorry, no authorization        "n560086
        EXIT.
      ENDIF.

*     separate time depending authorization for tax auditor "n486477
*     check the authority per item                          "n486477
      data : l_f_repid       type  progname.                "n486477
      move  sy-repid         to  l_f_repid.                 "n486477
                                                            "n486477
      CALL FUNCTION 'MB_CHECK_USER_PG_DATE_PLANT'           "n486477
        EXPORTING                                           "n486477
          i_plant              = ls_werks                   "n486477
          i_user               = sy-uname                   "n486477
          i_program            = l_f_repid                  "n486477
          i_budat              = ps_gohead-budat            "n486477
        EXCEPTIONS                                          "n486477
          no_authority_prog    = 1                          "n486477
          no_authority_date    = 2                          "n486477
          OTHERS               = 3.                         "n486477
                                                            "n486477
*     utilize the result                                    "n486477
      CASE   sy-subrc.                                      "n486477
        WHEN  0.                                            "n486477
*       user has the required authorization                 "n486477
        WHEN  1.                                            "n486477
*       You are not authorized to execute program &         "n486477
          def_msg_add oref_doc_log e 'CA_CHECK_DATE' '001'  "n486477
                               l_f_repid space space space. "n486477
          r_ok = abap_false.  "sorry, no authorization       "n560086
          EXIT.                                             "n486477
        WHEN  2.                                            "n486477
*       No authorization for displaying data from this ...  "n486477
          def_msg_add oref_doc_log e 'CA_CHECK_DATE' '002'  "n486477
                               space space space space.     "n486477
          r_ok = abap_false.  "sorry, no authorization       "n560086
          EXIT.                                             "n486477
        WHEN  OTHERS.                                       "n486477
*       parameter error                                     "n486477
          def_msg_add oref_doc_log e sy-msgid sy-msgno      "n486477
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4."n486477
          r_ok = abap_false.  "sorry, no authorization       "n560086
          EXIT.                                             "n486477
      ENDCASE.                                              "n486477

*     Movement type
      IF NOT cl_mmim_auth=>check( i_object = 'M_MSEG_BMB'
                                 i_actvt  = '03'
                                i_value1 = is_goitem-bwart ) IS INITIAL.
        def_msg_add oref_doc_log e 'M7' '121' is_goitem-bwart
                                              space space space.
        r_ok = abap_false.  "sorry, no authorization        "n560086
        EXIT.
      ENDIF.
*     Storage location
      IF NOT cl_mmim_auth=>check( i_object = 'M_MSEG_LGO'
                                 i_actvt  = '03'
                                 i_value1 = ls_werks
                                 i_value2 = ls_lgort
                                i_value3 = is_goitem-bwart ) IS INITIAL.
        def_msg_add oref_doc_log e 'MIGO' '055' ls_werks ls_lgort
                                              is_goitem-bwart space.
        r_ok = abap_false.  "sorry, no authorization        "n560086
        EXIT.
      ENDIF.
    ENDIF.
    IF s_action-display = abap_false.
      CASE s_action-migo_mode.
        WHEN 'GR'.
          l_object = 'M_MSEG_WWE'.
        WHEN 'GO'.
          l_object = 'M_MSEG_WWF'.
        WHEN 'GI'.
          l_object = 'M_MSEG_WWA'.
        WHEN 'GS'.
          l_object = 'M_MSEG_WWE'.
        WHEN 'GT'.
          l_object = 'M_MSEG_WWA'.
      ENDCASE.
      CHECK NOT l_object IS INITIAL.
      IF NOT cl_mmim_auth=>check( i_object = l_object
                                  i_actvt  = '01'
                                  i_value1 = ls_werks )
                                                     IS INITIAL.
        def_msg_add oref_doc_log e 'M7' '120' ls_werks
                                              space space space.
        r_ok = abap_false.  "sorry, no authorization        "n560086
        EXIT.
      ENDIF.
    ENDIF.
*     set transfer plant and storage location
    ls_werks = is_goitem-umwrk.
    ls_lgort = is_goitem-umlgo.
  ENDDO.

ENDMETHOD.