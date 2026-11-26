*----------------------------------------------------------------------*
*   INCLUDE LMIGOKM2 Material master                                   *
*----------------------------------------------------------------------*

***********************************************************************
* Read material master directy
* Material is read of storage location level because of bin location
***********************************************************************
METHOD material_read.
  DATA: ls_mbefu TYPE mbefu,
        ls_mcha  TYPE mcha,
        ls_mtcor TYPE mtcor,
        ls_mtcom TYPE mtcom,
        ls_makt  TYPE makt,
        l_objkey TYPE objky.
  CASE i_transfer.
    WHEN abap_false.
      ls_mtcom-kenng = 'MBEFU'.
      ls_mtcom-matnr = cs_goitem-matnr.
*     Access with full key if not cross-system background
*     part with nonexisting plant data (the main line for a
*     6B1 posting has a plant in another system).
      IF cl_mmim_cross_system=>plant_in_own_system(         "sdp462
           cs_goitem-werks ) = abap_true.                   "sdp462
        ls_mtcom-werks = cs_goitem-werks.
        ls_mtcom-lgort = cs_goitem-lgort.
        ls_mtcom-charg = cs_goitem-charg.
      ENDIF.                                                "sdp462
      ls_mtcom-shkzg = cs_goitem-shkzg.                     "1501121
      ls_mtcom-spras = sy-langu.
      CALL FUNCTION 'MATERIAL_READ'
         EXPORTING
            schluessel = ls_mtcom
         IMPORTING
            matdaten   = ls_mbefu
            return     = ls_mtcor
         EXCEPTIONS error_message.
*     In case of material_read raise an error, ls_mbefu data is initial.
*     In that case we'd better keep the former data in goitem (433341)
      IF sy-subrc = 0.
*       Material short text from material master if not given by PO...
*       If material is MPN, but EMATN is empty, use MAKTX instead.
*       The condition with XPOITEM and KZZUG
*       makes the conversion work in all
*       cases where the text can NOT come from the PO because no PO's
*       are involved.
        IF ls_mtcor-rmakt = abap_false AND
           (
             ( cs_goitem-maktx = space             )   OR
             ( cs_goitem-xpoitem = abap_false AND
               cs_goitem-kzzug   = abap_false      )   OR
             ( NOT cs_goitem-mprof IS INITIAL AND
                   cs_goitem-ematn IS INITIAL      )
           ).
          cs_goitem-maktx = ls_mbefu-maktx.
        ENDIF.
*       Please: never write MOVE-CORRESPONDING LS_MBEFU to CS_GOITEM!
*       F. E. GSBER and PRCTR will be destroyed
        IF ls_mtcor-rmarc = abap_false.
          cs_goitem-matkl = ls_mbefu-matkl.
          cs_goitem-meins = ls_mbefu-meins.
ENHANCEMENT-POINT lmigokm2_01 SPOTS es_saplmigo.
          "$$
          cs_goitem-ausme = ls_mbefu-ausme.
          cs_goitem-lgpbe = ls_mbefu-lgpbe.
          cs_goitem-ssqss = ls_mbefu-ssqss.
          cs_goitem-bwtty = ls_mbefu-bwtty.
          cs_goitem-wertu = ls_mbefu-wertu.
          cs_goitem-mengu = ls_mbefu-mengu.
          cs_goitem-wesch = ls_mbefu-wesch.
          cs_goitem-xchpf = ls_mbefu-xchpf.
          cs_goitem-kzbaa = ls_mbefu-kzbaa.
          cs_goitem-kzwsm = ls_mbefu-kzwsm.
          cs_goitem-sernp = ls_mbefu-sernp.
          cs_goitem-eprio = ls_mbefu-eprio.
          cs_goitem-zustd = ls_mbefu-zustd.
          IF cs_goitem-batch_from_refdoc <> space.
            CALL FUNCTION 'VB_BATCH_GET_DETAIL'
              EXPORTING
                matnr         = cs_goitem-matnr
                charg         = cs_goitem-charg
                werks         = cs_goitem-werks
                lock_batch    = s
              IMPORTING
                ymcha         = ls_mcha
              EXCEPTIONS
                lock_on_batch = 4
                OTHERS        = 99.
            IF sy-subrc = 0.
              IF s_action-display = abap_false.
                cs_goitem-zusch = ls_mcha-zusch.
                cs_goitem-zustd = ls_mcha-zustd.
*               cs_goitem-vfdat = ls_mcha-vfdat.
*               cs_goitem-hsdat = ls_mcha-hsdat.
                IF cs_goitem-vfdat IS INITIAL.
                  cs_goitem-vfdat = ls_mcha-vfdat.
                ENDIF.
                IF cs_goitem-hsdat IS INITIAL.
                  cs_goitem-hsdat = ls_mcha-hsdat.
                ENDIF.
                IF cs_goitem-bwtor IS INITIAL.
                  cs_goitem-bwtar = cs_goitem-bwtor = ls_mcha-bwtar.
                ENDIF.
              ENDIF.
              IF cs_goitem-licha IS INITIAL AND
               cs_goitem-vendorbatch_from_refdoc IS INITIAL.
                cs_goitem-licha = ls_mcha-licha.
              ENDIF.
            ELSEIF sy-subrc = 4.
