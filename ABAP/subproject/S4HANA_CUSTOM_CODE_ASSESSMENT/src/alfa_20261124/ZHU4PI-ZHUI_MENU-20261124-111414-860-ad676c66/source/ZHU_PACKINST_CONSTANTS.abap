*&---------------------------------------------------------------------*
*&  Include           ZHU_PACKINST_CONSTANTS
*&---------------------------------------------------------------------*
CONSTANTS:
* TCODES
  C_TCODE_FREESTOCK(6) VALUE 'ZHU4FS',
  C_TCODE_SO(6) VALUE 'ZHU4SO',

* DISPLAY MODES
  C_DISP_NEW          VALUE 'N',
  C_DISP_DISPLAY      VALUE 'D',
  C_DISP_CHANGE       VALUE 'C',

* PARTNER TYPES
  C_PARTNER_SHIPTO(2) VALUE 'WE',
  C_PARTNER_SOLDTO(2) VALUE 'AG',

* PACKING INSTRUCTION STATUS
  C_PINST_INACTIVE    VALUE 'N',
  C_PINST_ACTIVE      VALUE 'A',
  C_PINST_COMPLETED   VALUE 'C',
  C_PINST_INPROGRESS  VALUE 'I',

* INSTRUCTION LEVELS
  C_LEVEL_PALLET      VALUE '1',
  C_LEVEL_BOX         VALUE '2',
  C_LEVEL_ROLL        VALUE '3',

* HU status (O=open; I=In Progress; D=done; C=Canceled)
  C_HUSTAT_OPEN       VALUE 'O',
  C_HUSTAT_INPROGRESS VALUE 'I',
  C_HUSTAT_COMPLETED  VALUE 'C',
  C_HUSTAT_FORCED     VALUE 'F', "-- hu is assumed to be completed whatever
                                 "-- quantity actualy packed
  C_HUSTAT_CLOSED     VALUE 'X',

* PACKING PROCESS
  C_PCKST_OPEN        VALUE 'O',
  C_PCKST_PACKED      VALUE 'C',
  C_PCKST_PRINTED     VALUE 'P',

* HU PRINT STATUS
  C_PRSTAT_NOTPRINTED     VALUE 'N',
  C_PRSTAT_LABEL          VALUE 'L',
  C_PRSTAT_REPORT         VALUE 'R',
  C_PRSTAT_LABELANDREPORT VALUE 'B',

* DIGIT CONTROL EXISTANCE
  C_EXISTANCE_EXIST       VALUE ' ',  "-- ROLL STIL EXIST
  C_EXISTANCE_DELIVERY    VALUE 'A',  "-- GOOD ISSUE DELIVERY
  C_EXISTANCE_SCRAP       VALUE 'B',  "-- GOOD ISSUE SCRAP
  C_EXISTANCE_CANCELGR    VALUE 'C',  "-- CANCEL GOOD RECEIPT

* YES/NO
  C_YES VALUE 'X',
  C_NO  VALUE SPACE.