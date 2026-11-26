***INCLUDE BAPIDATA .
DATA:    BEGIN OF COMMON PART DATAFORBAPI.

DATA: BAPICALL(1) TYPE C.
DATA: BEGIN OF FXVBEP OCCURS 10.
        INCLUDE STRUCTURE VBEP.
DATA: END   OF FXVBEP.
data: begin of fxvbap occurs 10.
            include structure vbap.
data: end   of fxvbap.

data: begin of fxvbpa occurs 10.
            include structure vbpavb.
data: end   of fxvbpa.

DATA:    END   OF COMMON PART.