*----------------------------------------------------------------------*
* Report   ZHUI_PACKINST_LIST                                          *
* ~~~~~~~~~~~~~~                                                       *
*                                                                      *
* Description: Manage Packing List                                     *
*                                                                      *
* Specification - MM                                                   *
* Abaper        - Bagus Aditya Putra a.k.a BAP                         *
*----------------------------------------------------------------------*
* Amendment History                                                    *
* ~~~~~~~~~~~~~~~~~                                                    *
* Ref | Date     | Abaper      | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~   ~~~~~~~~~~~               *
*----------------------------------------------------------------------*

INCLUDE ZHUI_PACKINST_LIST_TOP .


 INCLUDE ZHU_PACKINST_LIST_O01                   .  " PBO-Modules     *
* INCLUDE ZHU_PACKINST_LIST_I01                   .  " PAI-Modules     *
INCLUDE ZHUI_PACKINST_LIST_F01                   .  " FORM-Routines   *

"-------------------------- ADD NEW COMPANY

AT SELECTION-SCREEN OUTPUT.

  IF TCODE EQ 'ZHU4FS'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'S_VBELN-LOW'.
        SCREEN-REQUIRED = '0'.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'S_WERKS-LOW'.
        SCREEN-REQUIRED = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ELSEIF TCODE EQ 'ZHU4SO'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'S_VBELN-LOW'.
        SCREEN-REQUIRED = '1'.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME = 'S_WERKS-LOW'.
        SCREEN-REQUIRED = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  "-------------------------- END NEW COMPANY

START-OF-SELECTION.
  "-------------------------- ADD NEW COMPANY
  IF FLAG_OBLI EQ '1'.
    PERFORM CHECK_PLANT.
  ELSEIF FLAG_OBLI EQ '2'.
    PERFORM CHECK_SO.
  ENDIF.
  "-------------------------- END NEW COMPANY
  PERFORM F_PROCESS_REPORT.

END-OF-SELECTION.
  IF ITAB_OUTPUT[] IS NOT INITIAL.
    PERFORM F_WRITE_DATA.

  ELSE.
    MESSAGE S000(0K) WITH 'Request returns zero result.'.

  ENDIF.