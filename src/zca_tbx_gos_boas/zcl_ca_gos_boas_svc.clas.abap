"! <p class="shorttext synchronized" lang="en">CA-TBX: GOS: BO Attachment selection for mails (service)</p>
CLASS zcl_ca_gos_boas_svc DEFINITION PUBLIC
                                     INHERITING FROM cl_gos_service
                                     CREATE PUBLIC.

* Create an entry in TA SGOSM like this:
* Name of service      ZCAGOSBOAS
*
* Description          Select attachments for mails
* Quick info           Select attachments for mails
* Class f.Gen.Service  ZCL_CA_GOS_BOAS_SVC
* Service Type
* Icon                 ICON_WORKLOAD or ICON_VARIANTS are the most fitting
* Next service         PERS_NOTE             => This is to set in order before
*                      'Send'. Set this service ZCAGOSBOAS as next service of
*                      service VIEW_ATTA = 'Attachment list'.
* Subservice
* _  Control
* _  Commit required


* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      if_xo_const_message.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Common object: Business Application Logging (BAL)</p>
      mo_log         TYPE REF TO zif_ca_log READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Content of a business object</p>
      mo_arch_cont   TYPE REF TO zcl_ca_gos_boas_arch_cont READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Constants and value checks for application log</p>
      mo_log_options TYPE REF TO zcl_ca_c_log READ-ONLY,


*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">GOS: As attachment marked documents</p>
      mt_gos_bomd    TYPE zca_tt_gos_bomd READ-ONLY,

*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">Business object/class key - BOR Compatible</p>
      ms_bo_key      TYPE sibflporb READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">GOS: Def. BOs for attachment selection</p>
      ms_gos_boas    TYPE zca_gos_boas READ-ONLY.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      constructor,

      "! <p class="shorttext synchronized" lang="en">Return current read / write mode</p>
      "!
      "! @parameter rv_mode | <p class="shorttext synchronized" lang="en">Read / write mode (use MP_MODE_* to compare)</p>
      get_mode
        RETURNING
          VALUE(rv_mode) TYPE sgs_rwmod,

      "! <p class="shorttext synchronized" lang="en">Service popup will be closed without saving</p>
      on_svc_closed
        FOR EVENT svc_closed OF zif_ca_gos_boas,

      "! <p class="shorttext synchronized" lang="en">Service popup will be closed and changes are saved</p>
      on_svc_saved
        FOR EVENT svc_saved OF zif_ca_gos_boas
        IMPORTING
          it_gos_bomd,

      execute REDEFINITION,

      on_service_succeeded REDEFINITION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      check_status REDEFINITION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   a l i a s e s
    ALIASES:
*     Message types
      c_msgty_e            FOR  if_xo_const_message~error,
      c_msgty_i            FOR  if_xo_const_message~info,
      c_msgty_s            FOR  if_xo_const_message~success,
      c_msgty_w            FOR  if_xo_const_message~warning.

*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Service result: Closed - no saving</p>
      c_result_closed   TYPE char1             VALUE 'C'  ##no_text,
      "! <p class="shorttext synchronized" lang="en">Service result: Saved on DB</p>
      c_result_saved    TYPE char1             VALUE 'S'  ##no_text,
      "! <p class="shorttext synchronized" lang="en">Name of interface that has to be implemented by consumers</p>
      c_ifname_gos_boas TYPE seoclsname        VALUE 'ZIF_CA_GOS_BOAS'  ##no_text,
      "! <p class="shorttext synchronized" lang="en">Application Log: Subobject to ZCA: GOS BO attachm. selection</p>
      c_subobj_gos_boas TYPE balsubobj         VALUE 'GOS_BOAS' ##no_text.


*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">GOS: Consumer implementation for BO attachment selection</p>
      mo_gos_boas   TYPE REF TO zif_ca_gos_boas,

*     s i n g l e   v a l u e s
      "! <p class="shorttext synchronized" lang="en">Last function code of popup</p>
      mv_svc_result TYPE syst_ucomm,
      "! <p class="shorttext synchronized" lang="en">X = First execution of service</p>
      mv_first_exec TYPE abap_bool       VALUE abap_true.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Checks if necessary interface is implemented in def. class</p>
      "!
      "! @parameter iv_clsname   | <p class="shorttext synchronized" lang="en">Class name from customizing</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
      check_class
        IMPORTING
          iv_clsname TYPE seoclsname
        RAISING
          zcx_ca_param,

      "! <p class="shorttext synchronized" lang="en">Saving and closing log</p>
      close_log,

      "! <p class="shorttext synchronized" lang="en">Save marked documents in DB</p>
      "!
      "! @raising zcx_ca_param | <p class="shorttext synchronized" lang="en">Common exception: Parameter error (INHERIT from this excep!)</p>
      save
        RAISING
          zcx_ca_param.

ENDCLASS.



