CLASS zcl_cleardata_btp1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  CLASS-METHODS clear_data IMPORTING im_user TYPE sy-uname OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cleardata_btp1 IMPLEMENTATION.
  METHOD clear_data.
  IF im_user IS NOT INITIAL.
    SELECT *
    FROM zdb_salehdr_btp1
    WHERE Personname = @im_user
    INTO TABLE @DATA(lt_hdr).

    IF lt_hdr IS NOT INITIAL.
      SELECT *
      FROM zdb_saleitm_btp1
      FOR ALL ENTRIES IN @lt_hdr
      WHERE Salesorder = @lt_hdr-Salesorder
      INTO TABLE @DATA(lt_item).
    ENDIF.
    DELETE zdb_salehdr_btp1 FROM TABLE @lt_hdr.
    DELETE zdb_saleitm_btp1 FROM TABLE @lt_item.
ENDIF.
  ENDMETHOD.

ENDCLASS.
