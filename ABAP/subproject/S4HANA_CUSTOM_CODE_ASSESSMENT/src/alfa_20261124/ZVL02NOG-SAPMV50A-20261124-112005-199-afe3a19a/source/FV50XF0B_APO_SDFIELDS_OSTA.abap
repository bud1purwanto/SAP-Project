*---------------------------------------------------------------------*
*        FORM CATALOGUE_BUILD_OSTA                                    *
*---------------------------------------------------------------------*
*        Build field catalog for One-time Ship-To party Address       *
*---------------------------------------------------------------------*
FORM APO_SDFIELDS_OSTA TABLES CT_SDFIELDS STRUCTURE ATPFIELD
                       USING  IV_VBELN    LIKE      LIPS-VBELN
                              IV_POSNR    LIKE      LIPS-POSNR.

  DATA:
    LS_ADDR1_SEL    TYPE ADDR1_SEL,
    LS_ADDR1_VAL    TYPE ADDR1_VAL,
    LS_VBPAVB       TYPE VBPAVB,
    LV_TABNAME      TYPE DDOBJNAME.
  FIELD-SYMBOLS:
    <FS_FIELD>      TYPE ANY.
  STATICS:
    ST_X031L        TYPE TABLE OF X031L WITH HEADER LINE.

* Determine ship-to (LS_VBPAVB) if address entered in document manually
  IF XLIKP-UPDKZ NE UPDKZ_DELETE.
    LOOP AT XVBPA INTO LS_VBPAVB WHERE VBELN EQ XLIPS-VBELN
                                 AND   PARVW EQ PARVW_WE
                                 AND   UPDKZ NE UPDKZ_DELETE
                                 AND   ADRDA CA 'BCEF'.
      EXIT.
    ENDLOOP.
  ELSE.
    LOOP AT YVBPA INTO LS_VBPAVB WHERE VBELN EQ XLIPS-VBELN
                                 AND   PARVW EQ PARVW_WE
                                 AND   ADRDA CA 'BCEF'.
      EXIT.
    ENDLOOP.
  ENDIF.
  CHECK SY-SUBRC EQ 0.

* Determine address (LS_ADDR1_VAL)
  LS_ADDR1_SEL-ADDRNUMBER = LS_VBPAVB-ADRNR.
  CALL FUNCTION 'ADDR_GET'
       EXPORTING
            ADDRESS_SELECTION = LS_ADDR1_SEL
       IMPORTING
            ADDRESS_VALUE     = LS_ADDR1_VAL
       EXCEPTIONS
            OTHERS            = 5.
  CHECK SY-SUBRC EQ 0.

* Determine nametab of address (ST_X031L)
  IF ST_X031L[] IS INITIAL.
    LV_TABNAME = 'ADDR1_VAL'.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
         EXPORTING
              TABNAME    = LV_TABNAME
         TABLES
               X031L_TAB = ST_X031L
         EXCEPTIONS
              OTHERS  = 2.
  ENDIF.

* Transfer "level" of ship-to party to field catalog
  CT_SDFIELDS-DELNR = IV_VBELN.
  CT_SDFIELDS-DELPS = IV_POSNR.
  CT_SDFIELDS-KFDNA = 'OSTA_LEVEL'.
  IF IV_VBELN EQ XLIPS-VBELN AND IV_POSNR EQ XLIPS-POSNR.
* - High: Ship-to party on delivery header level is valid for all items
    CT_SDFIELDS-VALUE = CHARH.
  ELSE.
* - Low: Assume (OK!) Ship-to on sales item level deviating from header
    CT_SDFIELDS-VALUE = CHARL.
  ENDIF.
  APPEND CT_SDFIELDS.

* Transfer address fields to field catalog
  LOOP AT ST_X031L FROM 7.
    ASSIGN COMPONENT    ST_X031L-FIELDNAME
           OF STRUCTURE LS_ADDR1_VAL
           TO           <FS_FIELD>.
    CHECK <FS_FIELD> IS NOT INITIAL.
    CT_SDFIELDS-KFDNA+5 = ST_X031L-FIELDNAME.
    CT_SDFIELDS-VALUE   = <FS_FIELD>.
    APPEND CT_SDFIELDS.
  ENDLOOP.

ENDFORM.