CLASS ZCL_CA_GOS_BOAS_SVC IMPLEMENTATION.


  METHOD check_class.
    "-----------------------------------------------------------------*
    "   Check if class implements the necessary interface
    "-----------------------------------------------------------------*
    DATA(lo_cls_desc) = CAST cl_abap_classdescr(
                                 NEW zcl_ca_ddic( iv_name = iv_clsname )->mo_type_desc ).

    lo_cls_desc->get_interface_type(
                              EXPORTING
                                p_name              = c_ifname_gos_boas
                              EXCEPTIONS
                                interface_not_found = 1
                                OTHERS              = 2 ).
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_ca_gos_boas
        EXPORTING
          textid   = zcx_ca_gos_boas=>interface_not_found
          mv_msgv1 = CONV #( iv_clsname )
          mv_msgv2 = CONV #( c_ifname_gos_boas ).
    ENDIF.
  ENDMETHOD.                    "check_class


  METHOD check_status.
    "-----------------------------------------------------------------*
    "   Handle Process Before Output - but set no GUI status!
    "-----------------------------------------------------------------*
*    importing
*      !IS_LPORB type SIBFLPORB
*      !IS_OBJECT type BORIDENT optional
*    exporting
*      value(EP_STATUS) type SGS_STATUS
*      !EP_ICON type SGS_ICON .

    "Local data definitions
    TRY.
        "Initialize status
        ep_status = mp_status_invisible.

        IF is_lporb-instid IS INITIAL.
          RETURN.
        ENDIF.

        "Check customizing - hide if not maintained for this BO
        SELECT SINGLE * INTO  @ms_gos_boas
                        FROM  zca_gos_boas
                        WHERE bo_name EQ @is_lporb-typeid.
        IF sy-subrc NE 0.
          RETURN.
        ENDIF.

        "Remove instance if the key change to be able to create a new one
        IF is_lporb-instid NE ms_bo_key-instid.
          CLEAR mo_gos_boas.
        ENDIF.

        IF mo_gos_boas IS NOT BOUND.
          "Keep object key and create log
          ms_bo_key = is_lporb.

          "Create log to be able to log occurring error here after
          mo_log = zcl_ca_log=>get_instance(
                             iv_object        = zif_ca_c_log_techn=>c_object_zca
                             iv_subobj        = c_subobj_gos_boas
                             is_lpor          = ms_bo_key
                             iv_extnumber     = CONV #( condense( val = |{ ms_bo_key-typeid } { ms_bo_key-instid }| ) )
                             iv_repid         = CONV #( ms_gos_boas-class_name_consumer )
                             iv_def_probclass = mo_log_options->problem_class-important ).

          "Check consumer class
          check_class( ms_gos_boas-class_name_consumer ).

          "Because the behavior of older transactions is different from others. They run two times
          "through this method and at the second turn the transaction code is empty!

          "Another problem is, that some transaction, e. g. Enjoy transactions, don't change the SY-TCODE
          "or raise an event that the service has changed when switching e. g. from display to change mode.
          "SORRY for that -> the user has to RESTART the transaction with the right TCODE!!
          IF sy-tcode IS NOT INITIAL.
            "Set change mode depending on customized transaction code
            gp_mode = mp_mode_read.
            IF sy-tcode EQ ms_gos_boas-tcode.
              gp_mode = mp_mode_write.
            ENDIF.
          ENDIF.

          "Create consumer
          CALL METHOD (ms_gos_boas-class_name_consumer)=>factory
            EXPORTING
              io_gos_svc  = me
            RECEIVING
              ro_gos_boas = mo_gos_boas.
        ENDIF.                         "mo_gos_boas IS NOT BOUND

        "Check other criteria if service should be activiated
        IF mo_gos_boas->activate_service( ) EQ abap_false.
          RETURN.
        ENDIF.

        "Set handler for class to archive a new business document
        SET HANDLER on_service_succeeded FOR ALL INSTANCES ACTIVATION abap_on.

        "Check for something to display
        IF mo_gos_boas->has_content( ) EQ abap_false.
          ep_status = mp_status_inactive.
          RETURN.
        ENDIF.

        ep_status = mp_status_active.

      CATCH zcx_ca_error INTO DATA(lx_error).
        IF mo_log IS BOUND.
          mo_log->add_msg_exc( ix_excep = lx_error
                               iv_all   = abap_true ).
          "Use integrated COMMIT of GOS
          mo_log->save( iv_close  = abap_false
                        iv_commit = abap_false ).
          RAISE EVENT commit_required.
        ENDIF.
    ENDTRY.
  ENDMETHOD.                    "check_status


  METHOD close_log.
    "-----------------------------------------------------------------*
    "   Save and close log
    "-----------------------------------------------------------------*
    IF mo_log IS BOUND.
      mo_log->save( iv_close = abap_false ).
      "Message of no messages registered for log causes problems
      "and is here of no need. So clear it.
      IF sy-msgid EQ 'BL'  AND
         sy-msgno EQ '209' ##no_text.
        CLEAR: sy-msgty, sy-msgid, sy-msgno, sy-msgv1, sy-msgv2.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "close_log


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( ).
    mo_log_options = zcl_ca_c_log=>get_instance( ).
  ENDMETHOD.                    "constructor


  METHOD execute.
    "-----------------------------------------------------------------*
    "   Handle Process Before Output - but set no GUI status!
    "-----------------------------------------------------------------*
