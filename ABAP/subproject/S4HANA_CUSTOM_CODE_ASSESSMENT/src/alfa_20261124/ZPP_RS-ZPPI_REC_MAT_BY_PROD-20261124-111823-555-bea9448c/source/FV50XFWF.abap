***INCLUDE FV50XFWF .
*&---------------------------------------------------------------------*
*&      Form  WF_OBJECT_PUBLISH
*&---------------------------------------------------------------------*
*      -->IF_VBTYP
*      -->IF_VBELN
*----------------------------------------------------------------------*
form wf_object_publish using value(if_vbtyp)
                             value(if_vbeln)
                             value(if_lfart).

data: lv_objtype      like nast-objtype.

  call function 'SD_OBJECT_TYPE_DETERMINE'
       exporting
            i_document_type   = if_vbtyp
       importing
            e_business_object = lv_objtype
       exceptions
            others            = 0.

  call function 'SWU_OBJECT_PUBLISH'
       exporting
            objtype           = lv_objtype
            objkey            = if_vbeln
       exceptions
            objtype_not_found = 1
            others            = 2.

endform.                    " WF_OBJECT_PUBLISH

*&---------------------------------------------------------------------*
*&      Form  WF_OBJECT_RESTORE (n_533596)
*&---------------------------------------------------------------------*
*      -->IF_VBTYP
*      -->IF_VBELN
*----------------------------------------------------------------------*
form wf_object_restore using value(if_vbtyp) like likp-vbtyp
                             value(if_vbeln) like likp-vbeln
                             value(if_lfart) like likp-lfart.

  data: lf_objtype like nast-objtype.

  call function 'SD_OBJECT_TYPE_DETERMINE'
       exporting
            i_document_type   = if_vbtyp
       importing
            e_business_object = lf_objtype
       exceptions
            others            = 0.

  call function 'SWU_OBJECT_RESTORE'
       exporting
            objtype           = lf_objtype
            objkey            = if_vbeln.

endform.                    " WF_OBJECT_PUBLISH