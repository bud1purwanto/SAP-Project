*---------------------------------------------------------------------*
*       FORM CONTAINER_REFRESH                                       *
*---------------------------------------------------------------------*
*       In Zusammenhang mit Funktionsbaustein                         *
*       SD_ORDER_CREATE_DIALOG werden bei VA01 etc. Daten aus dem     *
*       Memory initialisiert.                                         *
*---------------------------------------------------------------------*
FORM CONTAINER_REFRESH.

  DATA: LV_IDOC_IN_MEMORY_ID(20) TYPE C VALUE 'CUXC_IDOC',
        LV_INPUT_MODE_ID(20) TYPE C VALUE 'CUXC_INPUT_MODE'.

  CLEAR:    I_VBAKKOM, I_VBAKKOMX.
  REFRESH:  IX_VBAPKOM,
            IX_VBAPKOMX,
            IX_VBPAKOM,
            IX_VBEPKOM,
            IX_VBEPKOMX,
            IX_KONVKOM,
            IX_KONVKOMX,
            IX_KOMFKZM,
            SALES_CFGS_REF,
            SALES_CFGS_INST,
            SALES_CFGS_PART_OF,
            SALES_CFGS_VALUE,
            SALES_CFGS_BLOB,
            partneraddresses.
  EXPORT I_VBAKKOM TO MEMORY ID CONTAINER_SALES_DOC.

* Free Memory for configuration
  FREE MEMORY ID LV_IDOC_IN_MEMORY_ID.
  FREE MEMORY ID LV_INPUT_MODE_ID.

ENDFORM.