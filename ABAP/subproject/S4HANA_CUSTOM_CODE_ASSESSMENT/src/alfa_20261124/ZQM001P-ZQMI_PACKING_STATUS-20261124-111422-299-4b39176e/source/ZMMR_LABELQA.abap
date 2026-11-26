*&---------------------------------------------------------------------*
*& Report  ZMMR_LABELQA
*&---------------------------------------------------------------------*
*& Created by : Mualifi
*& Created on : 01-11-2012
*& Desc.      :
*&---------------------------------------------------------------------**--
REPORT  ZMMR_LABELQA NO STANDARD PAGE HEADING MESSAGE-ID pp.
TABLES: vekp.

DATA : BEGIN OF text_data OCCURS 0,
            str_text(255),
       END OF text_data.

DATA : BEGIN OF it_exidv OCCURS 0,
            exidv like vekp-exidv,
       END OF it_exidv.

data: v_exidv(10),
      v_nik(8).  " like zqm001-nik.

data:  file_d TYPE string VALUE 'C:\tslabel\DATA.DAX',
       v_returncode TYPE i,
       v_info_error(100) TYPE c.

SELECT-OPTIONS : p_exidv FOR vekp-exidv.
PARAMETER      : v_copies(3) DEFAULT 1.

START-OF-SELECTION.
  perform get_hu.

  loop at it_exidv.
    perform get_data.
    perform print.
  endloop.

end-of-selection.

form get_hu.
  select exidv into table it_exidv from vekp where exidv in p_exidv.
  if sy-subrc ne 0.
    leave program.
  endif.
endform.


form get_data.

  select single nik into v_nik from zqm001 where exidv = it_exidv-exidv.
  if sy-subrc ne 0.
    message 'NIK tidak di temukan didalam data QA.' type 'I'.
    Leave program.
  endif.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = it_exidv-exidv
    IMPORTING
      OUTPUT = v_exidv.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = v_nik
    IMPORTING
      OUTPUT = v_nik.

  REFRESH text_data.
  CLEAR text_data.

  text_data-str_text = '<STX><ESC>P;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>E1,41;A1,VBXOPP;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>L39;D0;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>B1,BARC  ;o178,611;f0;h90;w2;r0;i0;c0,0;d0,19;D39;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>H27,PALET ;o173,709;f0;h2;w3;c20;b0;d0,12;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>H40,USER;o741,731;f1;h1;w1;c20;b0;d0;10;<ETX>'.    Append text_data.
  text_data-str_text = '<STX>R<ETX>'.    Append text_data.
  text_data-str_text = '<STX><ESC>E1,1<CAN><ETX>'.    Append text_data.

  concatenate '<STX><ESC>F"BARC  "<LF>'  v_exidv '<ETX>' into text_data-str_text.    Append text_data.
  concatenate '<STX><ESC>F"PALET "<LF>' v_exidv '<ETX>' into text_data-str_text.    Append text_data.
  concatenate '<STX><ESC>F"USER  "<LF>' v_nik '<ETX>' into text_data-str_text.    Append text_data.

  text_data-str_text = '<STX><US>1<ETX>'.    Append text_data.
  text_data-str_text = '<STX><ETB><ETX>'.    Append text_data.
endform.


FORM print.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = file_d
      filetype                = 'ASC'
      write_field_separator   = 'X'
    TABLES
      data_tab                = text_data    " internal table containing data
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        v_info_error = 'file_write_error'.
      WHEN 2.
        v_info_error = 'no_batch'.
      WHEN 3.
        v_info_error = 'gui_refuse_filetransfer'.
      WHEN 4.
        v_info_error = 'invalid_type'.
      WHEN 5.
        v_info_error = 'no_authority'.
      WHEN 6.
        v_info_error = 'unknown_error'.
      WHEN 7.
        v_info_error = 'header_not_allowed'.
      WHEN 8.
        v_info_error = 'separator_not_allowed'.
      WHEN 9.
        v_info_error = 'filesize_not_allowed'.
      WHEN 10.
        v_info_error = 'header_too_long'.
      WHEN 11.
        v_info_error = 'dp_error_create'.
      WHEN 12.
        v_info_error = 'dp_error_send'.
      WHEN 13.
        v_info_error = 'dp_error_write'.
      WHEN 14.
        v_info_error = 'unknown_dp_error'.
      WHEN 15.
        v_info_error = 'access_denied'.
      WHEN 16.
        v_info_error = 'dp_out_of_memory'.
      WHEN 17.
        v_info_error = 'disk_full'.
      WHEN 18.
        v_info_error = 'dp_timeout'.
      WHEN 19.
        v_info_error = 'file_not_found'.
      WHEN 20.
        v_info_error = 'dataprovider_exception'.
      WHEN 21.
        v_info_error = 'control_flush_error'.
      WHEN 22.
        v_info_error = 'OTHERS'.
    ENDCASE.
    MESSAGE e000(0k) WITH 'Download data file error, cause : ' v_info_error.
  ENDIF.

  CALL FUNCTION 'GUI_RUN'
    EXPORTING
      command    = 'DATA.BAT'
      cd         = 'C:\tslabel'
    IMPORTING
      returncode = v_returncode.

  IF v_returncode <> 0.
    MESSAGE i000(0k) WITH 'Run Batch File Error'.
    STOP.
  ENDIF.
  wait UP TO 1 SECONDS.
ENDFORM.                    " print