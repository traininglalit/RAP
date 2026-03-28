CLASS lhc_ZR_SALESORDHDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_salesordhdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zr_salesordhdr RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zr_salesordhdr.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zr_salesordhdr.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zr_salesordhdr.

    METHODS earlynumbering_cba_Item FOR NUMBERING
      IMPORTING entities FOR CREATE zr_salesordhdr\_Item.

    METHODS quotbidDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_salesordhdr~quotbidDate.

    METHODS validateCurreny FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_salesordhdr~validateCurreny.
    METHODS postSales FOR MODIFY
      IMPORTING keys FOR ACTION ZR_SALESORDHDR~postSales RESULT result.

ENDCLASS.

CLASS lhc_ZR_SALESORDHDR IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    LOOP AT lt_result INTO DATA(ls_result).
      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        APPEND VALUE #(  Salesorder = ls_result-Salesorder
                         %delete = COND #( WHEN ls_result-Documentcat = 'T' THEN if_abap_behv=>auth-unauthorized
                                           ELSE if_abap_behv=>auth-allowed
                                        )
                      ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: lv_salesorder TYPE vbeln_va.

    TRY.
        CALL METHOD cl_numberrange_runtime=>number_get
          EXPORTING
*           ignore_buffer     =
            nr_range_nr       = '01'
            object            = 'ZSO'
            quantity          = 1
*           subobject         =
*           toyear            =
          IMPORTING
            number            = DATA(lv_number)
            returncode        = DATA(lv_returncode)
            returned_quantity = DATA(lv_returned_quan).
      CATCH cx_nr_object_not_found INTO DATA(lx_notfound).
      CATCH cx_number_ranges INTO DATA(lx_numrange).
    ENDTRY.
    lv_salesorder = |{ lv_number ALPHA = OUT }|.

    LOOP AT entities INTO DATA(ls_entity).
      APPEND VALUE #( %cid       = ls_entity-%cid
                      %is_draft  = ls_entity-%is_draft
                      salesorder = lv_salesorder ) TO mapped-zr_salesordhdr.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_create.
    LOOP AT entities INTO DATA(ls_entities).
      SELECT salesordtype
      FROM zdb_salesordhdr
      INTO TABLE @DATA(lt_vbak).

      LOOP AT lt_vbak INTO DATA(ls_result).
        IF ls_result-salesordtype <> 'OR'.
          APPEND VALUE #( %key = ls_entities-%key "keys[ 1 ]-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-none
                                   text     = 'Sales Order Type TA does not exist, please define'
                                 )
                        ) TO reported-zr_salesordhdr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

  METHOD earlynumbering_cba_Item.
    DATA: lv_salesorder      TYPE char10,
          lv_salesorder_next TYPE char10,
          lv_max_item(06)    TYPE c.
    LOOP AT entities INTO DATA(ls_header).
      SELECT MAX( salesitem ) FROM zdb_salesitem_d
        WHERE salesorder = @ls_header-salesorder
        INTO @DATA(lv_max_item_d).
      lv_max_item = lv_max_item_d.
*        ENDIF.
      " 2. Assign unique positions to each new item in the association
      LOOP AT ls_header-%target INTO DATA(ls_item).
        lv_max_item += 10. " Increments by 10 (standard practice)
        APPEND VALUE #(
          %cid       = ls_item-%cid
          %is_draft  = ls_item-%is_draft
          salesorder = ls_header-salesorder
          salesitem    = lv_max_item
        ) TO mapped-ze_salesorditem.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD quotbidDate.
    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
    READ ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    MODIFY ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr
    UPDATE SET FIELDS WITH VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                                 Quotationbiddate = ls_result-Quotationdate + 90
                                                               )

                                  ) REPORTED DATA(lt_header_reported).
  ENDMETHOD.

  METHOD validateCurreny.

    READ ENTITIES OF zr_salesordhdr
    ENTITY zr_salesordhdr ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    LOOP AT lt_result INTO DATA(ls_result).
      IF ls_result-Currency <> 'INR'.
        APPEND VALUE #( %tky = ls_result-%tky ) TO failed-zr_salesordhdr.
        APPEND VALUE #( %tky = ls_result-%tky "keys[ 1 ]-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Currency should be INR always'
                               )
                      ) TO reported-zr_salesordhdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD postSales.
