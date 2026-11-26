*----------------------------------------------------------------------*
*   INCLUDE RKRFCGROUPINC_PARAMS                                       *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK _rfcgroup.
SELECTION-SCREEN   BEGIN OF LINE.
PARAMETERS:  rfcproc TYPE co_para_processing  AS CHECKBOX
                     USER-COMMAND rfcproc.
SELECTION-SCREEN     COMMENT 3(28) rfcproct FOR FIELD rfcproc.
SELECTION-SCREEN POSITION pos_low.
SELECTION-SCREEN   PUSHBUTTON (40) rfcpbt1
                                   USER-COMMAND rfcpbt1.
*SELECTION-SCREEN     COMMENT 75(10) rfcmt.
SELECTION-SCREEN   END OF LINE.
SELECTION-SCREEN   BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(28) rfcgrt FOR FIELD rfcgroup.
SELECTION-SCREEN POSITION pos_low.
PARAMETERS:  rfcgroup TYPE spta_rfcgr.
SELECTION-SCREEN   END OF LINE.
SELECTION-SCREEN END OF BLOCK _rfcgroup.