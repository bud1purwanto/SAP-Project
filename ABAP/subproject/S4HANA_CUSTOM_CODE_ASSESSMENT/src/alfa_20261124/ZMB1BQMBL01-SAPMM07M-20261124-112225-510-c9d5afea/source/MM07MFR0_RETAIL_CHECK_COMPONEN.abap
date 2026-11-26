*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_CHECK_COMPONEN                   *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  RETAIL_STRUCT_CHECK_COMPONENTS
*----------------------------------------------------------------------*
*  all components have to be found and they have to be bound to the
*  original header of IT_XYMSEG loop above
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_CHECK_COMPONENTS USING WA_RSTRUCT  TYPE T_RSTRUCT
                                          KZ_YMSEG    TYPE C
                                          HEADER      LIKE MSEG-ZEILE
                                          ARTICLE     LIKE MSEG-MATNR
                                          LINE        LIKE MSEG-ZEILE
                                          LINE_XYMSEG LIKE SY-TABIX
                                                               "391224
                                          HEAD_ERFMG  LIKE MSEG-ERFMG
                                          XAUTO_COMP  LIKE MSEG-XAUTO.
   DATA: WA_COMP_RSTRUCT TYPE T_RSTRUCT.
   DATA: WA_XYMSEG TYPE T_XYMSEG.
   DATA: COMPONENTS_FOUND TYPE C.                             " 378908
   DATA: SY-TABIX-TMP LIKE SY-TABIX.                          " 378908

   LOOP AT IT_RSTRUCT INTO WA_COMP_RSTRUCT
                   WHERE MATNRVOR = WA_RSTRUCT-MATNR
                     AND BSTMEVOR = WA_RSTRUCT-BSTME
                     AND ERFMEVOR = WA_RSTRUCT-ERFME.
*     READ TABLE IT_XYMSEG INTO WA_XYMSEG                     " 378908
*          WITH KEY MATNR = WA_COMP_RSTRUCT-MATNR             " 378908
*                   BSTME = WA_COMP_RSTRUCT-BSTME             " 378908
*                   ERFME = WA_COMP_RSTRUCT-ERFME             " 378908
*                   URZEI = HEADER                            " 378908
*                   XAUTO = XAUTO_COMP.                       " 378908
*     IF  SY-SUBRC IS INITIAL.                                " 378908

*                           * Searching for expected line is  " 378908
*                           * ok, if found and xauto has      " 378908
*                           * the expected value; in the case " 378908
*                           * of xauto = L for empties, values" 378908
*                           * like W,M,F for valued articles  " 378908
*                           * are also acceptable             " 378908
*                           * Because of further extentions to" 378908
*                           * transfer postings, searching has" 378908
*                           * to be done by LOOP and not by   " 378908
*                           * READ;                           " 378908
      SY-TABIX-TMP = SY-TABIX.                                " 378908
      CLEAR COMPONENTS_FOUND.                                 " 378908
      LOOP AT IT_XYMSEG INTO WA_XYMSEG                        " 378908
              WHERE MATNR = WA_COMP_RSTRUCT-MATNR             " 378908
                AND BSTME = WA_COMP_RSTRUCT-BSTME             " 378908
                AND ERFME = WA_COMP_RSTRUCT-ERFME             " 378908
                AND URZEI = HEADER.                           " 378908
         IF WA_XYMSEG-XAUTO = XAUTO_COMP.                     " 378908
            COMPONENTS_FOUND = X.                             " 378908
            SY-TABIX-TMP = SY-TABIX.                          " 378908
            EXIT.                                             " 378908
         ELSE.                                                " 378908
            IF XAUTO_COMP = L.                                " 378908
*                           * not found but should be L       " 378908
               IF    WA_XYMSEG-XAUTO = W                      " 378908
                  OR WA_XYMSEG-XAUTO = M                      " 378908
                  OR WA_XYMSEG-XAUTO = F.                     " 378908
                   COMPONENTS_FOUND = X.                      " 378908
                   SY-TABIX-TMP = SY-TABIX.                   " 378908
                   EXIT.                                      " 378908
               ENDIF.                                         " 378908
            ENDIF.                                            " 378908
         ENDIF.                                               " 378908
      ENDLOOP. "IT_XYMSEG                                     " 378908
      SY-TABIX = SY-TABIX-TMP.                                " 378908

      IF  COMPONENTS_FOUND = X.                               " 378908
                                                         "begin 391224
*        IF WA_XYMSEG-ERFMG IS INITIAL AND NOT WA_XYMSEG-KZOK = F
         IF ( WA_XYMSEG-ERFMG IS INITIAL OR HEAD_ERFMG IS INITIAL )
            AND NOT WA_XYMSEG-ERFMG = HEAD_ERFMG
            AND NOT WA_XYMSEG-KZOK = F
                                                         "end   391224
            AND NOT XAUTO_COMP = SPACE.
*                           * korrelierte Mengen muessen jetzt alle
*                           * ungleich 0 sein; außer bei Sammelartikel
           PERFORM RETAIL_STRUCT_MESSAGE_BOX USING LINE_XYMSEG
                                                   HEADER
                                                   ARTICLE
                                                   LINE
                                                   XAUTO_COMP
                                                   KZ_YMSEG.
         ELSE.
*                            * member of RSTRUCT found -> ok
           IF NOT WA_XYMSEG-KZOK = F.                          " 391224
              WA_XYMSEG-KZOK = X.
              MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
           ENDIF.                                              " 391224
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
   ENDLOOP. "RSTRUCT
ENDFORM.                   " RETAIL_STRUCT_CHECK_COMPONENTS
* *************************************************** END   Note 328675