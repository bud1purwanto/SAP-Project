REPORT ztrain_idoc_out_mock.
TYPES: BEGIN OF ztrn_e1pohdr,
         ebeln(10) TYPE c, bsart(4) TYPE c, lifnr(10) TYPE c,
         bedat(8) TYPE c, waers(5) TYPE c,
       END OF ztrn_e1pohdr,
       BEGIN OF ztrn_e1poitm,
         ebelp(5) TYPE c, matnr(18) TYPE c, txz01(40) TYPE c,
         menge(17) TYPE c, meins(3) TYPE c, netwr(17) TYPE c,
       END OF ztrn_e1poitm.

* Latihan IDoc outbound: kirim 1 PO sebagai IDoc ZTRN_PO01 (message ZTRN_PO)
* Prasyarat: segmen ZTRN_E1POHDR/ZTRN_E1POITM (WE31), basic type ZTRN_PO01
* (WE30), message type ZTRN_PO (WE81/WE82), partner profile (WE20)

PARAMETERS: p_ebeln  TYPE ekko-ebeln OBLIGATORY,
            p_rcvprn TYPE edi_rcvprn OBLIGATORY DEFAULT 'ZTRNLS',
            p_rcvprt TYPE edi_rcvprt DEFAULT 'LS'.

DATA: gs_ekko    TYPE ekko,
      gt_ekpo    TYPE STANDARD TABLE OF ekpo,
      gs_ekpo    TYPE ekpo,
      gs_hdr     TYPE ztrn_e1pohdr,
      gs_itm     TYPE ztrn_e1poitm,
      gs_control TYPE edidc,
      gt_data    TYPE STANDARD TABLE OF edidd,
      gs_data    TYPE edidd,
      gt_comm    TYPE STANDARD TABLE OF edidc,
      gs_comm    TYPE edidc.

START-OF-SELECTION.
  SELECT SINGLE * FROM ekko INTO gs_ekko
    WHERE ebeln = p_ebeln AND bstyp = 'F'.
  IF sy-subrc <> 0.
    MESSAGE 'PO tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  SELECT * FROM ekpo INTO TABLE gt_ekpo
    WHERE ebeln = p_ebeln AND loekz = space.

* 1. Control record: siapa penerima, message type, basic type
  gs_control-mestyp = 'ZTRN_PO'.
  gs_control-idoctp = 'ZTRN_PO01'.
  gs_control-rcvprt = p_rcvprt.
  gs_control-rcvprn = p_rcvprn.

* 2. Data record: 1 segmen header + n segmen item
  gs_hdr-ebeln = gs_ekko-ebeln.
  gs_hdr-bsart = gs_ekko-bsart.
  gs_hdr-lifnr = gs_ekko-lifnr.
  gs_hdr-bedat = gs_ekko-bedat.
  gs_hdr-waers = gs_ekko-waers.
  CLEAR gs_data.
  gs_data-segnam = 'ZTRN_E1POHDR'.
  gs_data-sdata  = gs_hdr.
  APPEND gs_data TO gt_data.

  LOOP AT gt_ekpo INTO gs_ekpo.
    CLEAR gs_itm.
    gs_itm-ebelp = gs_ekpo-ebelp.
    gs_itm-matnr = gs_ekpo-matnr.
    gs_itm-txz01 = gs_ekpo-txz01.
    gs_itm-menge = gs_ekpo-menge.     "segmen semua CHAR: angka -> teks
    gs_itm-meins = gs_ekpo-meins.
    gs_itm-netwr = gs_ekpo-netwr.
    CLEAR gs_data.
    gs_data-segnam = 'ZTRN_E1POITM'.
    gs_data-sdata  = gs_itm.
    APPEND gs_data TO gt_data.
  ENDLOOP.

* 3. Serahkan ke ALE: partner profile menentukan port & cara kirim
  CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
    EXPORTING
      master_idoc_control            = gs_control
    TABLES
      communication_idoc_control     = gt_comm
      master_idoc_data               = gt_data
    EXCEPTIONS
      error_in_idoc_control          = 1
      error_writing_idoc_status      = 2
      error_in_idoc_data             = 3
      sending_logical_system_unknown = 4
      OTHERS                         = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  COMMIT WORK.            "IDoc baru benar-benar diproses setelah commit

  LOOP AT gt_comm INTO gs_comm.
    WRITE: / 'IDoc dibuat:', gs_comm-docnum, 'status', gs_comm-status.
  ENDLOOP.
  IF gt_comm IS INITIAL.
    WRITE: / 'Tidak ada IDoc: cek partner profile WE20 (outbound ZTRN_PO)'.
  ENDIF.
