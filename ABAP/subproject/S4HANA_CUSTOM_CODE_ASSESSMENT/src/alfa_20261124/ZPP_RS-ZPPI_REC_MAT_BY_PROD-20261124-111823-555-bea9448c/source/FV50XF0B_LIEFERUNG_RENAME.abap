***INCLUDE FV50XF0B_LIEFERUNG_RENAME .
*---------------------------------------------------------------------*
*       FORM LIEFERUNG_RENAME                                         *
*---------------------------------------------------------------------*
*  -->  IF_TEMP_VBELN                                                 *
*---------------------------------------------------------------------*
FORM lieferung_rename USING if_temp_vbeln LIKE likp-vbeln
                            if_flag_docnum_new TYPE c.

  DATA: lf_temp_vbeln LIKE likp-vbeln,
        objky_old    LIKE nast-objky,
        objky_new    LIKE nast-objky.

* Abhängige Tabellen umbenennen
  lf_temp_vbeln = if_temp_vbeln.
  IF lf_temp_vbeln = space   OR
     lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
    PERFORM b_abhaengige_tabellen_updaten USING lf_temp_vbeln.
  ELSE.
    IF t180-trtyp = 'H' AND if_temp_vbeln CN '0 $'.
      PERFORM b_abhaengige_tabellen_updaten USING '          '.
    ENDIF.
  ENDIF.

*SPE ST Renumbering of SPE_VBFS
  IF xlikp-vbtyp = '7' AND xlikp-updkz = 'I'.
    IF v50agl-split IS INITIAL.
      PERFORM /spe/renum_spe_vbfs(saplv50s)
              USING lf_temp_vbeln   xlikp-vbeln.
    ENDIF.
*   ID handling is active and later no distribution will run
    IF v50agl-spe_inb_dlv = 'X' AND
       v50agl-spe_dist_proc_code =
       /spe/cl_id_handling=>c_dist_proc_code-nothing.
*     Fill the tables of the ID Handling from the CORE tables
      PERFORM /spe/fill_id_handling.
    ENDIF.
  ENDIF.

* Texte umbenennen
  IF lf_temp_vbeln = space   OR
     lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
    CALL FUNCTION 'RV_TEXT_RENAME'
      EXPORTING
        fi_tdobject   = 'VBB*'
        fi_tdname_alt = lf_temp_vbeln
        fi_tdname_neu = xlikp-vbeln.
  ENDIF.

* Packdaten umbenennen
  IF xlikp-vbtyp CA vbtyp_mmli OR xlikp-vbtyp CA vbtyp_lire.
    vpobj = '03'.
  ELSE.
    vpobj = '01'.
  ENDIF.
  IF packdaten_verbuchen = 'X'.
    IF t180-trtyp = 'H' OR
      v50agl-mult NE space AND xlikp-updkz EQ updkz_new.
      DATA: lf_number_new LIKE vekp-vpobjkey,
            lf_number_old LIKE vekp-vpobjkey,               "n_v_877401
            ls_packing TYPE vse_s_v51h,
            ls_likp TYPE likpvb.
      IF v50agl-split NE space AND xlikp-vbeln <> lf_temp_vbeln.
        CLEAR packdaten_verbuchen.
        ls_likp = xlikp.
        ls_packing-display = t180-trtyp.
        ls_packing-init = 'X'.
        PERFORM init_complete_packing(sapmv50a) USING    ls_likp
                                                CHANGING ls_packing.
        packdaten_verbuchen = 'X'.
      ENDIF.                                                "n_^_877401
      lf_number_new = xlikp-vbeln.
      lf_number_old = lf_temp_vbeln.
      CALL FUNCTION 'V51P_PACKING_RENAME'
        EXPORTING
          if_object          = vpobj
          if_document_nr_new = lf_number_new
          if_document_nr_old = lf_number_old.
    ENDIF.
  ENDIF.

* Nachrichten umbenennen
  IF lf_temp_vbeln = space   OR
     lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
    objky_old = lf_temp_vbeln.
    objky_new = xlikp-vbeln.
    CALL FUNCTION 'RV_MESSAGES_RENAME'
      EXPORTING
        msg_objky_old = objky_old
        msg_objky_new = objky_new
        msg_leng      = 10.      " wg. Position
  ELSE.
    IF t180-trtyp = 'H' AND lf_temp_vbeln CN '0 $'.
      objky_old = '          '.
      objky_new = xlikp-vbeln.
      CALL FUNCTION 'RV_MESSAGES_RENAME'
        EXPORTING
          msg_objky_old = objky_old
          msg_objky_new = objky_new
          msg_leng      = 10.    " wg. Position
    ENDIF.
  ENDIF.