*             Refresh the items. As we read the PO again,      "1227767
*             so the items would be doubled in lock case       "1227767
              IF s_action-receipt = abap_true AND              "1227767
                 s_action-cancel = abap_false.                 "1227767
                REFRESH pt_goitem[].                           "1227767
                CLEAR p_line_id.                               "1227767
                CLEAR s_status-max_zeile.                      "1227767
              ENDIF.                                           "1227767
              MESSAGE ID sy-msgid
                    TYPE sy-msgty
                  NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF.
          ENDIF.
*         Data for expiry date routine / can already be set by PO
          IF NOT ( cs_goitem-xpoitem = abap_true AND
                   cs_goitem-iprkz <> space ).
            cs_goitem-iprkz = ls_mbefu-iprkz.
          ENDIF.
          IF NOT ( cs_goitem-xpoitem = abap_true AND
                   NOT cs_goitem-mhdrz IS INITIAL ).
            cs_goitem-mhdrz = ls_mbefu-mhdrz.
          ENDIF.
          cs_goitem-rdmhd = ls_mbefu-rdmhd.
          cs_goitem-mhdhb = ls_mbefu-mhdhb.
          cs_goitem-prfrq = ls_mbefu-prfrq.
*         check whether documentary batch is active here
          me->doc_batch_get_control_for_item(
                EXPORTING
                  i_goitem            = cs_goitem
                IMPORTING
                  e_docubatch_control = cs_goitem-docubatch_control ).
          me->doc_batch_get_data_for_matdoc(
                EXPORTING
                  i_goitem            = cs_goitem
                IMPORTING
*                                                          "s1302682
                  e_docubatch_control = cs_goitem-docubatch_control
                  e_docubatch_charg   = cs_goitem-docubatch_charg
                  e_mult_entries = cs_goitem-DOCUBATCH_MULT_ENTRIES ).
*                                                          "e1302682
        ENDIF.
      ENDIF.
*     If MPN-Material, always take the short text from this one
*     because EMATN is changeable, so not possible to take short
*     text from PO
        IF cs_goitem-ematn <> space AND                    "860619
           cs_goitem-mprof <> space AND                    "860619
           cs_goitem-ematn <> cs_goitem-matnr.             "860619
        CALL FUNCTION 'MAKT_SINGLE_READ'
          EXPORTING
            matnr      = cs_goitem-ematn
            spras      = sy-langu
          IMPORTING
            wmakt      = ls_makt
          EXCEPTIONS
            wrong_call = 1
            not_found  = 2
            OTHERS     = 3.
        IF sy-subrc <> 0.
          CLEAR cs_goitem-maktx.
        ELSE.
          cs_goitem-maktx = ls_makt-maktx.
        ENDIF.
      ENDIF.
* Retail
      IF ls_mbefu-mlgut = abap_true AND cs_goitem-xvgtype IS INITIAL.
        cs_goitem-xvgtype = p.
      ENDIF.
      CASE ls_mbefu-attyp.
*     Generic article
        WHEN '01'.
          cs_goitem-xgatype = p.
          IF NOT cs_goitem-sobkz IS INITIAL AND cs_goitem-sobkz <> k.
            MESSAGE i054(MIGO) WITH cs_goitem-sobkz.
            CLEAR: cs_goitem-sobkz.
          ENDIF.
          READ TABLE pt_goitem
            WITH KEY parent  = cs_goitem-global_counter
                     xgatype = c
                     TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0 AND s_action-cancel = abap_false.
            CLEAR: cs_goitem-erfmg.
          ENDIF.
        WHEN '02'.
          READ TABLE pt_goitem
            WITH KEY global_counter = cs_goitem-parent
                     xgatype        = p
                     TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            cs_goitem-xgatype = c.
            IF cs_goitem-sobkz <> k.
              CLEAR: cs_goitem-sobkz.
            ENDIF.
          ENDIF.
*     Structured article
        WHEN '10' OR '11' OR '12'.
*         if consignment handling for retail is active do not clear sobkz
          IF cs_goitem-sobkz IS NOT INITIAL AND
             lcl_migo_globals=>retail_consignment_active <> abap_true.
            CLEAR: cs_goitem-sobkz.
          ENDIF.
*          CLEAR cs_goitem-migo_insmk.
*         article already marked as child?
          IF NOT cs_goitem-xsttype = c.
