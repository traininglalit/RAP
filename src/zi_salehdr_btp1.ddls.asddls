@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Intf CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SALEHDR_BTP1
  as select from zdb_salehdr_btp1
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
