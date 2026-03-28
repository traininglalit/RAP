@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface CDS view for sales order hdr'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SALESORDHDR
  as select from zdb_salesordhdr
{
  key salesorder       as Salesorder,
      createdon        as Createdon,
      creationtime     as Creationtime,
      personname       as Personname,
      quotationdate    as Quotationdate,
      quotationbiddate as Quotationbiddate,
      documentdate     as Documentdate,
      documentcat      as Documentcat,
      transactiongrp   as Transactiongrp,
      salesordtype     as Salesordtype,
      orderreason      as Orderreason,
      warrantydate     as Warrantydate,
      netamount        as Netamount,
      currency         as Currency,
      totalamount      as Totalamount
}