*    importing
*      !IO_CONTAINER type ref to CL_GUI_CONTAINER optional
*    exceptions
*      EXECUTION_FAILED
*      CONTAINER_IGNORED .

    TRY.
        IF mv_first_exec EQ abap_false.
          "Refresh selection with current filter in case that further
          "documents were attached since the last display.
          "This method actualizes the filter and refreshes the content.
          "A refresh of the consumer, e. g. new items, is not necessary
          "because the new data can just be determined after saving the
          "data, which requires a restart of the transaction.
          mo_gos_boas->has_content( ).
        ENDIF.

        "Call popup
        mo_gos_boas->execute_consumer( io_container ).
        mv_first_exec = abap_false.


        CASE mv_svc_result.
          WHEN c_result_saved.
            save( ).

            RAISE EVENT service_succeeded
              EXPORTING
                eo_service = me.

          WHEN c_result_closed.
            RAISE EVENT service_succeeded
              EXPORTING
                eo_service = me.
        ENDCASE.

        close_log( ).

      CATCH zcx_ca_param INTO DATA(lx_error).
        mo_log->add_msg_exc( ix_excep = lx_error
                             iv_all   = abap_true ).
        MESSAGE lx_error TYPE c_msgty_s DISPLAY LIKE c_msgty_e
                              RAISING execution_failed.
    ENDTRY.
  ENDMETHOD.                    "execute


  METHOD get_mode.
    "-----------------------------------------------------------------*
    "   Return current read / write mode
    "-----------------------------------------------------------------*
    rv_mode = gp_mode.
  ENDMETHOD.                    "get_mode


  METHOD on_service_succeeded.
    "-----------------------------------------------------------------*
    "   Handle service was completed successful
    "-----------------------------------------------------------------*
*    for event SERVICE_SUCCEEDED of CL_GOS_SERVICE
*    importing
*      !EO_SERVICE type ref to OBJECT.

    "Local data definitions
    DATA:
      lv_new_check         TYPE abap_bool   VALUE abap_false.

    "Determine which service succeeded
    TRY.
        DATA(lo_attachm) = CAST cl_gos_srv_attachment_create( eo_service ).
        lv_new_check = abap_true.

      CATCH cx_sy_move_cast_error.
        TRY.
            DATA(lo_arc_link) = CAST cl_arl_srv_link( eo_service ).
            lv_new_check = abap_true.

          CATCH cx_sy_move_cast_error.
        ENDTRY.
    ENDTRY.

    IF lv_new_check EQ abap_true.
      DATA(lv_status) = gp_status.
      gp_status       = mp_status_active.

      IF lv_status NE gp_status.
        RAISE EVENT service_changed
          EXPORTING
            ep_status  = gp_status
            eo_service = me.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "on_service_succeeded


  METHOD on_svc_closed.
    "-----------------------------------------------------------------*
    "   Service popup will be closed without saving
    "-----------------------------------------------------------------*
    mv_svc_result = c_result_closed.
  ENDMETHOD.                    "on_svc_closed


  METHOD on_svc_saved.
    "-----------------------------------------------------------------*
    "   Service popup will be closed and changes are saved
    "-----------------------------------------------------------------*
    mv_svc_result = c_result_saved.
    mt_gos_bomd   = it_gos_bomd.
  ENDMETHOD.                    "on_svc_saved


  METHOD save.
    "-----------------------------------------------------------------*
    "   Save marked documents in DB
    "-----------------------------------------------------------------*
    "For testing purposes prepare to switch to synchronous update
    DATA(lv_sync_or_not) = abap_false.
    CASE lv_sync_or_not.
      WHEN abap_false.
        "Update normally asynchronous
        CALL FUNCTION 'Z_CA_GOS_BOAS_WRITE_BOMD'
          IN UPDATE TASK
          EXPORTING
            is_bo_key   = ms_bo_key
            it_gos_bomd = mt_gos_bomd.

      WHEN abap_true.
        "Call update FM in synchronous
        CALL FUNCTION 'Z_CA_GOS_BOAS_WRITE_BOMD'
          EXPORTING
            is_bo_key   = ms_bo_key
            it_gos_bomd = mt_gos_bomd.
    ENDCASE.

    zcl_ca_utils=>do_commit( ).
  ENDMETHOD.                    "save
ENDCLASS.
