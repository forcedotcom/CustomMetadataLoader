/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
public with sharing class MetadataObjectCreator {

  private static MetadataService.MetadataPort service = MetadataUtil.getPort();
  // Supported data types during migration. If source custom setting or
  // source custom object has extra data types than below map, it will
  // not work. You can always use custom mapping approach in that case.
  public static final Map<DisplayType, String> displayTypeToTypeMap =
      new Map<DisplayType, String>{
        DisplayType.Boolean => 'Checkbox',
        DisplayType.Date => 'Date',
        DisplayType.DateTime => 'DateTime',
        DisplayType.Double => 'Number',
        DisplayType.Email => 'Email',
        DisplayType.EncryptedString => 'Text',
        DisplayType.Integer => 'Number',
        DisplayType.Percent => 'Number',
        DisplayType.Phone => 'Phone',
        DisplayType.Picklist => 'Picklist',
        DisplayType.String => 'Text',
        DisplayType.TextArea => 'TextArea',
        DisplayType.URL => 'Url'};

  public static void createCustomObject(MetadataMappingInfo mappingInfo) {
    try {
      String fullName = mappingInfo.getCustomMetadadataTypeName();

      String strippedLabel = fullName.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');

      String pluralLabel = fullName.subString(0, fullName.indexOf(AppConstants.MDT_SUFFIX));
      String label = pluralLabel;
      pluralLabel = pluralLabel + 's';

      MetadataService.CustomObject customObject = new MetadataService.CustomObject();
      customObject.fullName = fullName;
      customObject.label = label;
      customObject.pluralLabel = pluralLabel;
      List<MetadataService.SaveResult> results =
          service.createMetadata(
              new MetadataService.Metadata[] { customObject });
      handleSaveResults(results[0]);

    }
    catch (Exception e) {
      System.debug('createCustomOnbject.Exception-->' + e.getMessage());
      throw e;
    }
  }

  public static void createCustomField(MetadataMappingInfo mappingInfo) {
    try {
      String fullName = mappingInfo.getCustomMetadadataTypeName();

      String strippedLabel = fullName.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');

      String fieldFullName 	= '';
      String label 			= '';
      String type_x 			= '';

      Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();

      List<MetadataService.CustomField> customFields = new List<MetadataService.CustomField>();
      integer counter = 0;
      for(String csField : mappingInfo.getCSToMDT_fieldMapping().keySet()) {
        if(mappingInfo.getCSToMDT_fieldMapping().get(csField).endsWith('__c')){

          Schema.DescribeFieldResult descFieldResult = descFieldResultMap.get(csField.toLowerCase());
          String cmtField = mappingInfo.getCSToMDT_fieldMapping().get(csField);
          fieldFullName = fullName + '.' + cmtField;
          label = descFieldResult.getLabel();
          type_x = displayTypeToTypeMap.get(descFieldResult.getType());

          MetadataService.CustomField customField = new MetadataService.CustomField();
          customFields.add(customField);
          customField.fullName = fieldFullName;
          customField.label = label;
          customField.type_x = type_x;

          // Field datatype specifics
          if(type_x == 'Number' || type_x == 'Percent') {
            customField.precision = descFieldResult.getPrecision();
            customField.scale = descFieldResult.getScale();
          }
          if(type_x == 'Checkbox') {
            customField.defaultValue =
                descFieldResult.getDefaultValue() == null ? 'false' : String.valueOf(descFieldResult.getDefaultValue());
          }

          boolean lengthReq = true;
          if(descFieldResult.getLength() == 0
              || type_x == 'Email' || type_x == 'Phone'
              || type_x == 'URL' || type_x == 'Url'
              || type_x == 'TextArea' || type_x == 'Picklist') {
            lengthReq = false;
          }
          if(lengthReq && descFieldResult.getLength() != 0 ) {
            customField.length = descFieldResult.getLength();
          }
          if(type_x == 'Picklist') {
            customField.type_x = 'Picklist';
            Metadataservice.Picklist pt = new Metadataservice.Picklist();
            pt.sorted = false;
            List<MetadataService.PicklistValue> picklistValues = new List<MetadataService.PicklistValue>();
            for(Schema.PicklistEntry entry : descFieldResult.getPicklistValues()) {
              Metadataservice.PicklistValue picklistValue = new Metadataservice.PicklistValue();
              picklistValue.fullName = entry.getLabel();
              picklistValue.default_x = entry.isDefaultValue();
              picklistValues.add(picklistValue);
            }
            pt.picklistValues = picklistValues;
            customField.picklist = pt;
          }
          // process as batches of 10
          if(counter == 9) {
            List<MetadataService.SaveResult> results =
                service.createMetadata(customFields);
            handleSaveResults(results[0]);
            customFields.clear();
          }
          counter++;
        }
      }
      if(customFields.size() > 0) {
        List<MetadataService.SaveResult> results =
            service.createMetadata(customFields);
        handleSaveResults(results[0]);
        customFields.clear();
      }
    }
    catch (Exception e) {
      System.debug('createCustomField.Exception-->' + e.getMessage());
      throw e;
    }
  }

  /**
   * Example helper method to interpret a SaveResult, throws an exception if errors are found
   **/
  private static void handleSaveResults(MetadataService.SaveResult saveResult) {
    // Nothing to see?
    if(saveResult==null || saveResult.success)
      return;
    // Construct error message and throw an exception
    if(saveResult.errors!=null) {
      List<String> messages = new List<String>();
      messages.add(
          (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
          'occurred processing component ' + saveResult.fullName + '.');
      for(MetadataService.Error error : saveResult.errors)
        messages.add(
            error.message + ' (' + error.statusCode + ').' +
            ( error.fields!=null && error.fields.size()>0 ?
                ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
      if(messages.size()>0)
        throw new MetadataMigrationException(String.join(messages, ' '));
    }
    if(!saveResult.success)
      throw new MetadataMigrationException(Label.ERROR_REQUEST_FAILED_NO_ERROR);
  }

}