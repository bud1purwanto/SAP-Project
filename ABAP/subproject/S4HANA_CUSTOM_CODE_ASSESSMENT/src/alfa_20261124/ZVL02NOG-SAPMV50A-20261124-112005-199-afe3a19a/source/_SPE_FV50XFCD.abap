*&---------------------------------------------------------------------*
*&  Include           /SPE/FV50XFCD
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SPE_DELETE_CROSS_DOCKING_HUS
*&---------------------------------------------------------------------*
*       For inbound deliveries into Cross-Docking Warehouses all
*       HU data is deleted on the final Goods Receipt
*----------------------------------------------------------------------*
*       --> IF_VPOBJKEY  Handling Unit Object Key
*       <-- EF_TRUE      Boolean value
*----------------------------------------------------------------------*
FORM spe_check_cd_predecessor  USING if_vpobjkey TYPE vekp-vpobjkey
                            CHANGING ef_true     TYPE xfeld.

* Local Data Declarations --------------------------------------------
  DATA: lf_vbeln        TYPE likp-vbeln
       ,lt_docflow      TYPE /spe/cd_docflow_vb_t
       ,lf_cd           TYPE xfeld
       .
* Local Field Symbols ------------------------------------------------
  FIELD-SYMBOLS:
        <fs_likp>            TYPE likpvb
       .

* Only supported for HU's created at Delivery Confirmation from
* decentral Warehouse !
  CLEAR ef_true.
* CHECK V50AGL-CONFIRM_CENTRAL EQ gc_x.

* Predecessor number directly in LIFEX (STO case)
  lf_vbeln = if_vpobjkey.
  LOOP AT xlikp ASSIGNING <fs_likp>.
    IF     <fs_likp>-lifex EQ lf_vbeln.
      ef_true = gc_x.
      EXIT.
    ELSEIF NOT <fs_likp>-spe_cd_process IS INITIAL.
      lf_cd = gc_x.
    ENDIF.
  ENDLOOP.

  CHECK ef_true IS INITIAL.
  CHECK lf_cd   EQ gc_x.

* Predecessor number in CD docflow
  CALL METHOD /spe/cl_cd_docflow=>get_complete
     EXPORTING
       IF_DELIVERY          = lf_vbeln
     IMPORTING
       ET_CD_DOCFLOW        = lt_docflow
     EXCEPTIONS
       NO_CD_PROCESS        = 1
       CD_PROCESS_NOT_FOUND = 2
       others               = 3.

  IF sy-subrc EQ 0.
    LOOP AT xlikp ASSIGNING <fs_likp>.
      READ TABLE lt_docflow WITH KEY delivery = <fs_likp>-vbeln
                            BINARY SEARCH
                            TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        ef_true = gc_x.
        EXIT.
      ELSE.
        READ TABLE lt_docflow WITH KEY
                              CD_PROCESS = <fs_likp>-spe_CD_PROCESS
                              TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          ef_true = gc_x.
          EXIT.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.                    "SPE_DELETE_CROSS_DOCKING_HUS