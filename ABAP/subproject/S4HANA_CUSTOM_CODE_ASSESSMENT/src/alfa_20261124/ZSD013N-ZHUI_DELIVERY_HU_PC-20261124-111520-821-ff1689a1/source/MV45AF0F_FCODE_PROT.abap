***INCLUDE MV45AF0F_FCODE_PROT .

form fcode_prot.

  data: l_display_profile type bal_s_prof,
        l_s_fcat type bal_s_fcat,
        l_s_baldisp type baldisp value is initial.

  call function 'BAL_DSP_PROFILE_STANDARD_GET'
       importing
            e_s_display_profile = l_display_profile.

  clear l_display_profile-lev1_fcat.
  clear l_display_profile-lev1_sort.
  clear l_display_profile-lev2_fcat.
  clear l_display_profile-lev2_sort.
  l_display_profile-head_text = 'Fehlergruppen'(013).

  clear l_s_fcat.
  l_s_fcat-ref_table = 'BAL_S_SHOW'.
  l_s_fcat-ref_field = 'T_SUBOBJ'.
  l_s_fcat-col_pos   = 1.
  l_display_profile-tree_ontop = charx.
  l_display_profile-show_all   = charx.
  append l_s_fcat to l_display_profile-lev1_fcat.

  clear l_s_baldisp.
  l_s_baldisp-number = '2'.
  l_s_baldisp-subobject = '2'.

  call function 'APPL_LOG_DISPLAY_INTERN'
       exporting
            column_selection    = l_s_baldisp
            object              = msg_object_sd_sls
            i_s_display_profile = l_display_profile
       exceptions
            others              = 1.
  if sy-subrc <> 0.
    message id sy-msgid type chari number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Nach dem Anzeigen der Meldungen nicht mehr aufs Protokoll hinweisen
  clear hinweis_protokoll_show.

endform.