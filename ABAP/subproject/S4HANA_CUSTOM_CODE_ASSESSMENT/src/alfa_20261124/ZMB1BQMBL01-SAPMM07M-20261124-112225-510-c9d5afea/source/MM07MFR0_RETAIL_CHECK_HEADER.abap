*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_CHECK_HEADER                     *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  RETAIL_STRUCT_CHECK_HEADER
*----------------------------------------------------------------------*
*  first, for the actual component the header must be found; after this
*  all components have to be found and they must to be bounded to the
*  there header (ZEILE = HEADER)
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_CHECK_HEADER USING WA_RSTRUCT  TYPE T_RSTRUCT
                                      KZ_YMSEG    TYPE C
                                      HEADER      LIKE MSEG-ZEILE
                                      ARTICLE     LIKE MSEG-MATNR
                                      LINE        LIKE MSEG-ZEILE
                                      LINE_XYMSEG LIKE SY-TABIX
                                      XAUTO_COMP  LIKE MSEG-XAUTO.
   DATA: WA_HEAD_RSTRUCT TYPE T_RSTRUCT.
   DATA: WA_XYMSEG TYPE T_XYMSEG.

   READ TABLE IT_RSTRUCT INTO WA_HEAD_RSTRUCT
        WITH KEY MATNR = WA_RSTRUCT-MATNRVOR
                 BSTME = WA_RSTRUCT-BSTMEVOR
                 ERFME = WA_RSTRUCT-ERFMEVOR.
   IF  SY-SUBRC IS INITIAL.
*                            * verify full item  RSTRUCT->XMSEG
*                            * Attention: must be the header
*                            * attached to the original component
      READ TABLE IT_XYMSEG INTO WA_XYMSEG
           WITH KEY MATNR = WA_HEAD_RSTRUCT-MATNR
                    BSTME = WA_HEAD_RSTRUCT-BSTME
                    ERFME = WA_HEAD_RSTRUCT-ERFME
                    ZEILE = HEADER.
      IF  SY-SUBRC IS INITIAL.
         IF WA_XYMSEG-ERFMG IS INITIAL AND NOT WA_XYMSEG-KZOK = F
            AND WA_HEAD_RSTRUCT-UPVOR = UPTYP_VAR.
*                           * korrelierte Mengen muessen jetzt alle
*                           * ungleich 0 sein; außer bei Sammelartikel
            PERFORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG
                                                    HEADER
                                                    ARTICLE
                                                    LINE
                                                    XAUTO_COMP
                                                    KZ_YMSEG.
         ELSE.
            WA_XYMSEG-KZOK = X.
            MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
         ENDIF.
*                            * all components have to be found
         WA_RSTRUCT = WA_HEAD_RSTRUCT.
         HEADER = WA_XYMSEG-ZEILE.
         PERFORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT
                                                      KZ_YMSEG
                                                      HEADER
                                                      ARTICLE
                                                      LINE
                                                      LINE_XYMSEG
                                                               "391224
                                                      WA_XYMSEG-ERFMG
                                                      XAUTO_COMP.
      ELSE.
         IF NOT XAUTO_COMP  = SPACE.
*                           * Message for none-generic articles
           PERFORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG
                                                   HEADER
                                                   ARTICLE
                                                   LINE
                                                   XAUTO_COMP
                                                   KZ_YMSEG.
         ENDIF.
      ENDIF.
   ELSE.
      IF NOT XAUTO_COMP  = SPACE.
        PERFORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG
                                                HEADER
                                                ARTICLE
                                                LINE
                                                XAUTO_COMP
                                                KZ_YMSEG.
      ENDIF.
   ENDIF.
ENDFORM.                   " RETAIL_STRUCT_CHECK_HEADER
* *************************************************** END   Note 328675