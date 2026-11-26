*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_CHECK                            *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  retail_struct_check
*----------------------------------------------------------------------*
*  The hunt for Retail-structures in the remaining GR-lines is open:
*  reading IT_XYMSEG you have to find materials with Retail-structures
*  in RSTRUCT. And certain headers and components in RSTRUCT must
*  be found in IT_XYMSEG. If not there must be an inconsistency and
*  the user need to get a message to proof the situation
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_CHECK  USING KZ_YMSEG TYPE C.
   DATA: WA_RSTRUCT   TYPE T_RSTRUCT.
   DATA: WA_XYMSEG    TYPE T_XYMSEG.
   DATA: HEADER       LIKE MSEG-ZEILE.
   DATA: LINE         LIKE MSEG-ZEILE.
   DATA: ARTICLE      LIKE MSEG-MATNR.
   DATA: XAUTO_COMP   LIKE MSEG-XAUTO.
   DATA: LINE_XYMSEG  LIKE SY-TABIX.
   DATA: PRE_COND_OK  TYPE C.

* *************************** testing preconditions
   PRE_COND_OK = SPACE.
   PERFORM RETAIL_STRUCT_PRECONDITIONS USING PRE_COND_OK.
   CHECK PRE_COND_OK = X.

*                           * Version works only for YMseg-Test
   CHECK KZ_YMSEG = X.
* ***************************

*                           * no sence to make Checks without any
*                           * Retail-structures
   READ TABLE IT_RSTRUCT INTO WA_RSTRUCT INDEX 1.
   CHECK SY-SUBRC IS INITIAL.
*                           * make a partial copy of YMESG or XMSEG
   IF NOT KZ_YMSEG IS INITIAL.
      PERFORM RETAIL_STRUCT_COPY_YMSEG.
   ELSE.
      PERFORM RETAIL_STRUCT_COPY_XMSEG.
   ENDIF.

*                          * only unmarked lines need to be checked
   LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE KZOK IS INITIAL
                                         AND  NOT ERFMG IS INITIAL.
*                           * actual line LINE_XYMSEG
      LINE_XYMSEG = SY-TABIX.
      READ TABLE IT_RSTRUCT INTO WA_RSTRUCT
           WITH KEY MATNR = WA_XYMSEG-MATNR
                    BSTME = WA_XYMSEG-BSTME
                    ERFME = WA_XYMSEG-ERFME
                    XAUTO = WA_XYMSEG-XAUTO.
      IF SY-SUBRC IS INITIAL.
*                            * start of the check-sequence

*                            * ---------------------------------
*                            * full items and empties
*                            * ---------------------------------
         IF     WA_RSTRUCT-UPVOR = UPTYP_LG.
*                            * full item:
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            XAUTO_COMP     = L.          " no transfer
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all empties have to be found
            PERFORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

         ELSEIF WA_RSTRUCT-UPTYP = UPTYP_LG.
*                            * empties
*                            * full item an all emties have to be found
            HEADER      = WA_XYMSEG-URZEI.
            ARTICLE     = WA_XYMSEG-MATNR.
            LINE        = WA_XYMSEG-ZEILE.
            XAUTO_COMP  = L.          " no transfer
*                           *  set default 'working'
            WA_XYMSEG-KZOK = W.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
            PERFORM RETAIL_STRUCT_CHECK_HEADER USING WA_RSTRUCT
                                                     KZ_YMSEG
                                                     HEADER
                                                     ARTICLE
                                                     LINE
                                                     LINE_XYMSEG
                                                     XAUTO_COMP.

*                            * ---------------------------------
*                            * generic articles
*                            * ---------------------------------
         ELSEIF WA_RSTRUCT-UPVOR = UPTYP_VAR.
*                            * generic article head
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            WA_XYMSEG-KZOK = X.
            XAUTO_COMP     = SPACE.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all components have to be found
            perform RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

         ELSEIF WA_RSTRUCT-UPTYP = UPTYP_VAR.
*                            * generic article component
            HEADER      = WA_XYMSEG-URZEI.
            ARTICLE     = WA_XYMSEG-MATNR.
            LINE        = WA_XYMSEG-ZEILE.
            XAUTO_COMP  = SPACE.
*                           *  set default 'working'
            WA_XYMSEG-KZOK = W.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
            PERFORM RETAIL_STRUCT_CHECK_HEADER USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                         XAUTO_COMP.

*                            * ---------------------------------
*                            * structured articles
*                            * ---------------------------------
         ELSEIF ( WA_RSTRUCT-ATTYP = ATTYP-VKS
              OR  WA_RSTRUCT-ATTYP = ATTYP-LOT
              OR  WA_RSTRUCT-ATTYP = ATTYP-DIS )
              AND WA_RSTRUCT-XAUTO IS INITIAL.
*                            * structured article head
            HEADER         = WA_XYMSEG-ZEILE.
            ARTICLE        = WA_XYMSEG-MATNR.
            LINE           = WA_XYMSEG-ZEILE.
            XAUTO_COMP     = S.          " no transfer
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
*                            * all components have to be found
            PERFORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                         KZ_YMSEG
                                                         HEADER
                                                         ARTICLE
                                                         LINE
                                                         LINE_XYMSEG
                                                               "391224
                                                         WA_XYMSEG-ERFMG
                                                         XAUTO_COMP.

         ELSEIF WA_RSTRUCT-XAUTO = S.
*                            * structured article component
            HEADER      = WA_XYMSEG-URZEI.
            ARTICLE     = WA_XYMSEG-MATNR.
            LINE        = WA_XYMSEG-ZEILE.
            XAUTO_COMP  = S.          " no transfer
*                           *  set default 'working'
            WA_XYMSEG-KZOK = W.
            MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
            PERFORM RETAIL_STRUCT_CHECK_HEADER USING WA_RSTRUCT
                                                     KZ_YMSEG
                                                     HEADER
                                                     ARTICLE
                                                     LINE
                                                     LINE_XYMSEG
                                                     XAUTO_COMP.
         ENDIF.
      ELSE.
*                            * not a known member of RSTRUCT -> ok
         WA_XYMSEG-KZOK = X.
         MODIFY IT_XYMSEG INDEX LINE_XYMSEG FROM WA_XYMSEG.
      ENDIF.
   ENDLOOP. "IT_XYMSEG

*                           * Postcondition:
*                           * if there are any unmarked items, there
*                           * must be an inconsistency
   READ TABLE IT_XYMSEG INTO WA_XYMSEG
        WITH KEY KZOK = SPACE.
   IF  SY-SUBRC IS INITIAL.
*                           * Stücklistenprüfung unvollständig beendet.
      MESSAGE E365.
   ENDIF.

ENDFORM.                    "RETAIL_STRUCT_CHECK
* *************************************************** END   Note 328675