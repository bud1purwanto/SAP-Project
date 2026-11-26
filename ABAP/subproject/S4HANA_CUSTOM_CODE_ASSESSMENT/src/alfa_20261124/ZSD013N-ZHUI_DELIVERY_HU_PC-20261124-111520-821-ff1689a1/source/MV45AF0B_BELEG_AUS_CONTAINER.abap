*&---------------------------------------------------------------------*
*&      Form  BELEG_AUS_CONTAINER                                      *
*&---------------------------------------------------------------------*
* Ein Verkaufsbeleg wird mit Vorschlagsdaten aus einem Container       *
* bearbeitet                                                           *
*----------------------------------------------------------------------*
FORM BELEG_AUS_CONTAINER.

  CHECK: NOT I_VBAKKOM IS INITIAL,
         NOT SY-CALLD IS INITIAL.

  DATA: BEGIN OF DA_RETURN OCCURS 5.
          INCLUDE STRUCTURE BAPIRET2.
  DATA: END OF DA_RETURN.
  DATA: DA_KUNNR LIKE VBAK-KUNNR.
  DATA: DA_AUART LIKE VBAK-AUART.

  IF dialog_processed = charx.
    MOVE vbak-auart TO i_vbakkom-auart.
    MOVE vbak-vkorg TO i_vbakkom-vkorg.
    MOVE vbak-vtweg TO i_vbakkom-vtweg.
    MOVE vbak-spart TO i_vbakkom-spart.
  ENDIF.
  call_bapi = charx.
  CLEAR dialog_processed.
  CLEAR dialog_check.

  CALL FUNCTION 'SD_SALES_DOCU_MAINTAIN'
       EXPORTING
            I_VBAKKOM          = I_VBAKKOM
            I_VBAKKOMX         = I_VBAKKOMX
            SIMULATION         = CHARX
            I_VBAKKOM_REF      = I_VBAKKOM_REF
            I_CALL_BAPI        = CHARX
            i_without_init     = charx
            suppress_availibility_dia = space
            i_posnr            = i_posnr
       tables
            RETURN             = DA_RETURN
            IX_VBAPKOM         = IX_VBAPKOM
            IX_VBAPKOMX        = IX_VBAPKOMX
            IX_VBPAKOM         = IX_VBPAKOM
            ix_bapiaddr1       = partneraddresses
            IX_VBEPKOM         = IX_VBEPKOM
            IX_VBEPKOMX        = IX_VBEPKOMX
            IX_KONVKOM         = IX_KONVKOM
            IX_KONVKOMX        = IX_KONVKOMX
            IX_KOMFKZM         = IX_KOMFKZM
            SALES_CFGS_REF     = SALES_CFGS_REF
            SALES_CFGS_INST    = SALES_CFGS_INST
            SALES_CFGS_PART_OF = SALES_CFGS_PART_OF
            SALES_CFGS_VALUE   = SALES_CFGS_VALUE
            SALES_CFGS_BLOB    = SALES_CFGS_BLOB.

  loop at da_return where type = chara or type = chare.

    READ TABLE IX_VBPAKOM WITH KEY PARVW = 'AG'
                                   POSNR = POSNR_LOW.
    IF SY-SUBRC = 0.
      DA_KUNNR = IX_VBPAKOM-KUNNR.
    ENDIF.
    DA_AUART = VBAK-AUART.
    PERFORM BELEG_INITIALISIEREN.
    VBAK-AUART = DA_AUART.

    vbak-vgbel = i_vbakkom-vgbel.
    vbak-vgtyp = i_vbakkom-vgtyp.

    KUAGV-KUNNR = DA_KUNNR.
    IF T180-TRTYP = CHARH.
      MESSAGE ID     DA_RETURN-ID
              TYPE   CHARI
              NUMBER DA_RETURN-NUMBER
              WITH DA_RETURN-MESSAGE_V1
                   DA_RETURN-MESSAGE_V2
                   DA_RETURN-MESSAGE_V3
                   DA_RETURN-MESSAGE_V4.
    ELSE.
      PERFORM CONTAINER_REFRESH.
      MESSAGE ID     DA_RETURN-ID
              TYPE   CHARI
              NUMBER DA_RETURN-NUMBER
              WITH DA_RETURN-MESSAGE_V1
                   DA_RETURN-MESSAGE_V2
                   DA_RETURN-MESSAGE_V3
                   DA_RETURN-MESSAGE_V4.
      LEAVE.
    ENDIF.

  endloop.

  PERFORM CONTAINER_REFRESH.
* Jetzt wieder im normalen Modus arbeiten
  CLEAR:    CALL_FUNCTION,
            STATUS_BUFF_INIT,
            DISPLAY_MESSAGE_POPUP,
            call_bapi,
            display_text_popup.

ENHANCEMENT-POINT BELEG_AUS_CONTAINER_01 SPOTS ES_SAPMV45A.
ENDFORM.