* Objektliste zu Serialnummern/Gefahrgutdaten umbenennen
  IF lf_temp_vbeln = space   OR
     lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
    LOOP AT xlips TRANSPORTING NO FIELDS                    "v_n_533441
                  WHERE vbeln = xlikp-vbeln
                  AND   anzsn > 0.
      EXIT.
    ENDLOOP.
*   needed just in case of assigned and/or deleted serial numbers
    IF sy-subrc IS INITIAL.
      PERFORM serialnumber_rename USING lf_temp_vbeln xlikp-vbeln.
    ELSE.
      LOOP AT ylips TRANSPORTING NO FIELDS
                    WHERE vbeln = xlikp-vbeln
                    AND   anzsn > 0.
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        PERFORM serialnumber_rename USING lf_temp_vbeln xlikp-vbeln.
      ENDIF.
    ENDIF.                                                  "^_n_533441
    PERFORM gg_lipsdg_rename    USING lf_temp_vbeln xlikp-vbeln.
    CALL FUNCTION 'EHS003_DGMSD_RENAME'
      EXPORTING
        i_oldnum = lf_temp_vbeln
        i_newnum = xlikp-vbeln
        i_vbtyp  = xlikp-vbtyp
      EXCEPTIONS
        others_  = 1.
  ENDIF.

* Rename of SD-monitor-protocol-entries if protocol must be saved
  IF xsdctrlflag-protsave = yes.
    IF lf_temp_vbeln = space   OR
       lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
      CALL FUNCTION 'SD_MONITOR_PROTOCOL_RENAME'
        EXPORTING
          fpappl     = protocolcaller-sdl
          fvbeln_old = lf_temp_vbeln
          fvbeln     = xlikp-vbeln
        EXCEPTIONS
          OTHERS     = 1.
    ELSE.
      IF t180-trtyp = 'H' AND lf_temp_vbeln CN '0 $'.
*       externe Nummernvergabe
        CALL FUNCTION 'SD_MONITOR_PROTOCOL_RENAME'
          EXPORTING
            fpappl     = protocolcaller-sdl
            fvbeln_old = '          '
            fvbeln     = xlikp-vbeln
          EXCEPTIONS
            OTHERS     = 1.
      ENDIF.
    ENDIF.
  ENDIF.

* Rename externe Absicherungsdaten (WKV)
  IF lf_temp_vbeln = space   OR
     lf_temp_vbeln(1) = '$'  OR
     ( v50agl-create_decentral NE space
       AND if_flag_docnum_new NE space ).
    PERFORM kreditdokument_rename(sapfv50k)
      USING lf_temp_vbeln xlikp-vbeln.
  ELSE.
    IF t180-trtyp = 'H' AND lf_temp_vbeln CN '0 $'.
*     externe Nummernvergabe
      PERFORM kreditdokument_rename(sapfv50k)
        USING '          ' xlikp-vbeln.
    ENDIF.
  ENDIF.

* incompleteness log ( late callers ):
  PERFORM ic_rename(sapfv50u) USING lf_temp_vbeln.

* Cumulated flow (for further status calculations)
  PERFORM rename_cumulated_flow TABLES xvbapf               "HP_377787
                                USING  lf_temp_vbeln
                                       xlikp-vbeln.

* documentary batch
  IF gf_docubatch_active EQ 'X' AND
   ( likp-vbtyp EQ vbtyp_lino   OR
     likp-vbtyp EQ vbtyp_liav ).
    CALL FUNCTION 'VBDBDM_KEY_RENAME_LE'
      EXPORTING
        i_vbeln_old = lf_temp_vbeln
        i_vbeln_new = xlikp-vbeln.
  ENDIF.

