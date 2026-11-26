*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TVKGR_SELECT                                      *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM TVKGR_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsabteilung lesen                                       *
*---------------------------------------------------------------------*
FORM tvkgr_select USING ts_vkgrp LIKE tvkgr-vkgrp
                        ts_error TYPE c
                        ts_subrc LIKE sy-subrc.

  ts_subrc = 0.
  CHECK: ts_vkgrp NE tvkgr-vkgrp.

  IF ts_vkgrp EQ space.
    CLEAR: tvkgr.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM tvkgr WHERE vkgrp EQ ts_vkgrp.
  IF sy-subrc NE 0.
    CLEAR tvkgr.
    IF ts_error NE space.
      MESSAGE e317 WITH ts_vkgrp.
    ELSE.
      ts_subrc = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "TVKGR_SELECT
*eject