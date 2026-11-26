FUNCTION ZCONVERSION_EXIT_CUNIT_INPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT)
*"     VALUE(LANGUAGE) LIKE  SY-LANGU DEFAULT SY-LANGU
*"  EXPORTING
*"     VALUE(OUTPUT)
*"     REFERENCE(MESSAGE) TYPE  CHAR100
*"  EXCEPTIONS
*"      UNIT_NOT_FOUND
*"----------------------------------------------------------------------

  DATA: lv_unit_found TYPE xfeld,
        lv_input TYPE mseh3,
        help(6).                              "*058i

* SPACE wird nicht umgesetzt
  IF INPUT EQ SPACE.
    OUTPUT = INPUT.
    EXIT.
  ENDIF.

  PERFORM conversion_exit_cunit_input                       "*058i+
          USING    input
                   language
          CHANGING output
                   lv_unit_found.
  IF lv_unit_found IS INITIAL.
* If the unit was not found this can be due to the
* fact that the letters that are maintained as capital
* letters were entered as lower case letters. In this case
* translate to upper case and repeat.
    lv_input = input.
*    PERFORM trans_latin_to_upper_case                      "*067d+
*            CHANGING lv_input.
    PERFORM trans_to_upper_case                             "*067i
            CHANGING lv_input.                              "*067i
    PERFORM conversion_exit_cunit_input
            USING    lv_input
                     language
            CHANGING output
                     lv_unit_found.
    IF lv_unit_found IS INITIAL.
    OUTPUT = INPUT.
    HELP = INPUT.     " falls an INPUT ein Konvertierungsexit haengt
*    MESSAGE E305 WITH HELP LANGUAGE RAISING UNIT_NOT_FOUND.
    CONCATENATE 'Unit ' HELP 'is not created in language' LANGUAGE INTO MESSAGE SEPARATED BY SPACE.
  ENDIF.
  ENDIF.                                                    "*058i-

*  IF g_buffer_new_version IS INITIAL.                      "*058d+
** alte Version
*    IF sw_use_buffer NE space
*    AND language EQ sy-langu
*    AND t006a_cnt EQ 0.
*      PERFORM fill_unit_buffer.
*    ENDIF.
*
*    IF sw_use_buffer EQ space
*    OR language NE sy-langu.
*      SELECT * FROM t006a UP TO 1 ROWS WHERE spras EQ language
*                          AND   mseh3 EQ input.
*        output = t006a-msehi.
*      ENDSELECT.
*    ELSE.
*      t006a_s_tab-mseh3 = input.
*      READ TABLE t006a_s_tab WITH KEY t006a_s_tab-mseh3 BINARY SEARCH.
*      output = t006a_s_tab-msehi.
*    ENDIF.
*    IF sy-subrc NE 0.
*      output = input.
*      help = input.     " falls an INPUT ein Konvertierungsexit haengt
*      MESSAGE e305 WITH help language RAISING unit_not_found.
*    ENDIF.
*  ELSE.
** ggf. selektive Pufferung
*    mseh3 = input.
*    PERFORM get_t006b USING    language mseh3
*                      CHANGING output l_return_code.
*    IF l_return_code <> 0.
*      output = input.
*      help = input.     " falls an INPUT ein Konvertierungsexit haengt
*      MESSAGE e305 WITH help language RAISING unit_not_found.
*    ENDIF.
*  ENDIF.                                                   "*058d-

ENDFUNCTION.