ENHANCEMENT 1  .

****************************************************
* Created by: PST_MONICA
* Created on: 31.08.2012
* Usage: Validasi One Time Customer hanya untuk
*        Sample Order (ZDSO atau ZESO)
****************************************************

DATA:
      ZKTOKD TYPE KNA1-KTOKD,
      ZKUNNR TYPE VBAK-KUNNR.

ZKUNNR = VBAK-KUNNR.

SELECT SINGLE KNA1~KTOKD INTO ZKTOKD
  FROM KNA1
  WHERE KNA1~KUNNR = ZKUNNR.

SY-SUBRC = 0.
IF VBAK-AUART NE 'ZDSO' AND VBAK-AUART NE 'ZESO'.
  IF ZKTOKD EQ 'ZOTC'.
  MESSAGE 'One time customer hanya untuk Sample Order, order type: ZDSO atau ZESO.' TYPE 'E'.
  ENDIF.


ENDIF.


****************************************************
* Created by: PST_MONICA
* Created on: 17.09.2012
* Usage: Validasi Currency yang digunakan di SO
*        sama atau tidak dengan customer master
****************************************************

IF SY-TCODE = 'VA01'
    OR SY-TCODE = 'VA21'
    OR SY-TCODE = 'VA02'
    OR SY-TCODE = 'VA22'
    OR SY-TCODE = 'ZVA02S'.

    IF SY-DYNNR = '4301'.
      DATA: WA_KNVV TYPE KNVV.

      SELECT SINGLE *
        FROM KNVV
        INTO WA_KNVV
       WHERE KUNNR = VBAK-KUNNR
         AND VKORG = VBAK-VKORG.

      IF VBAK-WAERK <> WA_KNVV-WAERS.
        DATA:
              P_TXT2 TYPE C LENGTH 100,
              P_ANS.

        CONCATENATE 'Currency antara customer master ='
                    WA_KNVV-WAERS
                    'dan sales dokumen ='
                    VBAK-WAERK 'berbeda!'
                    'Lanjutkan?' INTO P_TXT2 SEPARATED BY SPACE.

        CALL FUNCTION 'POPUP_TO_CONFIRM'
               EXPORTING
                 TITLEBAR                    = 'Document currency confirmation'
                 TEXT_QUESTION               = P_TXT2
                 DEFAULT_BUTTON              = '1'
                 DISPLAY_CANCEL_BUTTON       = ' '
               IMPORTING
                 ANSWER                      = P_ANS.

        IF SY-SUBRC <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

        CASE P_ANS.
          WHEN '1'.
            VBAK-WAERK = VBAK-WAERK.
*            DELETE XKOMV WHERE KSCHL = 'ZD00'.
          WHEN '2'.
            VBAK-WAERK = WA_KNVV-WAERS.
        ENDCASE.
      ENDIF.
    ENDIF.

****Add By Will 28.12.2012
    LOOP AT XVBAP WHERE NETWR > 0 AND WAERK NE VBAK-WAERK.
      DELETE XKOMV WHERE KSCHL = 'ZD00'.
      DELETE XKOMV WHERE KSCHL = 'ZDD0'.
      DELETE XKOMV WHERE KSCHL = 'ZE00'.
      DELETE XKOMV WHERE KSCHL = 'ZED0'.
      DELETE XKOMV WHERE KSCHL = 'ZEC0'.
    ENDLOOP.
****End Add By Will 28.12.2012

  ENDIF.


ENDENHANCEMENT.
