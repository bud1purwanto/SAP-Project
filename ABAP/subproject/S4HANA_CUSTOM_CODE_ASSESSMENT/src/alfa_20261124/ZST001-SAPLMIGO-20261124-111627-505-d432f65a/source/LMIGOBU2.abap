*----------------------------------------------------------------------*
*   INCLUDE LMIGOBU2: Buffers for plant and storage location           *
*----------------------------------------------------------------------*
CLASS lcl_migo_buffer IMPLEMENTATION.

* Includes
  INCLUDE lmigobn1.                    "Names and phone of users
  INCLUDE lmigobu3.                "vendor/customer master, opt. arch.
  INCLUDE lmigobu5.                    "movement types buffers

************************************************************************
* Reads t001w and depending tables from database
************************************************************************
  METHOD plant_get_from_db.
    DATA: ls_t001w TYPE t001w,
          ls_t001  TYPE t001,                                    "211556
          ls_t159l TYPE t159l,
          ls_tqss1 TYPE tqss1,
          ls_t001k TYPE t001k,
*         Data which have plant priority and not company code priority
*         (note 435560). Needs to be reviewed whenever field is added to
*         structure GOPLANT which is in T001 and T001W together.
          l_land1  TYPE land1,                                   "435560
          ls_t001w_ext TYPE t001w_ext,                           "sdp462
          l_own_ls     TYPE own_ls.                              "sdp462

    CALL FUNCTION 'AIP01_PLANT_DETERMINE'                        "sdp462
      EXPORTING                                                  "sdp462
        i_werks                         = i_plant                "sdp462
      IMPORTING                                                  "sdp462
        e_ownls                         = l_own_ls               "sdp462
        es_t001w_ext                    = ls_t001w_ext           "sdp462
        es_t001w                        = ls_t001w               "sdp462
      EXCEPTIONS                                                 "sdp462
        OTHERS                          = 1.                     "sdp462
    IF sy-subrc <> 0.
      MESSAGE e004(mick) WITH i_plant
                         RAISING not_found.
    ENDIF.
*   Fill LS_T001W in case of cross-system movement
    IF l_own_ls IS INITIAL.                                      "sdp462
      CLEAR ls_t001w.                                            "sdp462
      MOVE-CORRESPONDING ls_t001w_ext TO ls_t001w.               "sdp462
    ENDIF.                                                       "sdp462
*   Fill GOPLANT
    MOVE-CORRESPONDING ls_t001w TO e_goplant.
    SELECT SINGLE * FROM t159l INTO ls_t159l WHERE werks = i_plant.
    IF sy-subrc <> 0.
      CLEAR ls_t159l.
    ENDIF.
    MOVE-CORRESPONDING ls_t159l TO e_goplant.
    SELECT SINGLE * FROM tqss1 INTO ls_tqss1 WHERE werks = i_plant.
    IF sy-subrc <> 0.
      CLEAR ls_tqss1.
    ENDIF.
    MOVE-CORRESPONDING ls_tqss1 TO e_goplant.
    SELECT SINGLE * FROM t001k INTO ls_t001k
                               WHERE bwkey = ls_t001w-bwkey.
*   Data from T001W_EXT --> BWKEY not there, but no error.
    IF sy-subrc <> 0 AND NOT l_own_ls IS INITIAL.                "sdp462
      MESSAGE e005(mick) WITH ls_t001w-bwkey
                         RAISING val_area_not_found.
    ENDIF.
*   Company code from T001W_EXT
    IF l_own_ls IS INITIAL.                                      "sdp462
      ls_t001k-bukrs = ls_t001w_ext-bukrs.                       "sdp462
    ENDIF.                                                       "sdp462
    MOVE-CORRESPONDING ls_t001k TO e_goplant.
    e_goplant-bukrs_for_stock = ls_t001k-bukrs.
    CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
         EXPORTING
              bukrs                = ls_t001k-bukrs
              component            = 'BR'
         EXCEPTIONS
              component_not_active = 1
              OTHERS               = 2.
    IF sy-subrc = 0.
      e_goplant-brazil = x.
    ENDIF.

