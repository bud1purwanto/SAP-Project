*&---------------------------------------------------------------------*
*&  Include           MM07MFR0_RETAIL_DEL                              *
*&---------------------------------------------------------------------*
* *************************************************** Begin Note 328675
*----------------------------------------------------------------------*
*       Form  RETAIL_STRUCT_DEL
*----------------------------------------------------------------------*
*  fault in structure, so strike out the whole strucure with ERFMG = 0,
*  IT_XYMSEG-KZOK  = F, YMSEG-XAUTO = D
*  Data structures in actual version are IT_XYMSEG, YMSEG
*----------------------------------------------------------------------*
FORM RETAIL_STRUCT_DEL USING LINE_XYMSEG LIKE SY-TABIX
                                XAUTO_COMP  LIKE MSEG-XAUTO
                                KZ_YMSEG    TYPE C.
   DATA: WA_XYMSEG TYPE T_XYMSEG.
   DATA: HEADER    LIKE MSEG-ZEILE.
*                                                   " begin note 356129
   DATA: WA_RSTRUCT   TYPE T_RSTRUCT.
   DATA: HEADER_MATNR LIKE MSEG-MATNR.
   DATA: HEADER_BSTME LIKE MSEG-BSTME.
   DATA: HEADER_ERFME LIKE MSEG-ERFME.
   DATA: HEADER_XAUTO LIKE MSEG-XAUTO.
   DATA: AKT_XYMSEG   LIKE SY-TABIX.
*                                                   " end   note 356129

   READ TABLE IT_XYMSEG INTO WA_XYMSEG INDEX LINE_XYMSEG.
   IF  SY-SUBRC IS INITIAL.
*                           * first strike out line with fault
      WA_XYMSEG-ERFMG = 0.
      WA_XYMSEG-KZOK  = F.
      MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.

      PERFORM RETAIL_STRUCT_DEL_XYMSEG USING SY-TABIX
                                                KZ_YMSEG.

*                           * then strike out the whole structure
      IF WA_XYMSEG-URZEI IS INITIAL.
*                           * fault in header; header is cleaned
*                           * ... and all positions ... if any
         HEADER = WA_XYMSEG-ZEILE.
*                                                   " begin note 356129
*                           * loop at positions
*        LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER
*                                           AND XAUTO = XAUTO_COMP.
*           WA_XYMSEG-ERFMG = 0.
*           WA_XYMSEG-KZOK  = F.
*           MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
*
*           PERFORM RETAIL_STRUCT_DEL_XYMSEG USING SY-TABIX
*                                                     KZ_YMSEG.
*        ENDLOOP.
*     ELSE.
*                           * fault in position
*                           * -> find header
*        HEADER = WA_XYMSEG-URZEI.
*        READ TABLE IT_XYMSEG INTO WA_XYMSEG WITH KEY ZEILE = HEADER
*                                                     XAUTO = SPACE.
*        IF  SY-SUBRC IS INITIAL.
*                           * first strike out header
*           WA_XYMSEG-ERFMG = 0.
*           WA_XYMSEG-KZOK  = F.
*           MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
*
*           PERFORM RETAIL_STRUCT_DEL_XYMSEG USING SY-TABIX
*                                                     KZ_YMSEG.
*                           * loop at positions
*           LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER
*                                              AND XAUTO = XAUTO_COMP.
*              WA_XYMSEG-ERFMG = 0.
*              WA_XYMSEG-KZOK  = F.
*              MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.
*
*              PERFORM RETAIL_STRUCT_DEL_XYMSEG USING SY-TABIX
*                                                        KZ_YMSEG.
*           ENDLOOP.
*        ENDIF.
         HEADER_MATNR = WA_XYMSEG-MATNR.
         HEADER_BSTME = WA_XYMSEG-BSTME.
         HEADER_ERFME = WA_XYMSEG-ERFME.
         HEADER_XAUTO = XAUTO_COMP.
*                           * loop at positions
*                                                          begin 391224
*        LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER
*                                           AND XAUTO = XAUTO_COMP.
         LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER.
