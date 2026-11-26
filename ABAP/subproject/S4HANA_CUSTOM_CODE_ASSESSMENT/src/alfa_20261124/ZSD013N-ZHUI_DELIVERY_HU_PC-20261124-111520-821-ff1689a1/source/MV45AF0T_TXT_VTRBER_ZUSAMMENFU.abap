*&---------------------------------------------------------------------*
*&      Form  TXT_VTRBER_ZUSAMMENFUEGEN
*&---------------------------------------------------------------------*
*       Zusammenfuegen des Vertriebsbereichstext aus dem
*       Verkaufsorganisationstext, dem Vertriebsweg-Text
*       und dem Spartentext (durch Kommata getrennt)
*----------------------------------------------------------------------*
FORM TXT_VTRBER_ZUSAMMENFUEGEN.

   DATA: STR_LEN(4)  TYPE N,
         STR_LEN2(4) TYPE N.

   CLEAR RV45A-TXT_VTRBER.
   RV45A-TXT_VTRBER = TVKOT-VTEXT.
   STR_LEN = STRLEN( RV45A-TXT_VTRBER ).
   STR_LEN2 = STRLEN( TVTWT-VTEXT ).
   IF STR_LEN  NE 0 AND
      STR_LEN2 NE 0.
     WRITE ',' TO RV45A-TXT_VTRBER+STR_LEN.
     STR_LEN = STR_LEN + 2.
   ENDIF.
   WRITE TVTWT-VTEXT TO RV45A-TXT_VTRBER+STR_LEN.

   STR_LEN = STRLEN( RV45A-TXT_VTRBER ).
   STR_LEN2 = STRLEN( TSPAT-VTEXT ).
   IF STR_LEN  NE 0 AND
      STR_LEN2 NE 0.
     WRITE ',' TO RV45A-TXT_VTRBER+STR_LEN.
     STR_LEN = STR_LEN + 2.
   ENDIF.
   WRITE TSPAT-VTEXT TO RV45A-TXT_VTRBER+STR_LEN.

ENDFORM.                    " TXT_VTRBER_ZUSAMMENFUEGEN