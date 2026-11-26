*---------------------------------------------------------------------*
*       FORM M-BELEG_ERGAENZEN                                        *
*---------------------------------------------------------------------*
*       Der Materialbeleg wird ergaenzt.                              *
*---------------------------------------------------------------------*
FORM m-beleg_ergaenzen.

  mkpf-tcode2 = tcode.
  mkpf-usnam = sy-uname.
  IF NOT xmbwl IS INITIAL AND NOT usnam IS INITIAL.
    mkpf-usnam = usnam.
  ENDIF.
  mkpf-cpudt = sy-datum.
  mkpf-cputm = sy-uzeit.
  IF mkpf-bldat IS INITIAL.
    mkpf-bldat = mkpf-budat.
  ENDIF.

ENDFORM.