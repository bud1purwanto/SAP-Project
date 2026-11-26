*&---------------------------------------------------------------------*
*&  Include           MV45AI0A_ARCHIVE_SEARCH
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ARCHIVE_SEARCH  INPUT
*&---------------------------------------------------------------------*
* fcode 'ANZA' is needed for enabling an easy modification for customers
* who had to set back number ranges (which is not recommended to do)
* please see also corresponding modification note
*----------------------------------------------------------------------*
MODULE archive_search INPUT.

  IF fcode EQ 'ANZA'.
    gv_asuc = 'X'.
    LEAVE TO SCREEN 102.
  ELSEIF fcode EQ 'ANZE'.
    CLEAR gv_asuc.
    LEAVE TO SCREEN 102.
  ENDIF.

ENDMODULE.                 " ARCHIVE_SEARCH  INPUT