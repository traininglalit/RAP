CLASS zcl_validate_dropdown DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_validate_dropdown IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA(lo_paging)   = io_request->get_paging( ).
    DATA(lv_top)      = lo_paging->get_page_size( ).
    DATA(lv_skip)     = lo_paging->get_offset( ).
    DATA(lv_max_rows) = COND i( WHEN lv_top = if_rap_query_paging=>page_size_unlimited
                                THEN 0 ELSE lv_top ).

    " 2. Identify which Entity the UI is requesting
    DATA(lv_entity_id) = io_request->get_entity_id( ).

    " 3. Get all filters passed from the UI
    DATA(lt_filters) = io_request->get_filter( )->get_as_ranges( ).

    CASE lv_entity_id.
      WHEN 'ZCE_SALESORDER'.
        DATA(lt_type_range) = VALUE #( lt_filters[ name = 'SALESORDER' ]-range OPTIONAL ).
        IF io_request->is_data_requested( ).
          SELECT * FROM zc_salesordhdr
            WHERE Salesorder IN @lt_type_range
            ORDER BY Salesorder
            INTO TABLE @DATA(lt_header_out)
            UP TO @lv_max_rows ROWS
            OFFSET @lv_skip.

          io_response->set_data( lt_header_out ).
        ENDIF.

        "Set total count for the Fiori 'All' tab badge
        IF io_request->is_total_numb_of_rec_requested( ).
          SELECT COUNT( * ) FROM zc_salesordhdr WHERE Salesorder IN @lt_type_range INTO @DATA(lv_header_count).
          io_response->set_total_number_of_records( lv_header_count ).
        ENDIF.

        " --- ITEM LOGIC ---

      WHEN 'ZI_SALESITEM_COPY'.
        " Extract Parent Key (SalesOrder) filter automatically passed by the framework
        DATA(lt_so_range) = VALUE #( lt_filters[ name = 'SALESORDER' ]-range OPTIONAL ).
        IF io_request->is_data_requested( ).
          SELECT * FROM zc_salesorditem " Your Item Source
            WHERE Salesorder IN @lt_so_range
            ORDER BY Salesorder, Salesitem
            INTO TABLE @DATA(lt_items_out)
            UP TO @lv_max_rows ROWS
            OFFSET @lv_skip.

          io_response->set_data( lt_items_out ).

        ENDIF.

        " Set total count for the Items tab/table
        IF io_request->is_total_numb_of_rec_requested( ).
          SELECT COUNT( * ) FROM zc_salesorditem WHERE Salesorder IN @lt_so_range INTO @DATA(lv_item_count).
          io_response->set_total_number_of_records( lv_item_count ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
