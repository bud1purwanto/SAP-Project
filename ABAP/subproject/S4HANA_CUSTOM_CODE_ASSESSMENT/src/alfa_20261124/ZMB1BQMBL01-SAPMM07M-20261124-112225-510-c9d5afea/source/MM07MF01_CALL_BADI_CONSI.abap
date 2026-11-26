*----------------------------------------------------------------------*
***INCLUDE MM07MF01_CALL_BADI_CONSI .
*----------------------------------------------------------------------*

* begin note 663537 - Fashion
*&---------------------------------------------------------------------*
*&      Form  call_badi_consi_getsobkzlifnr
*&---------------------------------------------------------------------*
FORM call_badi_consi_getsobkzlifnr using PI_KBEFU  STRUCTURE KBEFU
                                         PI_EBEFU  STRUCTURE EBEFU
                                         PI_K_MSEG STRUCTURE MSEG
                                         PI_MSEG   STRUCTURE MSEG
                                         PI_VM07M  STRUCTURE VM07M
                                         PI_RM07M  STRUCTURE RM07M
                                         PI_WUEB   STRUCTURE WUEB
                                         PI_MKPF   STRUCTURE MKPF
                                   changing
                                         X_SOBKZ
                                         X_LIFNR.

  DATA: CONSI_ACTIVE      type XFELD.
  DATA: L_BADI            TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP.
  DATA: L_BADI_ACTIVE     TYPE XFELD.
  DATA: L_SOBKZ           TYPE SOBKZ,
        L_LIFNR           TYPE ELIEF,
        L_RETURN          TYPE BAPIRET2.

  DATA: LMSEG             TYPE MSEG.                         " 979280

  CHECK NOT PI_KBEFU-RESWK IS INITIAL.

  perform check_consi_procg  CHANGING CONSI_ACTIVE.

  IF consi_active is initial.
    EXIT.
  ENDIF.

  PERFORM BADI_CONSI_INSTANCE_GET CHANGING L_BADI
                                          L_BADI_ACTIVE.

  IF L_BADI_ACTIVE IS INITIAL.
    EXIT.
  ENDIF.

  move-corresponding pi_mseg to lmseg.            " 979280

  IF PI_MSEG-meins is initial and                 " 979280
     pi_mseg-erfmg is initial and                 " 979280
     not pi_k_mseg-erfmg is initial.              " 979280
     move pi_k_mseg-erfmg to lmseg-erfmg.         " 979280
  endif.                                          " 979280

  CALL METHOD L_BADI->WRF_GET_MSEG_GI_GR
    EXPORTING
      IS_KBEFU     = PI_KBEFU
      IS_EBEFU     = PI_EBEFU
      IS_MSEG      = LMSEG                        " 979280
      IS_VM07M     = PI_VM07M
      IS_RM07M     = PI_RM07M
      IS_WUEB      = PI_WUEB
      IS_MKPF      = PI_MKPF
    IMPORTING
      E_SOBKZ      = L_SOBKZ
      E_LIFNR      = L_LIFNR
      E_RETURN     = L_RETURN.

  IF L_RETURN IS INITIAL.
    X_LIFNR = L_LIFNR.
    X_SOBKZ = L_SOBKZ.
  ELSE.
    MESSAGE ID L_RETURN-ID TYPE L_RETURN-TYPE NUMBER L_RETURN-NUMBER
            WITH L_RETURN-MESSAGE_V1  L_RETURN-MESSAGE_V2
                 L_RETURN-MESSAGE_V3  L_RETURN-MESSAGE_V4.
  ENDIF.
ENDFORM.                    " call_badi_consi_getsobkzlifnr


*&---------------------------------------------------------------------*
*&      Form  check_consi_procg
*&---------------------------------------------------------------------*
FORM check_consi_procg  CHANGING P_ACTIVE.

  STATICS: S_INIT_DONE    TYPE XFELD VALUE ' '.
  STATICS: S_CONSI_ACTIVE TYPE XFELD.
  STATICS: S_TCURM        TYPE TCURM.

  IF S_INIT_DONE IS INITIAL.

    SELECT SINGLE * FROM TCURM INTO S_TCURM.

    IF sy-subrc <> 0.
      clear S_CONSI_ACTIVE.
    ELSE.
      S_CONSI_ACTIVE = S_TCURM-CONS_HND.
    ENDIF.
    S_INIT_DONE = 'X'.
  ENDIF.

  P_ACTIVE = S_CONSI_ACTIVE.
