*---------------------------------------------------------------------*
*       FORM FCODE_GRKO                                               *
*---------------------------------------------------------------------*
*       Anzeige Verkaufsbeleg aus Gruppenkontrakt                     *
*---------------------------------------------------------------------*
FORM FCODE_GRKO.

  LOCAL: GRUKO.
  DATA: lv_display_only TYPE boole.

* Zum verzweigen muß eine Zeile markiert sein
  READ TABLE GRUKO WITH KEY SELKZ = CHARX.
  IF SY-SUBRC NE 0.
    MESSAGE I765.
    EXIT.
  ENDIF.

* Displaying is only possible when subcontract is archived.
  lv_display_only = abap_false.
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true AND
     data_read_from_archive EQ abap_true.
    lv_display_only = abap_true.
  ENDIF.

* In markierten Unterkontrakt verzweigen
  LOOP AT GRUKO WHERE NOT SELKZ IS INITIAL.
*   Unterkontrakte dürfen nur im Ändernmodus aufgerufen werden,
*   wenn der Gruppenkontrakt im Anzeigemodus angezeigt wird.
    IF T180-TRTYP EQ CHARA AND
       NOT lv_display_only EQ abap_true.
      CALL FUNCTION 'RV_CALL_CHANGE_TRANSACTION'
           EXPORTING
                VBELN = GRUKO-VBELN
                POSNR = POSNR_LOW
                VBTYP = VBTYP_KONT.
    ELSE.
      CALL FUNCTION 'RV_CALL_DISPLAY_TRANSACTION'
           EXPORTING
                VBELN = GRUKO-VBELN
                POSNR = POSNR_LOW
                VBTYP = VBTYP_KONT.
    ENDIF.
    CLEAR GRUKO-SELKZ.
    MODIFY GRUKO.
  ENDLOOP.

ENDFORM.