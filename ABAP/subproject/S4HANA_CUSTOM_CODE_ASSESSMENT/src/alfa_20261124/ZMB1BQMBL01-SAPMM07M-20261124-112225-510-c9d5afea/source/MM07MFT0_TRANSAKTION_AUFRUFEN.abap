*---------------------------------------------------------------------*
*       FORM   TRANSAKTION_AUFRUFEN                                   *
*---------------------------------------------------------------------*
*       Die Transaktion wird aufgerufen.                              *
*---------------------------------------------------------------------*
FORM TRANSAKTION_AUFRUFEN.
  CLEAR PARAMID.
  SET PARAMETER ID 'CHA' FIELD PARAMID-CHARG.
  READ TABLE X063T INDEX 1.
  IF NOT SY-SUBRC IS INITIAL.
    SELECT * FROM T063T APPENDING TABLE X063T.
  ENDIF.
  DATA: GET_BWART LIKE MSEG-BWART,
        SET_BWART LIKE MSEG-BWART.
  GET PARAMETER ID 'BWA' FIELD GET_BWART.
  SET PARAMETER ID 'BWA' FIELD SET_BWART.
  LOOP AT X063T WHERE TCODE = T063O-TCODE.
    CASE X063T-PARAMID.
      WHEN 'BWA'.
        SET PARAMETER ID 'BWA' FIELD MSEG-BWART.
      WHEN 'ANR'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-AUFNR IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'AUFNR'.
          EXIT.
        ENDIF.
        CALL FUNCTION 'CO_SF_CALL_ORDER_CATEGORY'
             EXPORTING
                  AUFNR              = MSEG-AUFNR
                  AKTYP              = A
             EXCEPTIONS
                  ORDER_NOT_FOUND    = 1
                  CATEGORY_NOT_FOUND = 2
                  OTHERS             = 3.
        VW = X.
        IF NOT SY-SUBRC IS INITIAL.
          MESSAGE W017(CO) WITH MSEG-AUFNR.
          EXIT.
        ENDIF.
*       SET PARAMETER ID 'ANR' FIELD MSEG-AUFNR.
      WHEN 'BES'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-EBELN IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'EBELN'.
          EXIT.
        ENDIF.
        IF X063T-TCODE+0(3) = 'ME2' AND DM07M-BSTYP = L.
          SET PARAMETER ID 'VRT' FIELD MSEG-EBELN.
          SET PARAMETER ID 'BSP' FIELD MSEG-EBELP.
        ELSE.
          SET PARAMETER ID 'BES' FIELD MSEG-EBELN.
          SET PARAMETER ID 'BSP' FIELD MSEG-EBELP.
        ENDIF.
      WHEN 'LIF'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-LIFNR IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'LIFNR'.
          EXIT.
        ELSE.
          IF NOT MSEG-KZZUG IS INITIAL AND NOT MSEG-EBELN IS INITIAL.
            VW = X.
            PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'LIFNR'.
            EXIT.
          ENDIF.
        ENDIF.
        IF FCAUSW-XSELP IS INITIAL.
          READ TABLE YVM07M INDEX INDEX_L.
          IF SY-SUBRC IS INITIAL.
            VM07M-EKORG = YVM07M-EKORG.
          ENDIF.
        ENDIF.
        SET PARAMETER ID 'LIF' FIELD MSEG-LIFNR.
        SET PARAMETER ID 'EKO' FIELD VM07M-EKORG.
        SET PARAMETER ID 'KDY' FIELD '/110/310'.
      WHEN 'MAT'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-MATNR IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'MATNR'.
          EXIT.
        ENDIF.
* &001 begin: P.Pfaff: Anpassung wegen Bestandsübersicht Wertartikel
        IF NOT MSEG-MATBF IS INITIAL.
          SET PARAMETER ID 'MAT' FIELD MSEG-MATBF.
        ELSE.
* &001 end
          SET PARAMETER ID 'MAT' FIELD MSEG-MATNR.
* &001 begin: P.Pfaff: Anpassung wegen Bestandsübersicht Wertartikel
        ENDIF.
* &001 end
      WHEN 'WRK'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-WERKS IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'WERKS'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'WRK' FIELD MSEG-WERKS.
      WHEN 'LAG'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-LGORT IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'LGORT'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'LAG' FIELD MSEG-LGORT.
      WHEN 'CHA'.
        SET PARAMETER ID 'CHA' FIELD PARAMID-CHARG.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-CHARG IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'CHARG'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'CHA' FIELD MSEG-CHARG.
      WHEN 'PRR'.
        SET PARAMETER ID 'PRR' FIELD T158-PRREG.
      WHEN 'RES'.
        IF NOT X063T-XMUSS IS INITIAL AND MSEG-RSNUM IS INITIAL.
          VW = X.
          PERFORM NO_OUTPUT(SAPFM07M) USING 'MSEG' 'RSNUM'.
          EXIT.
        ENDIF.
        SET PARAMETER ID 'RES' FIELD MSEG-RSNUM.
        SET PARAMETER ID 'RPO' FIELD MSEG-RSPOS.
      WHEN 'SLK'.
*       DD = Werks.- Lagerortbestände u. andere.
        SET PARAMETER ID 'SLK' FIELD 'DD'.
      WHEN 'MXX'.
