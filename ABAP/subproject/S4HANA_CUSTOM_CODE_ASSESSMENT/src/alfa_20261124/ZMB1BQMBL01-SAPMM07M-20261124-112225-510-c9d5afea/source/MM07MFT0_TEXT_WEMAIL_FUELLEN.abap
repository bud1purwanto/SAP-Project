*----------------------------------------------------------------------*
*       FORM   TEXT_WEMAIL_FUELLEN.                                    *
*----------------------------------------------------------------------*
*       Die MSEG-Zeilen werden zur Verfügung gestellt, um die         *
*       MAIL-Textvariablen zu ersetzen.                               *
*       Diese Routine wird in den Nachrichtenarten MLGR/MLMD gesetzt. *
*---------------------------------------------------------------------*
FORM TEXT_WEMAIL_FUELLEN TABLES XTLINES STRUCTURE TLINE
                        USING XTHEAD STRUCTURE THEAD
                              SNAST  STRUCTURE NAST.
* tables: ekko, lfa1.
  DATA: NAME1 LIKE ADDR1_VAL-NAME1.

ENHANCEMENT-POINT TEXT_WEMAIL_FUELLEN_01 SPOTS ES_SAPMM07M.
* do.
*   index_m = index_m + 1.
*   read table xvm07m index index_m.
*   if not sy-subrc is initial.
*     exit.
*   endif.
*   if not xvm07m-weakt is initial.
*     vm07m = xvm07m.
*     read table xmseg index xvm07m-zeilv.
*     mseg = xmseg.
*     read table ymbuz index mseg-zeile.
*     read table ydm07m index ymbuz-zeile.
*     dm07m = ydm07m.
*     exit.
*   endif.
* enddo.

  DATA: BEGIN OF MSEG_KEY,
          MANDT LIKE MSEG-MANDT,
          MBLNR LIKE MSEG-MBLNR,
          MJAHR LIKE MSEG-MJAHR,
          ZEILE LIKE MSEG-ZEILE,
        END OF MSEG_KEY.
  MSEG_KEY-MANDT = SNAST-MANDT.
  MSEG_KEY-MBLNR = SNAST-OBJKY(10).
  MSEG_KEY-MJAHR = SNAST-OBJKY+10(4).
  MSEG_KEY-ZEILE = SNAST-OBJKY+14(4).

  READ TABLE XMSEG  WITH KEY MSEG_KEY BINARY SEARCH.
  MSEG = XMSEG.
  IF T158-TRTYP = H.
    READ TABLE XVM07M INDEX XMSEG-ZEILE.
    VM07M = XVM07M.
    READ TABLE YMBUZ  INDEX XMSEG-ZEILE.
    READ TABLE YDM07M INDEX YMBUZ-ZEILE.
    DM07M = YDM07M.
  ENDIF.

  IF EKKO-EBELN NE MSEG-EBELN.
    SELECT SINGLE * FROM EKKO WHERE EBELN = MSEG-EBELN.
  ENDIF.
  SELECT SINGLE * FROM EKPO WHERE EBELN = MSEG-EBELN
                              AND   EBELP = MSEG-EBELP.
  CALL FUNCTION 'MM_ADDRESS_GET'
       EXPORTING
            I_EKKO  = EKKO
       IMPORTING
            E_NAME1 = NAME1
       EXCEPTIONS
            OTHERS  = 1.
  AM07M-NAME1 = NAME1.
  MKPF = XMKPF.
  PERFORM TEXT_SYMBOL_REPLACE TABLES XTLINES
                              USING XTHEAD
                                    SNAST.
ENDFORM.