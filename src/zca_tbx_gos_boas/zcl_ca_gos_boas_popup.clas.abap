"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: Popup to select attachments</p>
CLASS zcl_ca_gos_boas_popup DEFINITION PUBLIC
                                       INHERITING FROM zcl_ca_gos_boas_popup_base
                                       CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_gos_cons     | <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
      "! @raising   zcx_ca_gos_boas | <p class="shorttext synchronized" lang="en">GOS: Errors while selecting attachments to BO</p>
      constructor
        IMPORTING
          io_gos_cons TYPE REF TO zif_ca_gos_boas
        RAISING
          zcx_ca_gos_boas.

* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      handle_pbo REDEFINITION,

      on_closed REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_POPUP IMPLEMENTATION.


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( io_gos_cons   = io_gos_cons
                        iv_starting_x = 10
                        iv_starting_y = 3
                        iv_ending_x   = 150
                        iv_ending_y   = 23 ).
  ENDMETHOD.                    "constructor


  METHOD handle_pbo.
    "-----------------------------------------------------------------*
    "   Handle Process Before Output
    "-----------------------------------------------------------------*
    IF mo_alv_sl IS BOUND.
      RETURN.
    ENDIF.

    super->handle_pbo( iv_event ).

    "Normally it should be possible to use container MO_CCONT_REUSE directly,
    "but it doesn't. So to create another container in the container is the workaround.
    DATA(lo_alv_sl) = NEW zcl_ca_gos_boas_sellist(
                                       io_gos_cons    = mo_gos_cons
                                       io_popup_ctlr  = me
*                                       io_cnt_sellist = mo_ccont_reuse ).
                                       io_cnt_sellist = mo_cnt_sellist ).
*                                       io_cnt_docview = mo_splt->get_container( row    = 1
*                                                                              column = 2 ) ).
    "DO IT HERE!!! Ohterwise the move is avoided by the DISPLAY method executed in PROCESS
    mo_alv_sl = CAST #( lo_alv_sl ).

    lo_alv_sl->process( ).
  ENDMETHOD.                    "handle_pbo


  METHOD on_closed.
    "-----------------------------------------------------------------*
    "   Release fields and instances for garbage collection
    "-----------------------------------------------------------------*
    super->on_closed( ).

    IF mo_alv_sl IS BOUND.
      DATA(lo_alv_sl) = CAST zcl_ca_gos_boas_sellist( mo_alv_sl ).
      lo_alv_sl->free( ).
    ENDIF.

    FREE: mo_splt,
          mo_alv_sl.
  ENDMETHOD.                    "on_closed
ENDCLASS.
