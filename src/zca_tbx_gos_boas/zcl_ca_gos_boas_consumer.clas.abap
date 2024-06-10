"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS Consumer to sel. attachm. for mail distribution</p>
CLASS zcl_ca_gos_boas_consumer DEFINITION PUBLIC
                                          CREATE PROTECTED.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      zif_ca_gos_boas.

*   a l i a s e s
    ALIASES:
*     GOS objects and methods
      mo_gos_svc           FOR  zif_ca_gos_boas~mo_gos_svc,
      mo_al_cont           FOR  zif_ca_gos_boas~mo_arch_cont,
      factory              FOR  zif_ca_gos_boas~factory,
      activate_service     FOR  zif_ca_gos_boas~activate_service,
      has_content          FOR  zif_ca_gos_boas~has_content,
      execute_consumer     FOR  zif_ca_gos_boas~execute_consumer,
      on_handle_fcode      FOR  zif_ca_gos_boas~on_fcode_triggered,
      svc_closed           FOR  zif_ca_gos_boas~svc_closed,
      svc_saved            FOR  zif_ca_gos_boas~svc_saved.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_gos_svc   | <p class="shorttext synchronized" lang="en">GOS: BO Attachment selection for mails (service)</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc | <p class="shorttext synchronized" lang="en">Common exception: Database access</p>
      constructor
        IMPORTING
          io_gos_svc TYPE REF TO zcl_ca_gos_boas_svc
        RAISING
          zcx_ca_param
          zcx_ca_dbacc.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
      mo_popup             FOR  zif_ca_gos_boas~mo_popup.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Function code constants (with suggested icons)</p>
      mo_fcodes        TYPE REF TO zcl_ca_c_fcodes.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_CONSUMER IMPLEMENTATION.


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    mo_gos_svc = io_gos_svc.
    SET HANDLER: mo_gos_svc->on_svc_closed FOR me,
                 mo_gos_svc->on_svc_saved  FOR me.

    mo_al_cont = NEW #( is_bo_key = mo_gos_svc->ms_bo_key ).
    mo_fcodes = zcl_ca_c_fcodes=>get_instance( ).
  ENDMETHOD.                    "constructor


  METHOD zif_ca_gos_boas~activate_service.
    "-----------------------------------------------------------------*
    "   Check service activation in customizing
    "-----------------------------------------------------------------*
    "No further details to be checked
    result = abap_true.
  ENDMETHOD.                    "zif_ca_gos_boas~activate_service


  METHOD zif_ca_gos_boas~execute_consumer.
    "-----------------------------------------------------------------*
    "   Starting main function of consumer, controlling the process
    "-----------------------------------------------------------------*
    DATA(lo_popup) = NEW zcl_ca_gos_boas_popup( me ).
    "DO IT HERE!!! Ohterwise the move is avoided by the DISPLAY method
    mo_popup = CAST #( lo_popup ).

    SET HANDLER on_handle_fcode FOR lo_popup.
    lo_popup->display( ).
  ENDMETHOD.                    "zif_ca_gos_boas~execute_consumer


  METHOD zif_ca_gos_boas~factory.
    "-----------------------------------------------------------------*
    "   Creating consumer instance
    "-----------------------------------------------------------------*
    TRY.
        CREATE OBJECT result TYPE (io_gos_svc->ms_gos_boas-class_name_consumer)
          EXPORTING
            io_gos_svc = io_gos_svc.

      CATCH zcx_ca_archive_content INTO DATA(lx_error).
        "Error when creating consumer &1 -> see previous exception
        RAISE EXCEPTION TYPE zcx_ca_gos_boas
          EXPORTING
            textid   = zcx_ca_gos_boas=>error_creating_consumer
            previous = lx_error
            mv_msgv1 = CONV #( translate( val  = sy-repid
                                          from = `=`
                                          to   = ``) ).
    ENDTRY.
  ENDMETHOD.                    "zif_ca_gos_boas~factory


  METHOD zif_ca_gos_boas~has_content.
    "-----------------------------------------------------------------*
    "   Checks if any content is connected to the current BO
    "-----------------------------------------------------------------*
    "Create filter from settings in MS_GOS_BOAS
    mo_al_cont->get( iv_refresh = abap_true ).
    result = mo_al_cont->has_content( ).
  ENDMETHOD.                    "zif_ca_gos_boas~has_content


  METHOD zif_ca_gos_boas~on_fcode_triggered.
    "-----------------------------------------------------------------*
    "   Receiving last action forwarding to GOS service
    "-----------------------------------------------------------------*
    "Inform service class
    CASE iv_fcode.
      WHEN mo_fcodes->save.
        RAISE EVENT svc_saved
          EXPORTING
            it_gos_bomd = mo_popup->get_result( ).

      WHEN OTHERS.
        RAISE EVENT svc_closed.
    ENDCASE.
  ENDMETHOD.                    "zif_ca_gos_boas~on_handle_fcode
ENDCLASS.
