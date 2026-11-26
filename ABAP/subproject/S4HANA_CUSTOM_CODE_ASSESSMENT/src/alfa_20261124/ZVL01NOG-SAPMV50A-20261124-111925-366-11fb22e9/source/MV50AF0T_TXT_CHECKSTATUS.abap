*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TXT_CHECKSTATUS                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TXT_CHECKSTATUS "AIP
*&---------------------------------------------------------------------*
*       Description of the check status of the delivery is determined
*----------------------------------------------------------------------*
form txt_checkstatus using    value(if_bestk) like vbuk-bestk
                              value(if_archived) type c
                     changing cf_description  like rv50a-chst_txt.

  data: lf_icon(4)  type c,
        lf_text(10) type c.

  if if_archived eq space.                                  "n_574894
    if if_bestk eq chara.
      lf_text = 'ungeprüft'(075).
      lf_icon = '@02@'.                  "ICON_INCOMPLETE
    else.
      lf_text = 'geprüft'(076).
      lf_icon = '@01@'.                  "ICON_CHECKED
    endif.
  else.
    lf_text = 'archiviert'(097).
    lf_icon = '@HJ@'.                    "ICON_READ_FILE
  endif.
  concatenate lf_icon lf_text into cf_description
              separated by space.

endform.                               " TXT_CHECKSTATUS