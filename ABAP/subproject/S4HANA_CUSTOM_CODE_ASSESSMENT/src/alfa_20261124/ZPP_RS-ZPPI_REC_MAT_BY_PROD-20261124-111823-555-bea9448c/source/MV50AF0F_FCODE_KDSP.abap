***INCLUDE MV50AF0F_FCODE_KDSP .
*---------------------------------------------------------------------*
*       FORM FCODE_KDSP                                               *
*---------------------------------------------------------------------*
*       Display of prnting output                                     *
*---------------------------------------------------------------------*
FORM fcode_kdsp.

  DATA: da_vbeln LIKE likp-vbeln,
        da_message_printed(1) TYPE c.

  DATA: da_xnast LIKE vnast OCCURS 0 WITH HEADER LINE,
        da_ynast LIKE nast OCCURS 0 WITH HEADER LINE,
        da_xvbfa LIKE vbfa OCCURS 0 WITH HEADER LINE.

  DATA: da_updat.

  DATA: xxtrtyp         LIKE t185f-trtyp,
      da_subrc        LIKE sy-subrc,
      lv_objtype      LIKE nast-objtype,
      lv_objtype_item LIKE nast-objtype.

* Nachrichtenfindung durchführen
  DATA: BEGIN OF vbkd_key,
          mandt LIKE vbkd-mandt,
          vbeln LIKE vbkd-vbeln,
          posnr LIKE vbkd-posnr,
        END   OF vbkd_key.

* Objektkey aufbauen
  xobjky = likp-vbeln.

* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
       EXPORTING
            i_document_type        = likp-vbtyp
       IMPORTING
            e_business_object      = lv_objtype
            e_business_object_item = lv_objtype_item
       EXCEPTIONS
            OTHERS                 = 0.

  IF t185f-trtyp NE 'A'.
*   Status aktualisieren
    PERFORM xvbuk_pflegen IN PROGRAM sapfv50k.
    vbuk = xvbuk.
*   Füllt aktuelle Workarea KOMKBV2
    IF likp-vbtyp CA vbtyp_lief.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV2'
           EXPORTING
                msg_likp  = likp
                msg_old   = ' '
                msg_rv50a = rv50a
                msg_vbuk  = vbuk
                msg_trtyp = t180-trtyp
           TABLES
                tab_part  = part
                tab_lips  = xlips
                tab_vbpa  = xvbpa.
    ENDIF.
    IF likp-vbtyp CA vbtyp_liav.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBE1'
           EXPORTING
                msg_likp  = likp
                msg_old   = ' '
                msg_rv50a = rv50a
                msg_vbuk  = vbuk
                msg_trtyp = t180-trtyp
           TABLES
                tab_part  = part
                tab_lips  = xlips
                tab_vbpa  = xvbpa.
    ENDIF.
    CALL FUNCTION 'MESSAGING'
         EXPORTING
              applikation = tvlk-kappl
              msg_objky   = xobjky
              schema      = tvlk-kalsm
              pi_objtype  = lv_objtype
         TABLES
              msg_part    = part.
  ENDIF.

  CALL FUNCTION 'RV_MESSAGES_GET'
       EXPORTING
            msg_kappl      = tvlk-kappl
            msg_objky_from = xobjky
       TABLES
            tab_xnast      = da_xnast
            tab_ynast      = da_ynast.

* prüfen, ob überhaupt relevante Nachrichten zur Druckanzeige da sind
  LOOP AT da_xnast WHERE nacha EQ char1.
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.

* Ausgabe aufrufen
    CALL FUNCTION 'RV_MESSAGE_DIALOG'
         EXPORTING
              pi_kappl              = tvlk-kappl
              pi_objky              = xobjky
              pi_kschl              = tvlk-kschl
              pi_data_from_buffer   = charx
         IMPORTING
              message_printed       = da_message_printed
         EXCEPTIONS
              cancel                = 1
              message_not_printable = 2
              no_message            = 2
              print_error           = 3
              OTHERS                = 4.

    CASE sy-subrc.
      WHEN 0.
        IF da_message_printed EQ charx.
          COMMIT WORK.
        ENDIF.
        MESSAGE s084.
        LEAVE.
      WHEN 1.
        LEAVE.
      WHEN 2.
        MESSAGE s085.
        LEAVE.
      WHEN 3.
        IF da_message_printed EQ charx.
          COMMIT WORK.
        ENDIF.
        MESSAGE s086.
        LEAVE.
      WHEN OTHERS.
        LEAVE.
    ENDCASE.
  ENDIF.

ENDFORM.