ENDFORM.                    "lieferung_rename
*---------------------------------------------------------------------*
*       FORM rename_cumulated_flow (HP_377787)                        *
*---------------------------------------------------------------------*
FORM rename_cumulated_flow TABLES ct_xvbapf STRUCTURE vbapf
                           USING  if_old_vbeln LIKE likp-vbeln
                                  if_new_vbeln LIKE likp-vbeln.

  FIELD-SYMBOLS: <ls_xvbapf> LIKE vbapf.

  READ TABLE ct_xvbapf WITH KEY vbeln = if_old_vbeln
                       BINARY SEARCH
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    LOOP AT ct_xvbapf ASSIGNING <ls_xvbapf>
                      FROM sy-tabix.
      IF <ls_xvbapf>-vbeln NE if_old_vbeln.
        EXIT.
      ENDIF.
      <ls_xvbapf>-vbeln = if_new_vbeln.
    ENDLOOP.
    SORT ct_xvbapf ASCENDING BY vbeln posnr.
  ENDIF.

ENDFORM.                    "rename_cumulated_flow

*&---------------------------------------------------------------------*
*&      Form  /spe/fill_id_handling
*&---------------------------------------------------------------------*
*     Fill the tables of the ID Handling from the CORE tables
*----------------------------------------------------------------------*
FORM /spe/fill_id_handling.

  DATA:
    lo_id          TYPE REF TO /spe/cl_id_handling,
    lo_idd         TYPE REF TO /spe/cl_ibdlv_dispatch,

*   Additional Tables
    lt_vekp        TYPE vsep_t_vekp,
    lt_vepo        TYPE vsep_t_vepo,
    lt_sernr       TYPE /spe/tt_rserob,
    lt_texth       TYPE texth_gn_t,
    lt_textl       TYPE textl_gn_t.

  FIELD-SYMBOLS:
    <ls_likp>      LIKE LINE OF xlikp[].

  IF v50agl-split IS INITIAL.
    PERFORM /spe/fill_id_handling_norm.
  ELSE.
    PERFORM /spe/fill_id_handling_split.
  ENDIF.

ENDFORM.                    "/spe/fill_id_handling


*&---------------------------------------------------------------------*
*&      Form  /spe/fill_id_handling_norm
*&---------------------------------------------------------------------*
*     Fill the tables of the ID Handling from the CORE tables
*----------------------------------------------------------------------*
FORM /spe/fill_id_handling_norm.

  DATA:
    lo_id          TYPE REF TO /spe/cl_id_handling,
    lo_idd         TYPE REF TO /spe/cl_ibdlv_dispatch,

*   Additional Tables
    lt_vekp        TYPE vsep_t_vekp,
    lt_vepo        TYPE vsep_t_vepo,
    lt_sernr       TYPE /spe/tt_rserob,
    lt_texth       TYPE texth_gn_t,
    lt_textl       TYPE textl_gn_t.

  FIELD-SYMBOLS:
    <ls_likp>      LIKE LINE OF xlikp[].

* Get the ID handling object from the global action info
  lo_id ?= /spe/cl_inb_action_info=>get_object(
      i_name = /spe/cl_inb_action_info=>c_obj_delivery ).
* check whether the ID Handling reference is valid.
  CHECK NOT lo_id IS INITIAL.
* Get reference for the ID dispatching
  CALL METHOD lo_id->get_id_ref
    IMPORTING
      eo_idd = lo_idd.
* check whether the ID dispatching reference is valid.
  CHECK NOT lo_idd IS INITIAL.

* In the ID handling case the table XT_LIKP should have only one entry.
  READ TABLE xlikp[] ASSIGNING <ls_likp> INDEX 1.
  CHECK sy-subrc = 0.

* ---- Fill additional tables ----
  CALL METHOD lo_idd->fill_add_disp_tab
    EXPORTING
      is_likp  = <ls_likp>
      it_lips  = xlips[]
      it_vbfa  = xvbfa[]
    IMPORTING
      et_vekp  = lt_vekp
      et_vepo  = lt_vepo
      et_sernr = lt_sernr
      et_texth = lt_texth
      et_textl = lt_textl.

* ---- Fill Tables into the delivery object ----
  CALL METHOD lo_id->fill_from_tables
    EXPORTING
      is_likp   = <ls_likp>
      it_lips   = xlips[]
      it_vbuk   = xvbuk[]
      it_vbup   = xvbup[]
      it_vbuv   = xvbuv[]
      it_vbfa   = xvbfa[]
      it_vbpa2  = xvbpa[] "Different table type
      it_vbadr2 = xvbadr[] "Different table type
      it_vekp   = lt_vekp[]
      it_vepo   = lt_vepo[]
      it_sernr  = lt_sernr[]
      it_texth  = lt_texth[]
      it_textl  = lt_textl[]
      it_vbfs   = cvbfs[].

