*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_IEHS                                        *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM FCODE_IEHS                                               *
*---------------------------------------------------------------------*
*       Aufruf EH&S Berichtsauskunft                                  *
*---------------------------------------------------------------------*
FORM fcode_iehs USING h185f STRUCTURE t185f
                      h185  STRUCTURE t185
                      h185v STRUCTURE t185v.

  DATA :          lt_matnr LIKE qmatnr OCCURS 2 WITH HEADER LINE,
                  lf_active LIKE charx.
  FIELD-SYMBOLS: <ls_lips>  TYPE vlggt_lipsvb_s,
                 <ls_ilips> TYPE shp_ilips.

* Item detail screen: show only the current material
  IF t185v-bldgr(1) CA 'IPC'.
    lt_matnr-matnr = lips-matnr.
    APPEND lt_matnr.
  ELSE.
*   Try to take over marked items
    LOOP AT ilips ASSIGNING <ls_ilips>
                  WHERE selkz <> space.
      READ TABLE xlips ASSIGNING <ls_lips>
                       INDEX <ls_ilips>-tabix.
      lt_matnr-matnr = <ls_lips>-matnr.
      COLLECT lt_matnr.
    ENDLOOP.
*   If no items are marked take over all items
    READ TABLE lt_matnr INDEX 1 TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      LOOP AT xlips ASSIGNING <ls_lips>
                    WHERE updkz <> 'D'.
        lt_matnr-matnr = <ls_lips>-matnr.
        COLLECT lt_matnr.
      ENDLOOP.
      MESSAGE s770(vl).       "Alle Positionen werden verarbeitet.
    ENDIF.
  ENDIF.
  READ TABLE lt_matnr INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    MESSAGE s771(vl).           "Keine verarbeitbare Position markiert.
    EXIT.
  ENDIF.
* call the report info-system

****** Definitions for substance reporting                  "v_n_530754
  IF gi_badi_instance_ehs002 IS INITIAL.
*   deleted lines "n_536540 and "n_572145 by "n_648769
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name = 'EHS_PS_002'                          "n_545270
        null_instance_accepted = 'X'                        "n_572145
      CHANGING
        instance = gi_badi_instance_ehs002
      EXCEPTIONS
        OTHERS   = 1.
  ENDIF.                                                    "^_n_530754
  IF gi_badi_instance_ehs002 IS INITIAL.                    "v_n_648769
    return.
  ENDIF.                                                    "^_n_648769

  CALL METHOD gi_badi_instance_ehs002->entry_inquiery
    EXPORTING
      i_flg_new_task   = ehs01_true
      i_qmatnr_tab     = lt_matnr[]
    EXCEPTIONS
      illegal_reptype  = 1
      illegal_rvlid    = 2
      illegal_langu    = 3
      no_materials     = 4
      no_reports_found = 5
      internal_error   = 6
      rfc_failed       = 7
      OTHERS           = 8.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 5.
        MESSAGE i002(cb01) WITH ''.
*       Es wurden keine & Berichte gefunden
      WHEN OTHERS.
        MESSAGE w001(cb01) WITH 'C1G1_ENTRY_INQUIERY_APPOBJ'
                              sy-repid
                              sy-subrc
                              ''.
*       interner System-Fehler! (&1 &2 &3 &4)
    ENDCASE.
  ENDIF.

ENDFORM.                    "FCODE_IEHS