endform.

*&---------------------------------------------------------------------*
*&      Form  BADI_CONSI_INSTANCE_GET
*&---------------------------------------------------------------------*
FORM BADI_CONSI_INSTANCE_GET
           CHANGING PE_BADI TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP
           PE_BADI_ACTIVE   TYPE XFELD.

  IF G_INIT_DONE IS INITIAL.
    CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
      EXPORTING
        EXIT_NAME              = 'MB_ME_CSGMT_BADI_SAP'
        NULL_INSTANCE_ACCEPTED = 'X'
      IMPORTING
        ACT_IMP_EXISTING       = G_BADI_ACTIVE
      CHANGING
        INSTANCE               = G_BADI.
    G_INIT_DONE = 'X'.
  ENDIF.

  PE_BADI        = G_BADI.
  PE_BADI_ACTIVE = G_BADI_ACTIVE.

ENDFORM.                    " BADI_CONSI_INSTANCE_GET

*&---------------------------------------------------------------------*
*&      Form  call_badi_consi_setsobkzlifnr
*&---------------------------------------------------------------------*
FORM call_badi_consi_setsobkzlifnr using PI_KBEFU STRUCTURE KBEFU
                                         PI_SOBKZ
                                         PI_LIFNR.

  DATA: CONSI_ACTIVE      type XFELD.
  DATA: L_BADI            TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP.
  DATA: L_BADI_ACTIVE     TYPE XFELD.

  CHECK NOT PI_KBEFU-RESWK IS INITIAL.

  perform check_consi_procg  CHANGING CONSI_ACTIVE.

  IF consi_active is initial.
    EXIT.
  ENDIF.

  PERFORM BADI_CONSI_INSTANCE_GET CHANGING L_BADI
                                           L_BADI_ACTIVE.

  IF L_BADI_ACTIVE IS INITIAL.
    EXIT.
  ENDIF.

  CALL METHOD L_BADI->WRF_SET_MSEG_GI_GR
    EXPORTING
      I_LIFNR     = PI_LIFNR
      I_SOBKZ     = PI_SOBKZ.

ENDFORM.                    " call_badi_consi_setsobkzlifnr


*&---------------------------------------------------------------------*
*&      Form  call_badi_consi_getcsgmtmvt
*&---------------------------------------------------------------------*
*  Aufruf BADI-Methode WRF_GET_CSGMT_MVT_STRUCT_ARTICLE
*  Bestimmung der Bewegungsart zum strukturierten Artikel
*---------------------------------------------------------------------*

FORM call_badi_consi_GetCsgmtMvt using PI_SOBKZ TYPE SOBKZ
                                       PI_XSTBW TYPE XSTBW
                                       PI_SHKZG TYPE SHKZG
                              changing PX_BWART_T156N TYPE BWART.

  DATA: CONSI_ACTIVE      type XFELD.
  DATA: L_BADI            TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP.
  DATA: L_BADI_ACTIVE     TYPE XFELD.
  DATA: L_SOBKZ           TYPE SOBKZ,
        L_LIFNR           TYPE ELIEF,
        L_RETURN          TYPE BAPIRET2.

  perform check_consi_procg  CHANGING CONSI_ACTIVE.

  IF consi_active is initial.
    EXIT.
  ENDIF.

  PERFORM BADI_CONSI_INSTANCE_GET CHANGING L_BADI
                                           L_BADI_ACTIVE.

  IF L_BADI_ACTIVE IS INITIAL.
    EXIT.
  ENDIF.

  CALL METHOD L_BADI->WRF_GET_CSGMT_MVT_STRUCT_ART
    EXPORTING
      I_SOBKZ       = PI_SOBKZ
      I_XSTBW       = PI_XSTBW
      I_SHKZG       = PI_SHKZG
    CHANGING
      X_BWART_T156N = PX_BWART_T156N.