*           This is needed because later we need to differentiate between
*           the various types of a structured article
            cs_goitem-xsttype = ls_mbefu-attyp.
          ENDIF.
        WHEN OTHERS.
          IF NOT cs_goitem-xgatype IS INITIAL.
            CLEAR: cs_goitem-expand.
          ENDIF.
          CLEAR: cs_goitem-xgatype.
      ENDCASE.
    WHEN abap_true.
      ls_mtcom-kenng = 'MBEFU'.
      ls_mtcom-matnr = cs_goitem-ummat.
*     The transfer data of the automatic line for cross-system
*     postings refers to an unknown plant.
      IF cl_mmim_cross_system=>plant_in_own_system(         "sdp462
           cs_goitem-umwrk ) = abap_true.                   "sdp462
        ls_mtcom-werks = cs_goitem-umwrk.
        ls_mtcom-lgort = cs_goitem-umlgo.
        ls_mtcom-charg = cs_goitem-umcha.
      ENDIF.                                                "sdp462
      ls_mtcom-spras = sy-langu.
      ls_mtcom-shkzg = cs_goitem-shkzg.                     "1501121
      CALL FUNCTION 'MATERIAL_READ'
         EXPORTING
            schluessel = ls_mtcom
         IMPORTING
            matdaten   = ls_mbefu
            return     = ls_mtcor
         EXCEPTIONS error_message.
*   In case of material_read raise an error, ls_mbefu data is initial.
*   In that case we'd better keep the former data in goitem.
      IF sy-subrc = 0.
*       Transfer Posting from general material to an generic article,
*       a structured article or tied emties must not be possible.
        IF ( cs_goitem-xgatype IS INITIAL AND ls_mbefu-attyp = '01' )
          OR ( cs_goitem-xsttype IS INITIAL AND ( ls_mbefu-attyp = '10'
          OR ls_mbefu-attyp = '11' OR ls_mbefu-attyp = '12' ) )
          OR ( cs_goitem-xvgtype IS INITIAL AND NOT ls_mbefu-mlgut IS INITIAL ).
          CLEAR: ls_mbefu, cs_goitem-ummat.
          MESSAGE i066(MIGO).
        ENDIF.
        IF ls_mtcor-rmakt = abap_false.
          cs_goitem-ummaktx = ls_mbefu-maktx.
        ENDIF.
        IF ls_mtcor-rmarc = abap_false.
          cs_goitem-umbwtty = ls_mbefu-bwtty.
          cs_goitem-umxchpf = ls_mbefu-xchpf.
        ENDIF.
        cs_goitem-umzst   = ls_mbefu-zustd.
        cs_goitem-umzus   = ls_mbefu-zusch.
        cs_goitem-umxchar = ls_mbefu-xchar.
        cs_goitem-umlgpbe = ls_mbefu-lgpbe.
        cs_goitem-umkzbaa = ls_mbefu-kzbaa.
        cs_goitem-umeprio = ls_mbefu-eprio.
        cs_goitem-ummhdrz = ls_mbefu-mhdrz.
        cs_goitem-umprfrq = ls_mbefu-prfrq.
        cs_goitem-ummatkl = ls_mbefu-matkl.
        cs_goitem-umkzwsm = ls_mbefu-kzwsm.
      ENDIF.
  ENDCASE.
* Check linked documents for the material
  l_objkey = cs_goitem-matnr.
  CALL FUNCTION 'CV141_LINK_EXIST'
    EXPORTING
      ps_drad_objky = l_objkey
      ps_drad_dokob = 'MARA'
    EXCEPTIONS
      no_link       = 1
      link_exist    = 2
      OTHERS        = 3.
  IF sy-subrc = 2. " Success with SY-SUBRC = 2.
    cs_goitem-xlinks = x.
  ELSE.
    CLEAR cs_goitem-xlinks.
  ENDIF.
ENDMETHOD.                    "material_read

***********************************************************************
* Read material master with prefetch
***********************************************************************
METHOD material_prefetch_read.
* First step: read MBEW/MARC------------------------------------------*
  IF NOT it_prefetch02 IS INITIAL.
*   Call with REFRESH because MIGO never changes the rollarea.
*   Any changes in the material master during the lifetime
*   of MIGO would not be seen without buffer refresh.
    CALL FUNCTION 'MATERIAL_PRE_READ_MBEFU'
      EXPORTING
        kzspr  = space      "no material lock in MIGO
        kzrfb  = x          "refresh buffer
        xvper  = space      "no previous period data
        xvvpr  = space
        xvjah  = space
        xvvja  = space
      TABLES
        ipre02 = it_prefetch02.
  ENDIF.
* Second step: read MAKT per array fetch------------------------------*
  IF NOT it_prefetch03 IS INITIAL.
    CALL FUNCTION 'MATERIAL_PRE_READ_MAKT'
      TABLES
        ipre03 = it_prefetch03.
  ENDIF.
ENDMETHOD.                    "material_prefetch_read