ENDFORM.                    "/spe/fill_id_handling_norm

*&---------------------------------------------------------------------*
*&      Form  /spe/fill_id_handling_split
*&---------------------------------------------------------------------*
*     Fill the tables of the ID Handling from the CORE tables
*----------------------------------------------------------------------*
FORM /spe/fill_id_handling_split.

  DATA:
    lo_id          TYPE REF TO /spe/cl_id_handling,
    lo_idd         TYPE REF TO /spe/cl_ibdlv_dispatch,
*   Original ID
    lo_id_org      TYPE REF TO /spe/cl_id_handling,
    lo_idd_org     TYPE REF TO /spe/cl_ibdlv_dispatch,
*   New ID
    lo_id_new      TYPE REF TO /spe/cl_id_handling,
    lo_idd_new     TYPE REF TO /spe/cl_ibdlv_dispatch,

*   Additional Tables
    lt_vekp        TYPE vsep_t_vekp,
    lt_vepo        TYPE vsep_t_vepo,
    lt_sernr       TYPE /spe/tt_rserob,
    lt_texth       TYPE texth_gn_t,
    lt_textl       TYPE textl_gn_t.

  FIELD-SYMBOLS:
    <ls_likp>      LIKE LINE OF xlikp[].

* Get the ID handling object from the global action info
  lo_id_org ?= /spe/cl_inb_action_info=>get_object(
      i_name = /spe/cl_inb_action_info=>c_obj_split_dlv_org ).
  lo_id_new ?= /spe/cl_inb_action_info=>get_object(
      i_name = /spe/cl_inb_action_info=>c_obj_split_dlv_new ).
* check whether the ID Handling reference is valid.
  CHECK NOT lo_id_org IS INITIAL AND
        NOT lo_id_new IS INITIAL.
* Get reference for the ID dispatching
  CALL METHOD lo_id_org->get_id_ref
    IMPORTING
      eo_idd = lo_idd_org.
  CALL METHOD lo_id_new->get_id_ref
    IMPORTING
      eo_idd = lo_idd_new.
* check whether the ID dispatching reference is valid.
  CHECK NOT lo_idd_org IS INITIAL AND
        NOT lo_idd_new IS INITIAL.

* In the ID handling case the table XT_LIKP should have only one entry.
  LOOP AT xlikp[] ASSIGNING <ls_likp>.
    IF <ls_likp>-vbeln =  lo_id_org->a_vbeln.
*     This is the Original ID
      lo_id  = lo_id_org.
      lo_idd = lo_idd_org.
    ELSEIF <ls_likp>-vbeln =  lo_id_new->a_vbeln.
*     This is the new ID
      lo_id  = lo_id_new.
      lo_idd = lo_idd_new.
    ELSE.
*     Not know ID
      CONTINUE.
    ENDIF.

*   -- Fill additional tables --
    REFRESH: lt_vekp[], lt_vepo[], lt_sernr[],
             lt_texth[], lt_textl[].
    CALL METHOD lo_idd->fill_add_disp_tab
      EXPORTING
        is_likp  = <ls_likp>
        it_lips  = xlips[]
        it_vbfa  = xvbfa[]
      IMPORTING
        et_vekp  = lt_vekp
        et_vepo  = lt_vepo
        et_sernr = lt_sernr
        et_texth = lt_texth
        et_textl = lt_textl.

*   -- Fill Tables into the delivery object --
    CALL METHOD lo_id->fill_from_tables
      EXPORTING
        is_likp   = <ls_likp>
        it_lips   = xlips[]
        it_vbuk   = xvbuk[]
        it_vbup   = xvbup[]
        it_vbuv   = xvbuv[]
        it_vbfa   = xvbfa[]
        it_vbpa2  = xvbpa[] "Different table type
        it_vbadr2 = xvbadr[] "Different table type
        it_vekp   = lt_vekp[]
        it_vepo   = lt_vepo[]
        it_sernr  = lt_sernr[]
        it_texth  = lt_texth[]
        it_textl  = lt_textl[]
        it_vbfs   = cvbfs[].

  ENDLOOP.

ENDFORM.                    "/spe/fill_id_handling_split