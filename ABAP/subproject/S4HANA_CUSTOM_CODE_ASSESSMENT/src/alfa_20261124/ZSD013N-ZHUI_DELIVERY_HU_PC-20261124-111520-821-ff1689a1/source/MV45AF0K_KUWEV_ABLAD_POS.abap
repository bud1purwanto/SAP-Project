*&---------------------------------------------------------------------*
*&  Include           MV45AF0K_KUWEV_ABLAD_POS                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  kuwev_ablad_pos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FVBAPKOM_POSNR  text
*----------------------------------------------------------------------*
FORM KUWEV_ABLAD_POS USING    P_FVBAPKOM_POSNR.

STATICS: DA_FIRST_CALL TYPE BOOLEAN VALUE CHARX.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'WE'
                                      P_FVBAPKOM_POSNR
                                      XVBPA_AKTIND.

  IF XVBPA-PARVW EQ 'WE'.
    PERFORM KUWEV_FUELLEN_VBADR.
    IF VTCOMWE-KUNNR NE XVBPA-KUNNR OR
       VTCOMWE-VKORG NE VBAK-VKORG OR
       VTCOMWE-VTWEG NE VBAK-VTWEG OR
       VTCOMWE-ABLAD NE XVBPA-ABLAD OR
       VTCOMWE-SPART NE VBAK-SPART.
*     Warenempfänger gefunden
      CLEAR VTCOMWE.
      VTCOMWE-KUNNR = XVBPA-KUNNR.
      VTCOMWE-VKORG = VBAK-VKORG.
      VTCOMWE-VTWEG = VBAK-VTWEG.
      VTCOMWE-SPART = VBAK-SPART.
      VTCOMWE-ABLAD = XVBPA-ABLAD.
      VTCOMWE-VBOBJ = CHARA.
      VTCOMWE-VBTYP = TVAK-VBTYP.

      IF VTCOMWE-KUNNR CN '0 '.        "wg. Fehlerprotokoll
        CALL FUNCTION 'VIEW_KUWEV'
             EXPORTING
                  COMWA = VTCOMWE
             IMPORTING
                  WEWA  = KUWEV.
*       Abladestelle zurückgekommen ?
        IF NOT KUWEV-ABLAD IS INITIAL AND
           XVBPA-ABLAD IS INITIAL.
          CALL FUNCTION 'SD_PARTNER_UNLOADING_POINT'
               EXPORTING
                    I_MANDT = SY-MANDT
                    I_VBELN = VBAK-VBELN
                    I_POSNR = P_FVBAPKOM_POSNR
                    I_ABLAD = KUWEV-ABLAD
                    I_ANLEG = CHARX
               TABLES
                    T_XVBPA = XVBPA
                    T_YVBPA = YVBPA
                    T_XVBUV = XVBUV
                    T_HVBUV = HVBUV.
        ENDIF.
        PERFORM KUWEV_FUELLEN_VBADR.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR VTCOMWE-NOABLAD.

ENDFORM.                    " kuwev_xvbpa_pos