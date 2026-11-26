*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_LESEN                                       *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BELEG_LESEN                                              *
*---------------------------------------------------------------------*
*       Der Vertriebsbeleg wird gelesen und folgende interne          *
*       Tabellen werden gefüllt:                                      *
*                                VBBK                                 *
*                                LIKP                                 *
*                               XLIPS                                 *
*                               XVBPA                                 *
*---------------------------------------------------------------------*
FORM beleg_lesen.

  PERFORM beleg_lesen_buffered USING likp-vbeln
                                     space                  "n_855047
                                     space
                                     nicht_sperren.
*SPE INB ST
*VL-MM consistencies vendor returns with outbound delivery
  IF /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
    IF xlikp-vbtyp = vbtyp_liav.
*   Because document flow,XLIKP-VBTYP should be stored
*   vbfa_tab_pruefen(MV75FF01) will use this export parameter
      DATA: l_vbtyp TYPE likp-vbtyp.
      l_vbtyp = xlikp-vbtyp.
      EXPORT l_vbtyp TO MEMORY ID 'ANLI-AUSL'.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT BELEG_LESEN_01 SPOTS ES_SAPMV50A.
ENDFORM.                    "beleg_lesen