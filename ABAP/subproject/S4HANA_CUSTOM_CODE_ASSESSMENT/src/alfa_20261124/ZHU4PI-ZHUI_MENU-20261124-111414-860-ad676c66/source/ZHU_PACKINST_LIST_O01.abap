*&---------------------------------------------------------------------*
*&  Include           ZHU_PACKINST_LIST_O01
*&---------------------------------------------------------------------*

"-------------------------------------- START NEW COMPANY

GET PARAMETER ID 'TSOURCE' FIELD TCODE.

IF TCODE EQ 'ZHU4FS'.
   LOOP AT SCREEN.

    IF SCREEN-NAME = 'S_VBELN-LOW'.
      SCREEN-REQUIRED = '0'.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME = 'S_WERKS-LOW'.
      FLAG_OBLI = '1'.
      SCREEN-REQUIRED = '1'.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ELSEIF TCODE EQ 'ZHU4SO'.
  LOOP AT SCREEN.

    IF SCREEN-NAME = 'S_VBELN-LOW'.
      FLAG_OBLI = '2'.
      SCREEN-REQUIRED = '1'.
      MODIFY SCREEN.
    ENDIF.

    IF SCREEN-NAME = 'S_WERKS-LOW'.
      SCREEN-REQUIRED = '0'.
      MODIFY SCREEN.
    ENDIF.

  ENDLOOP.

ENDIF.

"--------------------------------------END NEW COMPANY