*       B = Buchhaltung
*       D = Dispositon
*       E = Einkauf
*       L = Lagerungsdaten
*       X = Bestand Werk
*       Z = Bestand Lagerort
        SET PARAMETER ID 'MXX' FIELD 'BDEKLXZ'.
      WHEN 'MBN'.
        SET PARAMETER ID 'MBN' FIELD MKPF-MBLNR.
        SET PARAMETER ID 'MJA' FIELD MKPF-MJAHR.
      WHEN 'KNR'.                                               "1118920
        DATA: LV_KNR LIKE MSEG-MAT_KDAUF,                       "1118920
              LV_KPO LIKE MSEG-MAT_KDPOS,                       "1118920
              LV_PRJ LIKE MSEG-MAT_PSPNR,                       "1118920
              LV_BERID LIKE AFPOD-BERID.                        "1118920
        IF MSEG-SHKZG = 'H'.                                    "1118920
          LV_KNR = MSEG-MAT_KDAUF.                              "1118920
          LV_KPO = MSEG-MAT_KDPOS.                              "1118920
          LV_PRJ = MSEG-MAT_PSPNR.                              "1118920
        ELSEIF MSEG-SHKZG = 'S'                                 "1118920
           AND ( MSEG-UMSOK = 'E' OR MSEG-UMSOK = 'Q' ).        "1118920
          LV_KNR = MSEG-KDAUF.                                  "1118920
          LV_KPO = MSEG-KDPOS.                                  "1118920
          LV_PRJ = MSEG-PS_PSP_PNR.                             "1118920
        ENDIF.                                                  "1118920
        SET PARAMETER ID 'KNR' FIELD LV_KNR.                    "1118920
        SET PARAMETER ID 'KPO' FIELD LV_KPO.                    "1118920
        SET PARAMETER ID 'PRJ' FIELD LV_PRJ.                    "1118920
        SET PARAMETER ID 'BERID' FIELD LV_BERID.                "1118920
*       Receiving side of transfer -> use issuing keys          "1118920
        IF MSEG-SHKZG = 'S' AND NOT MSEG-UMMAT IS INITIAL.      "1118920
          SET PARAMETER ID 'MAT' FIELD MSEG-UMMAT.              "1118920
        ENDIF.                                                  "1118920
        IF MSEG-SHKZG = 'S' AND NOT MSEG-UMWRK IS INITIAL.      "1118920
          SET PARAMETER ID 'WRK' FIELD MSEG-UMWRK.              "1118920
        ENDIF.                                                  "1118920
    ENDCASE.
  ENDLOOP.
  CASE VW.
    WHEN X.
      CLEAR: INDEX_L,
             XPF02.
      SET PARAMETER ID 'BWA' FIELD GET_BWART.
    WHEN SPACE.
      IF X063T-TCODE+0(3) = 'ME2' AND DM07M-BSTYP = L.
        X063T-TCODE+2(1) = 3.
      ENDIF.
      IF NOT X063T-TCODE IS INITIAL.
        IF X063T-TCODE = CCOD-FB03.
          AWREF    = MKPF-MBLNR.
          AWORG(4) = MKPF-MJAHR.
          CALL FUNCTION 'AC_DOCUMENT_RECORD'
               EXPORTING
                    I_AWSYS      = MKPF-AWSYS
                    I_AWTYP      = RW_AWTYP
                    I_AWREF      = AWREF
                    I_AWORG      = AWORG
               EXCEPTIONS
                    NO_DOCUMENT  = 1
                    NO_REFERENCE = 2.
          IF NOT SY-SUBRC IS INITIAL.
            IF  SY-SUBRC EQ 1.
              MESSAGE W082 WITH MKPF-MBLNR.
            ELSE.
              MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.
          ENDIF.
        ELSEIF X063T-TCODE = CCOD-VL03.
          DATA: VBELN LIKE VM07M-VBELN.
          VBELN = XMKPF-XBLNR.
          CALL FUNCTION 'SD_SHOW_ORIGINATE_DOCUMENT'
               EXPORTING
                    MBLNR             = XMKPF-MBLNR
                    MJAHR             = XMKPF-MJAHR
                    VBELN             = VBELN
               EXCEPTIONS
                    NO_DELIVERY_FOUND = 1
                    OTHERS            = 2.
          IF NOT SY-SUBRC IS INITIAL.
            IF  SY-SUBRC EQ 1.
              MESSAGE W203 WITH XMKPF-MBLNR.
            ELSE.
              MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
            ENDIF.
          ENDIF.
* &001 begin: P.Pfaff: Anpassung wegen Bestandsübersicht Wertartikel
        ELSEIF X063T-TCODE = CCOD-WMBE AND
           ( NOT MSEG-MENGU IS INITIAL OR
                 MSEG-WERTU IS INITIAL ).
          MESSAGE W418 WITH MSEG-MATNR.
        ELSEIF X063T-TCODE = CCOD-MMBE AND
                 MSEG-MENGU IS INITIAL AND
             NOT MSEG-WERTU IS INITIAL.
          MESSAGE W417 WITH MSEG-MATNR.
* &001 end
        ELSE.
          CALL TRANSACTION X063T-TCODE AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'BWA' FIELD GET_BWART.
        ENDIF.
      ELSE.
        CLEAR: INDEX_L,
               XPF02.
      ENDIF.
  ENDCASE.
ENDFORM.