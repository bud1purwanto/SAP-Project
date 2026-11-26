*---------------------------------------------------------------------*
*       FORM FPLAN_MLSTN_AENDERN                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  US_AUFNR                                                      *
*---------------------------------------------------------------------*
FORM FPLAN_MLSTN_AENDERN USING US_AUFNR.

DATA: BEGIN OF TMSTSD  OCCURS 10.
  INCLUDE STRUCTURE MSTSD.
DATA: END   OF TMSTSD.

* Aufruf Ermitteln Meilensteine, Erzeugen Termine
  CALL FUNCTION 'CN_MS_GET_MLST_FOR_DATE'
       EXPORTING
            AUFNR_IMP    = US_AUFNR
            SDDAT_IMP    = '01'
       TABLES
            MSTSD_EXP    = TMSTSD
       EXCEPTIONS
            NOT_FOUND    = 01
            NO_MILESTONE = 02.
  IF SY-SUBRC = 0.
    PERFORM FAKTURIERUNGSPLAN_MEILENSTEINE(SAPFV45P) TABLES TMSTSD.
  ENDIF.
ENDFORM.