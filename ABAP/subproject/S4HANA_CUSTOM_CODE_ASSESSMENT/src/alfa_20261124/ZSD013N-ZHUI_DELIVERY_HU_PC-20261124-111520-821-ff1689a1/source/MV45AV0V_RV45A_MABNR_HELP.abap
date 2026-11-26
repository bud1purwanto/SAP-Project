*----------------------------------------------------------------------*
*   INCLUDE MV45AV0V_RV45A_MABNR_HELP                                  *
*----------------------------------------------------------------------*

MODULE RV45A_MABNR_HELP.

  DATA: DA_TITLE     LIKE DSYST-DOKTITLE,
        DA_PROGRAM   LIKE HELP_INFO-PROGRAM,
        DA_DYNPRO    LIKE HELP_INFO-DYNPRO,
        DA_DYNPROFLD LIKE HELP_INFO-DYNPROFLD,
        DA_BATCH     LIKE HELP_INFO-DYNPROFLD,
        DA_CUAPROG   LIKE HELP_INFO-PROGRAM,
        DA_CUASTATUS LIKE HELP_INFO-PFKEY,
        DA_LINKS     LIKE TLINE OCCURS 0.

  DA_TITLE     = SY-TITLE.
  DA_PROGRAM   = SY-REPID.
  DA_DYNPRO    = SY-DYNNR.
  DA_BATCH     = 'VBAP-MATNR'.
  GET PF-STATUS DA_CUASTATUS PROGRAM DA_CUAPROG.
  GET CURSOR FIELD DA_DYNPROFLD.




*--------------------------------------------------------------------*
* Material                                                           *
*--------------------------------------------------------------------*
  IF TVAK-ERMAT IS INITIAL  OR  TVAK-ERMAT  EQ  CHARB.

    CALL FUNCTION 'HELP_OBJECT_SHOW_FOR_FIELD'
         EXPORTING
             DOKLANGU                      = SY-LANGU
*         DOKTITLE                      = ' '
             CALLED_BY_TCODE               = SY-TCODE
*            CALLED_BY_PROGRAM             = SY-CPROG
             CALLED_BY_PROGRAM             = DA_PROGRAM
             CALLED_BY_DYNP                = DA_DYNPRO
             CALLED_FOR_TAB                = 'RV45A'
             CALLED_FOR_FIELD              = 'MABNR'
             CALLED_FOR_TAB_FLD_BTCH_INPUT = DA_BATCH
             CALLED_BY_CUAPROG             = DA_CUAPROG
             CALLED_BY_CUASTAT             = DA_CUASTATUS
             MERGE_DZ_IF_AVAILABLE         = 'X'
*         MEMORYID                      =
*         EXPLICIT_MEMORYID             = ' '
*    TABLES
*         LINKS                         =
*         EXCLUDEFUN                    =
*    EXCEPTIONS
*         OBJECT_NOT_FOUND              = 1
*         SAPSCRIPT_ERROR               = 2
*         OTHERS                        = 3
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.




  ENDIF.


*--------------------------------------------------------------------*
* Material(bestell)nummer                                            *
*--------------------------------------------------------------------*
  IF TVAK-ERMAT EQ CHARA.

    CALL FUNCTION 'HELP_OBJECT_SHOW'
         EXPORTING
           DOKCLASS                      = 'TX'
           DOKLANGU                      = SY-LANGU
           DOKNAME                       = 'RV45A_MABNR_MATERIALBESTNR'
           DOKTITLE                      = TEXT-300
           CALLED_BY_PROGRAM             = DA_PROGRAM
           CALLED_BY_DYNP                = DA_DYNPRO
           CALLED_FOR_TAB                = 'RV45A'
           CALLED_FOR_FIELD              = 'MABNR'
           CALLED_FOR_TAB_FLD_BTCH_INPUT = DA_BATCH
*          MSG_VAR_1                     = ' '
*          MSG_VAR_2                     = ' '
*          MSG_VAR_3                     = ' '
*          MSG_VAR_4                     = ' '
           CALLED_BY_CUAPROG             = DA_CUAPROG
           CALLED_BY_CUASTAT             = DA_CUASTATUS
*          SHORT_TEXT                    = ' '
        TABLES
           LINKS                         = DA_LINKS
*      EXCEPTIONS
*           OBJECT_NOT_FOUND              = 1
*           SAPSCRIPT_ERROR               = 2
*           OTHERS                        = 3
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.


  ENDIF.

ENDMODULE.