ENDFORM.                    " call_badi_consi_GetCsgmtMvt

*&---------------------------------------------------------------------*
*&      Form  call_badi_consi_chpriceSArt
*&---------------------------------------------------------------------*
*  Aufruf BADI-Methode WRF_CHECK_PRICE_STRUCT_ARTICLE
*  Preistest für den strukturierten Artikel
*---------------------------------------------------------------------*
FORM call_badi_consi_ChPriceSArt using  PI_LIFNR TYPE LIFNR
                                        PI_BWART TYPE BWART
                                        PI_SOBKZ TYPE SOBKZ
                                        PI_MATNR_HEAD TYPE MATNR
                                        PI_WERKS  TYPE WERKS_D
                                        PI_MENGE  TYPE MENGE_D
                                        PI_MEINS  TYPE MEINS
                                        PIT_XSTRU TYPE WSOS_STULI_T.


  DATA: CONSI_ACTIVE      type XFELD.
  DATA: L_BADI            TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP.
  DATA: L_BADI_ACTIVE     TYPE XFELD.
  DATA: L_RETURN          TYPE BAPIRET2.

  perform check_consi_procg  CHANGING CONSI_ACTIVE.

  IF consi_active is initial.
    EXIT.
  ENDIF.

  PERFORM BADI_CONSI_INSTANCE_GET CHANGING L_BADI
                                          L_BADI_ACTIVE.

  IF L_BADI_ACTIVE IS INITIAL.
    EXIT.
  ENDIF.

  CALL METHOD L_BADI->WRF_CHECK_PRICE_STRUCT_ARTICLE
    EXPORTING
      I_LIFNR       = PI_LIFNR
      I_BWART       = PI_BWART
      I_SOBKZ       = PI_SOBKZ
      I_MATNR_HEAD  = PI_MATNR_HEAD
      I_WERKS       = PI_WERKS
      IT_XSTRU      = PIT_XSTRU
      I_MENGE       = PI_MENGE
      I_MEINS       = PI_MEINS
    IMPORTING
      E_RETURN     = L_RETURN.

  IF NOT L_RETURN IS INITIAL.
    MESSAGE ID L_RETURN-ID TYPE L_RETURN-TYPE NUMBER L_RETURN-NUMBER
            WITH L_RETURN-MESSAGE_V1  L_RETURN-MESSAGE_V2
                 L_RETURN-MESSAGE_V3  L_RETURN-MESSAGE_V4.
  ENDIF.
ENDFORM.                    " call_badi_consi_ChPriceSArt

*&---------------------------------------------------------------------*
*&      Form  call_badi_consi_checkstructart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MSEG  text
*      -->P_VM07M  text
*      <--P_L_KONSI_CHECK_C  text
*----------------------------------------------------------------------*
FORM call_badi_consi_checkstructart  USING    PI_MSEG   structure mseg
                                              PI_VM07M  structure vm07m
                                     CHANGING PX_KONSI_CHECK_C.
  DATA: CONSI_ACTIVE      type XFELD.
  DATA: L_BADI            TYPE REF TO IF_EX_MB_ME_CSGMT_BADI_SAP.
  DATA: L_BADI_ACTIVE     TYPE XFELD.

  perform check_consi_procg  CHANGING CONSI_ACTIVE.

  IF consi_active is initial.
    PX_KONSI_CHECK_C = 'X'.
    EXIT.
  ENDIF.

  PERFORM BADI_CONSI_INSTANCE_GET CHANGING L_BADI
                                           L_BADI_ACTIVE.

  IF L_BADI_ACTIVE IS INITIAL.
    EXIT.
  ENDIF.

  CALL METHOD L_BADI->WRF_CHECK_STRUCT_ARTICLE_VAL
    EXPORTING
      IS_MSEG       = PI_MSEG
      IS_VM07M      = PI_VM07M
    IMPORTING
      E_KONSI_CHECK = PX_KONSI_CHECK_C.

ENDFORM.                    " call_badi_consi_checkstructart



* end note 663537 - Fashion