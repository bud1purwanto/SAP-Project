*eject
*---------------------------------------------------------------------*
*       MODULE LIEFERFZ_KORRIGIEREN                                   *
*---------------------------------------------------------------------*
*       Ein manuell gesetztes Lieferdatum wird geprüft                *
*---------------------------------------------------------------------*
MODULE LIEFERFZ_KORRIGIEREN.

  DATA: DA_KORMNL LIKE VBAPD-KORMNG,
        DA_ABEFZ(20) TYPE C,
        DA_LIFFZ LIKE RV45Z-LIFFZ,
        DA_GJAHR LIKE BKPF-GJAHR,
        DA_KORDT LIKE SY-DATUM.

  DATA: PROGRAM LIKE SY-REPID VALUE 'SAPFV45L',
        TEXT_TAB LIKE TEXTPOOL OCCURS 0 WITH HEADER LINE.

  DA_LIFFZ = RV45Z-LIFFZ.
  IF NOT *VBAPD-KORMNG IS INITIAL.
    IF NOT KUWEV-PERIV IS INITIAL.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
           EXPORTING
                I_BUDAT = *VBAPD-KORDT
                I_PERIV = KUWEV-PERIV
           IMPORTING
                E_GJAHR = DA_GJAHR
           EXCEPTIONS
                OTHERS  = 01.
    ENDIF.
    IF SY-SUBRC > 0 OR KUWEV-PERIV IS INITIAL.
      DA_GJAHR = *VBAPD-KORDT(4).
    ENDIF.
    IF DA_GJAHR >= VBLB-VJKUN.
      DA_LIFFZ = DA_LIFFZ - *VBAPD-KORMNG.
    ENDIF.
  ENDIF.
  IF NOT VBAPD-KORMNG IS INITIAL.
    IF VBAPD-KORDT IS INITIAL.
      DA_KORDT = SY-DATLO.
    ELSE.
      DA_KORDT = VBAPD-KORDT.
    ENDIF.
    IF NOT KUWEV-PERIV IS INITIAL.
      CALL FUNCTION 'FI_PERIOD_DETERMINE'
           EXPORTING
                I_BUDAT = DA_KORDT
                I_PERIV = KUWEV-PERIV
           IMPORTING
                E_GJAHR = DA_GJAHR
           EXCEPTIONS
                OTHERS  = 01.
    ENDIF.
    IF SY-SUBRC > 0 OR KUWEV-PERIV IS INITIAL.
      DA_GJAHR = VBAPD-KORDT(4).
    ENDIF.
    IF DA_GJAHR >= VBLB-VJKUN.
      DA_LIFFZ = DA_LIFFZ + VBAPD-KORMNG.
    ENDIF.
  ENDIF.
  IF DA_LIFFZ < VBLB-ABEFZ.
    READ TEXTPOOL PROGRAM INTO TEXT_TAB LANGUAGE SY-LANGU.
    WRITE VBLB-ABEFZ TO DA_ABEFZ UNIT VBAP-VRKME LEFT-JUSTIFIED.
    IF VBLB-ABART EQ ABART_LAB.
      READ TABLE TEXT_TAB WITH KEY KEY = '007'.
    ELSEIF VBLB-ABART EQ ABART_FAB.
      READ TABLE TEXT_TAB WITH KEY KEY = '008'.
    ELSEIF VBLB-ABART EQ ABART_PAB.
      READ TABLE TEXT_TAB WITH KEY KEY = '009'.
    ENDIF.
    MESSAGE E015(V4) WITH VBLB-VBELN
                          VBLB-POSNR
                          TEXT_TAB-ENTRY
                          DA_ABEFZ.
  ENDIF.

  perform correction_delivery_store(saplv45l) using
                                              vbap-posnr
                                              vbapd-kordt
                                              vbapd-kormng
                                              space
                                              vbap-umvkz
                                              vbap-umvkn.

  DA_KORMNL = - *VBAPD-KORMNG * VBAP-UMVKZ / VBAP-UMVKN.

  CALL FUNCTION 'SD_DELIVERY_CUMULATIVE_CHANGE'
       EXPORTING
            I_VBELN  = VBAK-VBELN
            I_POSNR  = VBAP-POSNR
            I_KORMNL = DA_KORMNL
            I_KORDT  = *VBAPD-KORDT
            I_KUWEV  = KUWEV.

  DA_KORMNL = VBAPD-KORMNG * VBAP-UMVKZ / VBAP-UMVKN.

  CALL FUNCTION 'SD_DELIVERY_CUMULATIVE_CHANGE'
       EXPORTING
            I_VBELN  = VBAK-VBELN
            I_POSNR  = VBAP-POSNR
            I_KORMNL = DA_KORMNL
            I_KORDT  = VBAPD-KORDT
            I_KUWEV  = KUWEV.

  VBAP_ENDE_BEARBEITUNG = CHARX.
  VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  PERFORM XVBFA_PFLEGEN_DUMMY(SAPFV45C).
  CALL FUNCTION 'RV_XVBAPF_CREATE'
       EXPORTING
            VBELN        = VBAK-VBELN
            I_VBAK       = VBAK
       TABLES
            FXVBAPF      = XVBAPF
            FXVBFA       = XVBFA.
  VBAP_ENDE_BEARBEITUNG = CHARX.

ENDMODULE.