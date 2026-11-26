*---------------------------------------------------------------------*
*              Lesen Frachtlieferant                                   *
*----------------------------------------------------------------------*
FORM f_lieferant_lesen.

  DATA: BEGIN OF ekbz_key,
         mandt LIKE sy-mandt,
         ebeln LIKE ekbz-ebeln,
         ebelp LIKE ekbz-ebelp,
         stunr LIKE ekbz-stunr,
         zaehk LIKE ekbz-zaehk,
         vgabe LIKE ekbz-vgabe,
         gjahr LIKE ekbz-gjahr,
         belnr LIKE ekbz-belnr,
         buzei LIKE ekbz-buzei,
        END OF ekbz_key.

  CLEAR: dekbnk,
         d_ekbnk,
         i_ekbz,
         flindex.

  REFRESH: dekbnk,
           d_ekbnk,
           i_ekbz,
           flindex.

  SORT yekbnk.
  LOOP AT yekbnk.
    CHECK yekbnk-ebeln = mseg-ebeln AND
          yekbnk-ebelp = mseg-ebelp AND NOT
          yekbnk-frerf IS INITIAL.
    d_ekbnk = yekbnk.
    d_ekbnk = yekbnk.
    d_ekbnk-zeile = sy-tabix.
    APPEND d_ekbnk.
  ENDLOOP.
  IF vm07m-xstor = eins OR vm07m-xstor = zwei.

    CALL FUNCTION 'MMPUR_EKBZ_READ_EBELN_EBELP'
         EXPORTING
              pi_ebeln             = mseg-ebeln
              pi_ebelp             = mseg-ebelp
*             PI_BYPASSING_BUFFER  =
              pi_refresh_buffer    = 'X'
         TABLES
              pto_ekbz_po          = i_ekbz
         EXCEPTIONS
              no_records_requested = 1
              OTHERS               = 2
              .
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    SORT d_ekbnk.
    SORT i_ekbz BY mandt ebeln ebelp stunr zaehk vgabe gjahr belnr
                   buzei.
    LOOP AT d_ekbnk.
      ekbz_key-mandt = sy-mandt.
      ekbz_key-ebeln = d_ekbnk-ebeln.
      ekbz_key-ebelp = d_ekbnk-ebelp.
      ekbz_key-stunr = d_ekbnk-stunr.
      ekbz_key-zaehk = d_ekbnk-zaehk.
      ekbz_key-vgabe = 1.
      ekbz_key-gjahr = mseg-sjahr.
      ekbz_key-belnr = mseg-smbln.
      ekbz_key-buzei = mseg-smblp.
      READ TABLE i_ekbz WITH KEY ekbz_key BINARY SEARCH.
      MOVE-CORRESPONDING i_ekbz TO dekbnk.
      dekbnk-zeile = d_ekbnk-zeile.
      APPEND dekbnk.
    ENDLOOP.
  ELSE.
    LOOP AT d_ekbnk.
      MOVE-CORRESPONDING d_ekbnk TO dekbnk.
      dekbnk-zeile = d_ekbnk-zeile.
      APPEND dekbnk.
    ENDLOOP.
  ENDIF.

ENDFORM.