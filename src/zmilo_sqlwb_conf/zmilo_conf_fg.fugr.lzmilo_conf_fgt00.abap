*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMILO_MASK......................................*
DATA:  BEGIN OF STATUS_ZMILO_MASK                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMILO_MASK                    .
CONTROLS: TCTRL_ZMILO_MASK
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZMILO_ROLE......................................*
DATA:  BEGIN OF STATUS_ZMILO_ROLE                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMILO_ROLE                    .
CONTROLS: TCTRL_ZMILO_ROLE
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZMILO_WLIST.....................................*
DATA:  BEGIN OF STATUS_ZMILO_WLIST                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMILO_WLIST                   .
CONTROLS: TCTRL_ZMILO_WLIST
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZMILO_MASK                    .
TABLES: *ZMILO_ROLE                    .
TABLES: *ZMILO_WLIST                   .
TABLES: ZMILO_MASK                     .
TABLES: ZMILO_ROLE                     .
TABLES: ZMILO_WLIST                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
