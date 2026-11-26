*---------------------------------------------------------------------*
*       FORM FCODE_VERP                                               *
*---------------------------------------------------------------------*
*       Aufruf Verpacken                                              *
*---------------------------------------------------------------------*
FORM FCODE_VERP.
  DATA: DA_SICHERN_ODER_ABBRUCH LIKE SY-UCOMM.
  DATA: PACKDATEN_VERBUCHEN type xfeld, LS_VBUK LIKE VBUKVB.
  DATA: lt_xvbap like xvbap occurs 0.

  loop at XVBAP.                                         "1158685/1383509
    read table xvbfa with key VBELV = xvbap-vbeln POSNV = xvbap-posnr
                              VBTYP_N = 'X'.
    if sy-subrc = 0.
      append xvbap to lt_xvbap.
    else.
      if XVBAP-abgru is initial.
        append xvbap to lt_xvbap.
      endif.
    endif.
  endloop.

  CALL FUNCTION 'HU_PACKING_SALES_PROPOSAL'
       EXPORTING
            IF_ANZEIGEMODUS         = T180-TRTYP
            IF_DUNKEL               = SPACE
            if_profile              = '0012'
            IS_VBAK                  = VBAK
*           IT_XVBAP                 = XVBAP[]
            IT_XVBAP                 = lt_XVBAP[]              "1158685
            IT_XVBPA                 = XVBPA[]
            IT_XVBKD                 = XVBKD[]                 "NC907679
       IMPORTING
            EF_DATA_CHANGED          = PACKDATEN_VERBUCHEN
            EF_FCODE                 = DA_SICHERN_ODER_ABBRUCH
       CHANGING
            CT_XVBFA                 = XVBFA[]
            CT_YVBFA                 = YVBFA[]
            CT_XVBAPF                = XVBAPF[].
  IF PACKDATEN_VERBUCHEN EQ CHARX.
    R185D-DATALOSS = CHARX.
*  PERFORM PACKFLUSS_UEBERNEHMEN.
  ENDIF.

  IF DA_SICHERN_ODER_ABBRUCH(4) = 'SICH'.
    FCODE = 'SICH'.
  ELSE.
    FCODE = 'ENT1'.
  ENDIF.

  PERFORM FCODE_BEARBEITEN.
ENDFORM.