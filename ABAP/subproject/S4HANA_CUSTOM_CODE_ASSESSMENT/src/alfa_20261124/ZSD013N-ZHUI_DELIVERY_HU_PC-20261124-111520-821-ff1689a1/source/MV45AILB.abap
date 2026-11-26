***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung                                *
*
*  PAI-Module für Lieferabrufe                                        *
*                                                                     *
***********************************************************************

  INCLUDE MV45AILB_VBLB_BEARBEITEN .
  INCLUDE MV45AILB_VBLB_FUELLEN .
  INCLUDE MV45AILB_XVBLB_LESEN .

*&---------------------------------------------------------------------*
*&      Module  horizont_pruefen  INPUT
*&---------------------------------------------------------------------*
*       Checks wether the entered date is not less then 1902,
*       this will be also checked later in JIT processing, but
*       errorhandling is easier here.
*----------------------------------------------------------------------*
  MODULE horizont_pruefen INPUT.

    DATA: s_absolut_date        TYPE p.

    constants: min_year  TYPE p VALUE  '694327',  "1902
               max_abhor TYPE p VALUE  '766277',  "28.12.2098
               valid_fe  TYPE p VALUE '3652060'.  "31.12.9999

    CHECK NOT rv45z-abhor IS INITIAL.

    IF vblb-abart EQ ABART_FAB.
      s_absolut_date = rv45z-abhor.
* Older than 1902 is not possible
* After 28th of Dec. 2098 is not possible, except 99991231
      IF s_absolut_date lt min_year OR
         s_absolut_date gt max_abhor AND
         s_absolut_date ne valid_fe.
        MESSAGE ID '00' TYPE 'E' NUMBER '064'.
      ENDIF.
* validation of JIT horizon
      IF rv45z-abhor LT vblb-abrdt.
        PERFORM message_variabel(sapfv45l) USING 'V4'
                                                 '337'
                                                 rv45z-msgvs
                                                 space
                                                 rv45z-abhor
                                                 vblb-abrdt
                                                 space
                                                 space.
      ENDIF.
    ENDIF.

  ENDMODULE.                           " horizont_pruefen  INPUT