*     DATA: ls_salesorderhdr_in  TYPE bapisdhd1,
*          ls_salesorderhdr_inx TYPE bapisdhd1x,
*          lt_partners          TYPE STANDARD TABLE OF bapiparnr,
*          lt_salesorderitem_in TYPE STANDARD TABLE OF bapisditm,
*          lt_salesorderitem_x  TYPE STANDARD TABLE OF bapisditmx,
*          lt_schedules         TYPE STANDARD TABLE OF bapischdl,
*          lt_schedules_x       TYPE STANDARD TABLE OF bapischdlx,
*          lt_return            TYPE STANDARD TABLE OF bapiret2,
*          ls_salesorderitem_in TYPE bapisditm,
*          ls_salesorderitem_x  TYPE  bapisditmx,
*          ls_partners          TYPE bapiparnr,
*          ls_schedules         TYPE bapischdl,
*          ls_schedules_x       TYPE bapischdlx,
*          lv_salesdocument     TYPE vbeln.
*
*    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).
*    READ ENTITIES OF zr_salesordhdr IN LOCAL MODE
*    ENTITY zr_salesordhdr ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_header)
*    ENTITY zr_salesordhdr BY \_item ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_item)
*    FAILED DATA(lt_failed)
*    REPORTED DATA(lt_reported).
*
*    LOOP AT lt_header INTO DATA(ls_header).
*      lv_salesdocument = ls_header-Salesorder.
*      ls_salesorderhdr_in-doc_type = ls_header-Salesordtype.
**      ls_salesorderhdr_in-
*      ls_salesorderhdr_in-sales_org = '1710'.
*      ls_salesorderhdr_in-distr_chan = '10'.
*      ls_salesorderhdr_in-division = '00'.
*
*      ls_salesorderhdr_inx-doc_type  = 'X'.
*      ls_salesorderhdr_inx-sales_org = 'X'.
*      ls_salesorderhdr_inx-distr_chan = 'X'.
*      ls_salesorderhdr_inx-division = 'X'.
*      ls_salesorderhdr_inx-updateflag = 'I'.
*
*      ls_partners-partn_numb = '0017100001'.
*      ls_partners-partn_role = 'AG'.
*      APPEND ls_partners TO lt_partners.
*      ls_partners-partn_numb = '0017100001'.
*      ls_partners-partn_role = 'WE'.
*      APPEND ls_partners TO lt_partners.
*    ENDLOOP.
"Create below RFC in your on-premise system with necessary parameters and then call it here
*    CALL FUNCTION 'ZRFC_SALESORDER_CREATE' DESTINATION 'NONE'
*      EXPORTING
*        im_salesdocument     = lv_salesdocument
*        im_salesorderhdr_in  = ls_salesorderhdr_in
*        im_salesorderhdr_inx = ls_salesorderhdr_inx
*      TABLES
*        t_return             = lt_return
*        t_salesorderitem_in  = lt_salesorderitem_in
*        t_salesorderitem_x   = lt_salesorderitem_x
*        t_partners           = lt_partners.
*    LOOP AT lt_return INTO DATA(ls_return).
*      APPEND VALUE #(
*           %msg = new_message(
*               id       = ls_return-id
*               number   = ls_return-number
*               severity = if_abap_behv_message=>severity-error
*               v1       = ls_return-message_v1
*               v2       = ls_return-message_v2
*               v3       = ls_return-message_v3
*               v4       = ls_return-message_v4 )
*      ) TO reported-zr_salesordhdr.
*    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZE_SALESORDITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS ToCalculateTotalAmt FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ze_salesorditem~ToCalculateTotalAmt.

ENDCLASS.

CLASS lhc_ZE_SALESORDITEM IMPLEMENTATION.

  METHOD ToCalculateTotalAmt.
    DATA: lv_netitem_sum TYPE ze_salesorditem-Netitemamount.
    READ ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).

    DATA(lv_key) = lt_result[ 1 ]-Salesorder.

    READ ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr BY \_item ALL FIELDS WITH VALUE #( ( %tky-Salesorder = lv_key
                                                             %tky-%is_draft  = if_abap_behv=>mk-on
                                                           ) )
    RESULT DATA(lt_item)
    FAILED DATA(lt_failed_item)
    REPORTED DATA(lt_reported_item).

    lv_netitem_sum = REDUCE #( INIT lv_sum = 0
                               FOR ls_item IN lt_item
                               NEXT lv_sum += ls_item-Netitemamount
                             ).

    MODIFY ENTITIES OF zr_salesordhdr IN LOCAL MODE
    ENTITY zr_salesordhdr UPDATE FROM VALUE #( (  %tky-Salesorder = lv_key
                                                  %is_draft = if_abap_behv=>mk-on
                                                   Totalamount = lv_netitem_sum
                                                   %control-Totalamount = if_abap_behv=>mk-on
                                                        ) )
     REPORTED DATA(lt_reported_modify)
     FAILED DATA(lt_failed_modify)
     MAPPED DATA(lt_mapped_modify).
  ENDMETHOD.

ENDCLASS.
