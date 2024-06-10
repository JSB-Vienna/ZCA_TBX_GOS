"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: Popup to select attachments (base impl.)</p>
CLASS zcl_ca_gos_boas_popup_base DEFINITION PUBLIC
                                            INHERITING FROM zcl_ca_reusable_popup_cust_cnt
                                            CREATE PROTECTED
                                            ABSTRACT.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      zif_ca_gos_boas_popup.

*   a l i a s e s
    ALIASES:
      get_result           FOR  zif_ca_gos_boas_popup~get_result.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_gos_cons     | <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
      "! @parameter iv_starting_x   | <p class="shorttext synchronized" lang="en">Starting in column</p>
      "! @parameter iv_starting_y   | <p class="shorttext synchronized" lang="en">Starting in line</p>
      "! @parameter iv_ending_x     | <p class="shorttext synchronized" lang="en">Ending in column</p>
      "! @parameter iv_ending_y     | <p class="shorttext synchronized" lang="en">Ending in line</p>
      "! @raising   zcx_ca_gos_boas | <p class="shorttext synchronized" lang="en">GOS: Errors while selecting attachments to BO</p>
      constructor
        IMPORTING
          io_gos_cons   TYPE REF TO zif_ca_gos_boas
          iv_starting_x TYPE i DEFAULT 0
          iv_starting_y TYPE i DEFAULT 0
          iv_ending_x   TYPE i DEFAULT 0
          iv_ending_y   TYPE i DEFAULT 0
        RAISING
          zcx_ca_gos_boas.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
      mo_gos_cons          FOR  zif_ca_gos_boas_popup~mo_gos_cons,
      mo_splt              FOR  zif_ca_gos_boas_popup~mo_splt,
      mo_cnt_sellist       FOR  zif_ca_gos_boas_popup~mo_cnt_sellist,
      mo_alv_sl            FOR  zif_ca_gos_boas_popup~mo_alv_sl.

*   i n s t a n c e   m e t h o d s
    METHODS:
      handle_pbo REDEFINITION,

      on_set_status REDEFINITION,

      on_process_fcode REDEFINITION,

      on_closed REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_POPUP_BASE IMPLEMENTATION.


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( iv_mode       = SWITCH #( io_gos_cons->mo_gos_svc->get_mode( )
                                          WHEN io_gos_cons->mo_gos_svc->mp_mode_read
                                            THEN mo_scr_options->mode-display
                                          WHEN io_gos_cons->mo_gos_svc->mp_mode_write
                                            THEN mo_scr_options->mode-modify )
                        is_popup_corners = VALUE #( starting_at_x = iv_starting_x
                                                    starting_at_y = iv_starting_y
                                                    ending_at_x   = iv_ending_x
                                                    ending_at_y   = iv_ending_y ) ).

    mo_gos_cons = io_gos_cons.
  ENDMETHOD.                    "constructor


  METHOD handle_pbo.
    "-----------------------------------------------------------------*
    "   Handle Process Before Output
    "-----------------------------------------------------------------*
    IF mo_splt IS BOUND.
      RETURN.
    ENDIF.

    super->handle_pbo( iv_event ).

    "Create splitter in relative mode => width in percent (%)
    mo_splt = zcl_ca_cfw_util=>create_splitter_container( io_parent   = mo_ccont_reuse
                                                     iv_rows     = 1
                                                     iv_columns  = 1 "2
                                                     iv_cnt_name = 'SPLT_BOAS' ) ##no_text.

    mo_cnt_sellist = mo_splt->get_container( row    = 1
                                             column = 1 ).
  ENDMETHOD.                    "handle_pbo


  METHOD on_closed.
    "-----------------------------------------------------------------*
    "   Release fields and instances for garbage collection
    "-----------------------------------------------------------------*
    super->on_closed( ).

    FREE mo_splt.
  ENDMETHOD.                    "on_closed


  METHOD on_process_fcode.
    "-----------------------------------------------------------------*
    "   Handle popup function codes
    "-----------------------------------------------------------------*
    TRY.
        "Inform caller
        RAISE EVENT fcode_triggered
          EXPORTING
            iv_fcode = iv_fcode.

        "Initialize function code and leave screen
        set_fcode_handled( ).
        close( ).

      CATCH cx_root INTO DATA(lx_error) ##catch_all.
        set_fcode_handled( ).
        MESSAGE lx_error TYPE c_msgty_e.
    ENDTRY.
  ENDMETHOD.                    "on_process_fcode


  METHOD on_set_status.
    "-----------------------------------------------------------------*
    "   Activate functions depending on mode and set title bar
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_excl_fcode TYPE salv_dynpro_t_fcode.

    super->on_set_status( mo_gui_status ).

    CASE mo_screen->mv_mode.
      WHEN mo_scr_options->mode-display.
        APPEND: mo_fcodes->cancel TO lt_excl_fcode,
                mo_fcodes->save   TO lt_excl_fcode.

      WHEN mo_scr_options->mode-modify.
        APPEND mo_fcodes->enter TO lt_excl_fcode.
    ENDCASE.

    "Hide functions for mode x
    mo_gui_status->set_excl_fcode( lt_excl_fcode ).

    mo_gui_status->set_titlebar(
                iv_titlebar_var1 = CONV #( mo_gos_cons->mo_arch_cont->ms_bo_desc-ntext )
                iv_titlebar_var2 = |{ mo_gos_cons->mo_arch_cont->ms_bo_key-instid ALPHA = OUT }| ).
  ENDMETHOD.                    "on_set_status


  METHOD zif_ca_gos_boas_popup~get_result.
    "-----------------------------------------------------------------*
    "   Return the result to GOS class
    "-----------------------------------------------------------------*
    rt_gos_bomd = mo_alv_sl->get_marked_docs( ).
  ENDMETHOD.                    "zif_ca_gos_boas_popup~get_result
ENDCLASS.
