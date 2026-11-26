*----------------------------------------------------------------------*
* Form ZSDF_FAKTUR_PAJAK
* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
* Description      : Faktur Pajak (Tax Invoice)
*
* Application Area - SD
* ABAPer           - Fina Oktavia Manurung
* Date             - November 20, 2012
*----------------------------------------------------------------------*
* Amendment History
* ~~~~~~~~~~~~~~~~~
* Ref | Date     | Programmer  | Correction | Description
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~
*
*----------------------------------------------------------------------*


INCLUDE ZSDF_FAKTUR_PAJAK_TOP.
INCLUDE ZABAPALV.
INCLUDE ZSDF_FAKTUR_PAJAK_F01.

INITIALIZATION.
  CLEAR SMP_DYNTXT.
  SMP_DYNTXT-ICON_ID    = '@GX@'.
  SMP_DYNTXT-ICON_TEXT  = 'Maintain KMK'.
  SMP_DYNTXT-QUICKINFO  = 'Maintain KMK'.
  SSCRFIELDS-FUNCTXT_01 = SMP_DYNTXT.

TOP-OF-PAGE.
  PERFORM HEADER_DATA.

TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM HEADER_DATA.

AT USER-COMMAND.
  PERFORM USER_COMMAND USING SY-UCOMM RS_SELFIELD.

START-OF-SELECTION.
  SELECT VKORG FROM TVKO INTO TABLE IT_TVKO WHERE VKORG IN SO_VKORG.

  LOOP AT IT_TVKO.
    AUTHORITY-CHECK OBJECT 'V_VBAK_VKO' ID 'VKORG' FIELD IT_TVKO-VKORG.
    IF SY-SUBRC NE 0.
      MESSAGE 'No Authorization to process data' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDLOOP.

  PERFORM DATA_RETRIEVAL.

  IF P_MODE1 = 'X'.
    PERFORM DATA_DISPLAY USING ''.
  ELSEIF P_MODE2 = 'X'.
    PERFORM DOWNLOAD_DATA.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF P_MODE2 = 'X'.
    LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'CON'.
            SCREEN-ACTIVE = 1.
            SCREEN-INPUT = 1.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'CON'.
            SCREEN-ACTIVE = 0.
            SCREEN-INPUT = 0.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'Z_OLAP' ID 'ZOLAP' FIELD '01'.
  IF SY-SUBRC EQ 0.
    LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'MOD'.
            SCREEN-ACTIVE = 1.
            SCREEN-INPUT = 1.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
        IF SCREEN-GROUP1 = 'MOD'.
            SCREEN-ACTIVE = 0.
            SCREEN-INPUT = 0.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
        ENDIF.
    ENDLOOP.
  ENDIF.


AT SELECTION-SCREEN.
  IF SO_VKORG[] IS INITIAL.
    MESSAGE 'Sales Organization. is required !!' TYPE 'E'.
  ENDIF.

  CASE SY-UCOMM.
    WHEN 'FC01'.
      CALL TRANSACTION 'ZZKMK'.
*      PERFORM GET_ZKMK.
*      PERFORM CALL_SCREENKMK.
  ENDCASE.