***INCLUDE MV50AF0F_FCODE_KDLM .
*---------------------------------------------------------------------*
*       FORM FCODE_KDLM                                               *
*---------------------------------------------------------------------*
*       Aufruf der Versandterminpflege                                *
*---------------------------------------------------------------------*
FORM fcode_kdlm USING h185f STRUCTURE t185f
                      h185  STRUCTURE t185
                      h185v STRUCTURE t185v.

  DATA xxdataloss LIKE r185d-dataloss.
  DATA: tp_change(1).
  DATA:
    l_fcode      LIKE sy-ucomm,
    l_leave(1)   TYPE c,
    l_save(1)    TYPE c,
    l_display(1) TYPE c.
  DATA:                                                     "P99K048259
    ls_adrc      LIKE adrc.                                 "P99K048259

* Bildtext aufbauen
  bildtext    = rv50a-txt_vbeln.
  bildtext+21 = likp-vbeln.
* Terminpflege aufrufen
  t185f = h185f.
  t185  = h185.
  t185v = h185v.
  IF h185f-trtyp = 'A'.
    l_display = 'X'.
  ELSE.
    l_display = ' '.
  ENDIF.

* Get GUID if not existing yet
  IF likp-handle IS INITIAL.
    CALL FUNCTION 'GUID_CREATE'
         IMPORTING
              ev_guid_22 = likp-handle.
  ENDIF.
* Determine template
* no template in document but deadlines on database
* ... then use template from deadline header, not default template
  IF LIKP-TSEGTP IS INITIAL AND NOT LIKP-HANDLE IS INITIAL.
    SELECT SINGLE HEAD_TPL FROM TSEGH INTO LIKP-TSEGTP
        WHERE HEAD_HDL = LIKP-HANDLE.
  ENDIF.
  IF LIKP-TSEGTP IS INITIAL.
    PERFORM TVLK_SELECT USING LIKP-LFART SPACE SY-SUBRC.
    LIKP-TSEGTP = TVLK-TSEGTP.
  ENDIF.

* Determine Time Zones of
* ... Shipping Point
  IF likp-tzonis IS INITIAL.
    IF NOT tvst-adrnr IS INITIAL.
      CALL FUNCTION 'SD_TZONE_ADDRESS'
        EXPORTING
          if_addrnumber                 = tvst-adrnr
        IMPORTING
          ef_timezone                   = likp-tzonis
        EXCEPTIONS
          OTHERS                        = 7.
      IF sy-subrc <> 0.
        likp-tzonis = sy-zonlo.
      ENDIF.
    ELSE.
      likp-tzonis = sy-zonlo.
    ENDIF.
  ENDIF.

* ... Ship To
  IF likp-tzonrc IS INITIAL.
    CALL FUNCTION 'SD_TZONE_ADDRESS'
      EXPORTING
        if_customer                   = kuwev-kunnr
      IMPORTING
        ef_timezone                   = likp-tzonrc
      EXCEPTIONS
        OTHERS                        = 7.
    IF sy-subrc <> 0.
      likp-tzonrc = likp-tzonis.
    ENDIF.
  ENDIF.

* Configure
  CALL FUNCTION 'SD_DEADLINES_CONFIGURE'
       EXPORTING
            i_call_back_program        = 'SAPMV50A'
            i_ext_pai_fcode_process    = 'DELIVERY_PAI_FCODE_PROCESS'
            i_ext_pai_fcode_check      = 'DELIVERY_PAI_FCODE_CHECK'
            i_ext_pbo_status_set       = 'DELIVERY_PBO_SET_PFSTAT'
            i_header_subscreen_program = 'SAPLV51T'
            i_header_subscreen_dynnr   = '0002'
       EXCEPTIONS
            OTHERS                     = 1.
  CALL FUNCTION 'SD_DEADLINE_MAINTAIN_NEW'
       EXPORTING
            i_deadline_no       = likp-ternr
            i_handle            = likp-handle
            i_ddl_exist         = likp-tsegfl
            i_docnum            = likp-vbeln
            i_table_appl        = 'LIKP'
            opt_display         = l_display
       IMPORTING
            e_deadline_no       = likp-ternr
            e_handle            = likp-handle
            e_ddl_exist         = likp-tsegfl
            e_pressed_fcode     = l_fcode
            e_leave_transaction = l_leave
            e_change            = xxdataloss
            e_save              = l_save
       CHANGING
            obj_wa              = likp
       EXCEPTIONS
            invalid_tcode       = 1
            no_deadlines        = 2
            app_anchor_error    = 3
            OTHERS              = 4.
  IF sy-subrc NE 0.
    CASE sy-subrc.
      WHEN 01.                         "INVALID_TCODE
      WHEN 03.                         "APP_ANCHOR_ERROR
      WHEN 02.                         "NO_DEADLINES
        MESSAGE s046.
    ENDCASE.
  ENDIF.
  IF xxdataloss NE space AND r185d-dataloss EQ space.
    r185d-dataloss = xxdataloss.
  ENDIF.
  h185  = t185.
  h185f = t185f.
  h185v = t185v.
  IF l_fcode EQ 'BABA' OR
     l_fcode EQ 'ABBA'.
    h185f-fcode = 'BACK'.
  ELSE.
    h185f-fcode = l_fcode.
  ENDIF.

ENDFORM.