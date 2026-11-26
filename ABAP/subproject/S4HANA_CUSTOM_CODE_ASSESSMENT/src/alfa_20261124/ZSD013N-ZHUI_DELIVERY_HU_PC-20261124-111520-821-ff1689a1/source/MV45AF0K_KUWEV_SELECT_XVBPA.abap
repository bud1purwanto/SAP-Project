*eject
*---------------------------------------------------------------------*
*       FORM KUWEV_SELECT_XVBPA                                       *
*---------------------------------------------------------------------*
*       Kopf                                                          *
*       Warenempfänger aus Partnertabelle lesen                       *
*       und Abladestelle bereitstellen                                *
*       Wird nur aufgerufen nach Eingabe eines Auftraggebers          *
*       Wichtig ist, daß UPDKZ = UPDKZ_NEW                            *
*---------------------------------------------------------------------*
FORM KUWEV_SELECT_XVBPA.

  STATICS: DA_FIRST_CALL TYPE BOOLEAN VALUE CHARX.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'WE'
                                      POSNR_LOW
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
      IF T180-TRTYP NE CHARH OR
         FIRST_CALL_UNLPOINT IS INITIAL.
        VTCOMWE-NOABLAD = CHARX.
      ELSE.
        DATA: lv_number type i.

        DESCRIBE TABLE xvbfa LINES lv_number.
        CLEAR FIRST_CALL_UNLPOINT.
* If XVBPA-ABLAD is empty at this stage that means
* cancel was pressed.
        if XVBPA-ABLAD is initial AND
           call_bapi is initial   AND
           vbak-vbkla(2) EQ 'CR'  AND
           lv_number = 0.
          VTCOMWE-NOABLAD = CHARX.
        ENDIF.
      ENDIF.
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
                    I_POSNR = POSNR_LOW
                    I_ABLAD = KUWEV-ABLAD
                    I_ANLEG = CHARX
               TABLES
                    T_XVBPA = XVBPA
                    T_YVBPA = YVBPA
                    T_XVBUV = XVBUV
                    T_HVBUV = HVBUV.
        ENDIF.
        PERFORM KUWEV_FUELLEN_VBADR.
ENHANCEMENT-POINT KUWEV_SELECT_XVBPA_10 SPOTS ES_SAPMV45A.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR VTCOMWE-NOABLAD.

ENDFORM.