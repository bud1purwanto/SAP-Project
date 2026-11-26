*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BESTELLUNG_SPERREN                                *
*----------------------------------------------------------------------*

FORM bestellung_sperren USING us_vbeln LIKE ekko-ebeln.

  DATA: lf_ordernumber(10) TYPE c,
        lf_user LIKE sy-uname.

  CHECK: t180-trtyp NE chara,
         NOT us_vbeln IS INITIAL.
*-split
  IF v50agl-split NE space.
    CHECK nicht_sperren NE 'Y'.
  ENDIF.
*-split
  CALL FUNCTION 'ENQUEUE_EMEKKOE'
    EXPORTING
      mandt          = sy-mandt
      ebeln          = us_vbeln
    EXCEPTIONS
      foreign_lock   = 2
      system_failure = 3.

  CASE sy-subrc.
    WHEN 2.
      WRITE us_vbeln TO lf_ordernumber NO-ZERO.
      WRITE sy-msgv1 TO lf_user.
      MESSAGE e247 WITH lf_ordernumber lf_user.
    WHEN 3.
      MESSAGE e047.
  ENDCASE.

ENDFORM.                    "BESTELLUNG_SPERREN