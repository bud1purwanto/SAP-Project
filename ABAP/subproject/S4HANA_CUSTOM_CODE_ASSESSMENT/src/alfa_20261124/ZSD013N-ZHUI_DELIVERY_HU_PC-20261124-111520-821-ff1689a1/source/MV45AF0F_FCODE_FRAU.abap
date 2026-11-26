*&---------------------------------------------------------------------*
*&      Form  FCODE_FRAU
*&---------------------------------------------------------------------*
*       Frachtauskunft vom Auftrag aufrufen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FCODE_FRAU
                USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  DATA:
    L_VBAK     LIKE VBAK   OCCURS 0 WITH HEADER LINE,
    L_VEKP     LIKE VEKPVB OCCURS 0 WITH HEADER LINE,
    L_VEPO     LIKE VEPOVB OCCURS 0 WITH HEADER LINE,
    L_VPOBJKEY LIKE VEKP-VPOBJKEY,
    ls_object  type vsep_s_objkey.


  PERFORM CALL_DIALOG_EXPORT.

* packing functionality needs VBAK as TABLES-PARAMETER:
  L_VBAK       = VBAK.
  L_VBAK-VBELN = *VBAK-VBELN.
  APPEND L_VBAK.
    CALL FUNCTION 'HU_PACKING_SALES_PROPOSAL'
           EXPORTING
                IF_ANZEIGEMODUS   = t180-trtyp
                IF_DUNKEL         = 'X'
                if_profile        = '0002'
                IS_VBAK           = VBAK
                IT_XVBAP          = XVBAP[]
                IT_XVBPA          = XVBPA[]
           CHANGING
                CT_XVBFA          = XVBFA[]
                CT_YVBFA          = YVBFA[]
                CT_XVBAPF         = XVBAPF[].
    LS_OBJECT-OBJECT = '02'.
    LS_OBJECT-OBJKEY = L_VBAK-VBELN.
    CALL FUNCTION 'HU_GET_HUS'
             EXPORTING
                  IS_OBJECTS = LS_OBJECT
             IMPORTING
                  ET_HEADER = L_VEKP[]
                  ET_ITEMS  = L_VEPO[]
             EXCEPTIONS
                  others = 0.
* call freight cost information
  CALL FUNCTION 'SD_SCD_COST_INFO_SALES_ORDER_D'
       EXPORTING
            I_VBAK  = L_VBAK
       TABLES
            I_VBAP  = XVBAP
            I_VBEP  = XVBEP
            I_VBFA  = XVBFA
            I_VBKD  = XVBKD
            I_VBPA  = XVBPA
            I_VBUK  = XVBUK
            I_VBUV  = XVBUV
            I_VBUP  = XVBUP
            I_VEKP  = L_VEKP
            I_VEPO  = L_VEPO
            I_VBADR = XVBADR
            I_FPLA  = XFPLA
            I_FPLT  = XFPLT
            I_VBAPF = XVBAPF
       EXCEPTIONS
            OTHERS  = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.