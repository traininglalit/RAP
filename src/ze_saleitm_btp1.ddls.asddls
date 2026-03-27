@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Entity CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZE_SALEITM_BTP1
  as select from ZI_SALEITM_BTP1
  association to parent ZR_SALEHDR_BTP1 as _header on $projection.Salesorder = _header.Salesorder
{
  key Salesorder,
  key Salesitem,
  key Itemuuid,
      Material,
      Batchnumber,
      Materialgroup,
      Refmaterial,
      Netitemamount,
      Currency,
      _header
}
