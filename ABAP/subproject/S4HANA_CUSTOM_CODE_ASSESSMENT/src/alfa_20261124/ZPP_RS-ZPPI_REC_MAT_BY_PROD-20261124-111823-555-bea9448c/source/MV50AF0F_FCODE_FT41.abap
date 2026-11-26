***INCLUDE MV50AF0F_FCODE_FT41 .
*---------------------------------------------------------------------*
*       FORM FCODE_FT41                                               *
*---------------------------------------------------------------------*
*       Beleg sichern und Transportauftrag aufrufen                   *
*---------------------------------------------------------------------*
FORM FCODE_FT41.

  IF R185D-DATALOSS NE SPACE.
    PERFORM synchron.                                         "n_617342
    PERFORM beleg_sichern USING charx.

  ENDIF.

  set parameter id 'LGN' field likp-lgnum.
  if likp-vbtyp eq vbtyp_mmli.
    set parameter id 'VLM' field likp-vbeln.
  else.
    set parameter id 'VL'  field likp-vbeln.
  endif.
ENDFORM.