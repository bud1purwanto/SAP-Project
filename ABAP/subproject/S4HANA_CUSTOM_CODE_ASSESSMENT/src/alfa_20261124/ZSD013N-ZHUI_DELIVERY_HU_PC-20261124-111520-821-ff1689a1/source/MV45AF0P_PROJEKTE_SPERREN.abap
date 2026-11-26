*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PROJEKTE_SPERREN                                  *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PROJEKTE_SPERREN
*&---------------------------------------------------------------------*
*       Shared lock for WBS elements
*       This is necessary if planned revenues are written from a
*       billing plan in the WBS elements
*----------------------------------------------------------------------*
FORM PROJEKTE_SPERREN.

  DATA: DA_VRGNG LIKE TJ01-VRGNG,
        DA_VBUKVB LIKE VBUKVB.

  CHECK T180-TRTYP EQ CHARV.
  CHECK VBAK-VBTYP NE VBTYP_ANFR.

  DA_VBUKVB = VBUK.

  CASE VBAK-VBTYP.
    WHEN VBTYP_ANGE.
      DA_VRGNG = VRGNG_ANGE.
    WHEN VBTYP_AUFT.
      DA_VRGNG = VRGNG_AUFT.
    WHEN VBTYP_KONT.
      DA_VRGNG = VRGNG_ANGE.
      CALL FUNCTION 'SD_DETERMINE_CONTRACT_TYPE'
        EXPORTING
          I_VBAK_VBELN      = VBAK-VBELN
          I_VBUK            = DA_VBUKVB
          I_VBAK            = VBAK
        EXCEPTIONS
          SERVICE_CONTRACT  = 1
          QUANTITY_CONTRACT = 2
          OTHERS            = 3.
      IF SY-SUBRC EQ 1.
        DA_VRGNG = VRGNG_AUFT.
      ENDIF.
    WHEN OTHERS.
      DA_VRGNG = VRGNG_AUFT.
  ENDCASE.

* In BELEG_LESEN it is not really necessary to check for UPDKZ but
* maybe this routine will be called from elsewhere too.
  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE AND
                      NOT PS_PSP_PNR IS INITIAL.

    CALL FUNCTION 'CJPN_PROJECT_ACCOUNT'
      EXPORTING
        ACTIVITY            = DA_VRGNG
        INT_NUM             = XVBAP-PS_PSP_PNR
        I_ACTIVITY_CO       = VRGNG_COIN
      EXCEPTIONS
        BILLING_PLAN_LOCKED = 1
        INPUT_ERROR         = 2
        NOT_ALLOWED         = 3
        NOT_FOUND           = 4
        NO_ACCOUNT_ELEMENT  = 5
        NO_GSBER            = 6
        NO_INVOICE_ELEMENT  = 7
        OBJECT_NOT_FOUND    = 8
        WRONG_BUKRS         = 9
        WRONG_GSBER         = 10
        WRONG_KOKRS         = 11
        OTHERS              = 12.

    IF SY-SUBRC = 1.
      MESSAGE E099(V2) WITH XVBAP-PS_PSP_PNR XVBAP-POSNR.
    ENDIF.

  ENDLOOP.

ENDFORM.                               " PROJEKTE_SPERREN