*   save data with priority from plant
    l_land1 = e_goplant-land1.                                   "435560

    SELECT SINGLE * FROM t001 INTO ls_t001                       "211556
                              WHERE bukrs = ls_t001k-bukrs.      "211556
    IF sy-subrc <> 0.                                            "211556
      CLEAR ls_t001.                                             "211556
    ENDIF.                                                       "211556
    MOVE-CORRESPONDING ls_t001 TO e_goplant.                     "211556

*   reset saved plant data in e_goplant
    e_goplant-land1 = l_land1.                                   "435560


  ENDMETHOD.

************************************************************************
* Reads goplant data from buffer or db (METHOD plant_get_from_db) and
* updates buffer if necessary
************************************************************************
  METHOD plant_get.
    DATA: ls_buffer TYPE pty_plant_buffer.
* look for plant data in the buffer table
    READ TABLE pt_plant_buffer INTO ls_buffer
                               WITH TABLE KEY werks = i_plant
                               TRANSPORTING plant_data.
    IF sy-subrc = 0.
      e_goplant = ls_buffer-plant_data.
      EXIT.
    ENDIF.
*   read plant data from data base
    CLEAR e_goplant.
    CALL METHOD plant_get_from_db
         EXPORTING
           i_plant = i_plant
         IMPORTING
           e_goplant = e_goplant
         EXCEPTIONS
           not_found          = 1
           val_area_not_found = 2.
    CASE sy-subrc.
      WHEN 0.
*   store result
        ls_buffer-werks = i_plant.
        ls_buffer-plant_data  = e_goplant.
        INSERT ls_buffer INTO TABLE pt_plant_buffer.
      WHEN 1.
        MESSAGE e004(mick) WITH i_plant
                           RAISING not_found.
      WHEN 2.
        MESSAGE e005(mick) WITH sy-msgv1
                           RAISING val_area_not_found.
    ENDCASE.
  ENDMETHOD.

************************************************************************
* Plant name only
************************************************************************
  METHOD plant_name_get.
    DATA: ls_goplant TYPE goplant.
    CHECK NOT i_werks IS INITIAL.
    CLEAR r_name1.
    CALL METHOD plant_get
      EXPORTING
        i_plant = i_werks
      RECEIVING
        e_goplant = ls_goplant
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc = 0.
      r_name1 = ls_goplant-name1.
    ENDIF.
  ENDMETHOD.
************************************************************************
* Reads got001l data from buffer or t001l and updates buffer
* if necessary
************************************************************************
  METHOD storage_loc_get.
    DATA: ls_buffer TYPE pty_storage_loc_buffer,
          ls_t001l TYPE t001l.
    CHECK NOT i_storage_loc IS INITIAL.
* look for storage loc. data in the buffer table
    READ TABLE pt_storage_loc_buffer INTO ls_buffer
                                     WITH TABLE KEY plant  = i_plant
                                                 st_loc = i_storage_loc
                                     TRANSPORTING   storage_loc_data.
    IF sy-subrc = 0.
      e_storage_loc = ls_buffer-storage_loc_data.
      EXIT.
    ENDIF.
*  read storage loction data from data base
    CLEAR e_storage_loc.
    SELECT SINGLE * FROM t001l INTO ls_t001l
                    WHERE werks = i_plant
                    AND   lgort = i_storage_loc.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_t001l TO e_storage_loc.
      ls_buffer-plant = i_plant.
      ls_buffer-st_loc = i_storage_loc.
      ls_buffer-storage_loc_data  = e_storage_loc.
      INSERT ls_buffer INTO TABLE pt_storage_loc_buffer.
    ELSE.
      MESSAGE e010(migo) WITH i_storage_loc i_plant
                         RAISING not_found.
    ENDIF.
  ENDMETHOD.
************************************************************************
* Storage location name only
************************************************************************
  METHOD sloc_name_get.
    DATA: ls_got001l TYPE got001l.
    CLEAR r_lgobe.
    CALL METHOD storage_loc_get
      EXPORTING
        i_plant = i_werks
        i_storage_loc  = i_lgort
      RECEIVING
        e_storage_loc = ls_got001l
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc = 0.
      r_lgobe = ls_got001l-lgobe.
    ENDIF.
  ENDMETHOD.


ENDCLASS.