*                                                          end   391224
*                           * founded component can be deleted if it
*                           * could be found in the list of components
*                           * of the actual header
            READ TABLE IT_RSTRUCT INTO WA_RSTRUCT
                 WITH KEY MATNRVOR = HEADER_MATNR
                          BSTMEVOR = HEADER_BSTME
*                                                          begin 391224
*                         ERFMEVOR = HEADER_ERFME
*                         XAUTO = HEADER_XAUTO.
                          ERFMEVOR = HEADER_ERFME.
*                                                          end   391224
            IF SY-SUBRC IS INITIAL.
               WA_XYMSEG-ERFMG = 0.
               WA_XYMSEG-KZOK  = F.
               MODIFY IT_XYMSEG INDEX SY-TABIX FROM WA_XYMSEG.

               PERFORM RETAIL_STRUCT_DEL_XYMSEG USING SY-TABIX
                                                      KZ_YMSEG.
            ENDIF.
         ENDLOOP.
      ELSE.
*                           * fault in position
*                           * -> find header
         HEADER = WA_XYMSEG-URZEI.
         READ TABLE IT_XYMSEG INTO WA_XYMSEG WITH KEY ZEILE = HEADER
                                                      XAUTO = SPACE.
         IF  SY-SUBRC IS INITIAL.
            AKT_XYMSEG   = SY-TABIX.
            HEADER_MATNR = WA_XYMSEG-MATNR.
            HEADER_BSTME = WA_XYMSEG-BSTME.
            HEADER_ERFME = WA_XYMSEG-ERFME.
            HEADER_XAUTO = XAUTO_COMP.
*                           * first strike out header:
*                           * founded header can be deleted if it
*                           * could be found in the list of structures
            READ TABLE IT_RSTRUCT INTO WA_RSTRUCT
                 WITH KEY MATNR = HEADER_MATNR
                          BSTME = HEADER_BSTME
                          ERFME = HEADER_ERFME
                          XAUTO = SPACE
                          UPTYP = SPACE.
            IF SY-SUBRC IS INITIAL.
               WA_XYMSEG-ERFMG = 0.
               WA_XYMSEG-KZOK  = F.
               MODIFY IT_XYMSEG INDEX AKT_XYMSEG FROM WA_XYMSEG.

               PERFORM RETAIL_STRUCT_DEL_XYMSEG USING AKT_XYMSEG
                                                      KZ_YMSEG.
            ENDIF.
*                           * loop at positions
*                                                          begin 391224
*           LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER
*                                              AND XAUTO = XAUTO_COMP.
            LOOP AT IT_XYMSEG INTO WA_XYMSEG WHERE URZEI = HEADER.
*                                                          end   391224
*                           * founded component can be deleted if it
*                           * could be found in the list of components
*                           * of the actual header
               AKT_XYMSEG   = SY-TABIX.
               READ TABLE IT_RSTRUCT INTO WA_RSTRUCT
                    WITH KEY MATNRVOR = HEADER_MATNR
                             BSTMEVOR = HEADER_BSTME
*                                                          begin 391224
*                            ERFMEVOR = HEADER_ERFME
*                            XAUTO = HEADER_XAUTO.
                             ERFMEVOR = HEADER_ERFME.
*                                                          end   391224
               IF SY-SUBRC IS INITIAL.
                  WA_XYMSEG-ERFMG = 0.
                  WA_XYMSEG-KZOK  = F.
                  MODIFY IT_XYMSEG INDEX AKT_XYMSEG FROM WA_XYMSEG.

                  PERFORM RETAIL_STRUCT_DEL_XYMSEG USING AKT_XYMSEG
                                                         KZ_YMSEG.
               ENDIF.
            ENDLOOP.
         ENDIF.
*                                                   " end  note 356129
      ENDIF.
   ELSE.
      MESSAGE E001 WITH 'IT_XYMSEG' HEADER.
   ENDIF.
ENDFORM.
* *************************************************** END   Note 328675