"! <p class="shorttext synchronized" lang="en">GOS: Update FM for table ZCA_T_GOS_BOMD</p>
"!
"! @parameter is_bo_key   | <p class="shorttext synchronized" lang="en">Business object key</p>
"! @parameter it_gos_bomd | <p class="shorttext synchronized" lang="en">Changed attachment assignments</p>
FUNCTION z_ca_gos_boas_write_bomd.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_BO_KEY) TYPE  SIBFLPORB
*"     VALUE(IT_GOS_BOMD) TYPE  ZCA_TT_GOS_BOMD
*"----------------------------------------------------------------------
  "Local data definitions
  DATA:
    lt_gos_bomd          TYPE STANDARD TABLE OF zca_gos_bomd.

  DATA(ls_bo_key) = is_bo_key.
  ls_bo_key-instid = ls_bo_key-instid && '%'.  "Generic read or deletion

  "Delete all entries of BO
  DELETE FROM zca_gos_bomd WHERE sap_object EQ   ls_bo_key-typeid
                             AND object_id  LIKE ls_bo_key-instid.

  "Insert new entries to BO - before complete key by BO name and Id
  lt_gos_bomd = it_gos_bomd.
  MODIFY lt_gos_bomd FROM VALUE #( sap_object = is_bo_key-typeid
                                   object_id  = is_bo_key-instid )
                     TRANSPORTING sap_object  object_id
                     WHERE sap_object NE is_bo_key-typeid
                        OR object_id  NE is_bo_key-instid.

  INSERT zca_gos_bomd FROM TABLE lt_gos_bomd.

ENDFUNCTION.
