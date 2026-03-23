@EndUserText.label: 'Abstract Entity for excel upload'
define root abstract entity ZAE_EXCELUPLOAD_BTP1
{
  @UI.hidden  : true
  uploadexcel : abap_boolean;
  _FileStream : association [1] to ZAE_FILESTREAM_BTP1 on 1 = 1;

}
