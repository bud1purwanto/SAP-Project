*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TEXT_CONTROL_PUT                                  *
*----------------------------------------------------------------------*
form text_control_put.

  data: da_display.

* refresh frame text
  clear ttxit-tdtext.

* set frame text
  ttxit-tdtext = text-t01.

* Kopf-TVCOM versorgen
  perform vbak_fuellen_tvcom(sapfv45k).

* Anzeigemodus
  da_display = t180-trtyp.
  translate da_display using 'AXH V '.

* Subscreen aufrufen
call function 'SD_WORD_PROCESSING_PUT'
     exporting
          fi_application_data  = tvcom
          FI_DISPLAY_FLAG      = da_display
          fi_group             = tvcom-txtgn
          fi_object            = tvcom-tdobject
          fi_new_text_language = sy-langu
*         FI_APPL_OBJECT_IDENT = ' '
*         FI_APPL_OBJECT_DESCR = ' '
          FI_DEFAULT_FCODE     = 'ENT1'
          fi_subscreen_number  = '2000'
*         FIT_EXCL_FCODE       =
          FIT_XVBPA            = xvbpa[]
     CHANGING
          FCT_XTHEAD           = xthead[]
          FCT_XVBUV            = xvbuv[]
     EXCEPTIONS
         ERROR_OCCURED        = 1
         OTHERS               = 2
          .
if sy-subrc <> 0.
  MESSAGE ID SY-MSGID TYPE chari NUMBER SY-MSGNO
         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
endif.

endform.