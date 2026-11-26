*----------------------------------------------------------------------*
*   INCLUDE LMIGOKT3                                                   *
*   Transportidentification
*----------------------------------------------------------------------*

METHOD transportident_read.

  DATA: ls_vmvmb TYPE shp_view_trai,                        "470
        lt_vmvmb TYPE TABLE OF shp_view_trai.

  SELECT * FROM shp_view_trai INTO TABLE lt_vmvmb
           WHERE traid = i_transportident.

  IF NOT i_transport_means IS INITIAL.
    DELETE lt_vmvmb WHERE traty <> i_transport_means.
  ENDIF.

  LOOP AT lt_vmvmb INTO ls_vmvmb.
    CALL METHOD confirmation_get
      EXPORTING i_vbeln = ls_vmvmb-vbeln.
  ENDLOOP.

ENDMETHOD.