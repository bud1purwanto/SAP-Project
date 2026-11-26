*--------------------------------------------------------------------*
*  Object types (Präfix: CON)                                        *
*--------------------------------------------------------------------*
DATA:
  BEGIN OF CON_AWOBA,
    OR LIKE TKV03-AWOBA VALUE 'OR',   " Order header
    HP LIKE TKV03-AWOBA VALUE 'HP',   " Cost object hierarchie
    KS LIKE TKV03-AWOBA VALUE 'KS',   " Cost center
    BP LIKE TKV03-AWOBA VALUE 'BP',   " Business process
    OP LIKE TKV03-AWOBA VALUE 'OP',   " Order item
    RS LIKE TKV03-AWOBA VALUE 'RS',   " Run schedule
    RM LIKE TKV03-AWOBA VALUE 'RM',   " Production version
    EK LIKE TKV03-AWOBA VALUE 'EK',   " Cost estimate
  END   OF CON_AWOBA.