/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class MetadataWrapperApiLoader extends MetadataLoader {
  private static MetadataService.MetadataPort port;

  public static MetadataService.MetadataPort getPort() {
    if (port == null) {
      port = new MetadataService.MetadataPort();
      port.sessionHeader = new MetadataService.SessionHeader_element();
      port.sessionHeader.sessionId = UserInfo.getSessionId();
    }
    return port;
  }

  public override void migrateAsIsWithObjCreation(String csName, String cmtName) {
    try{
      super.migrateAsIsWithObjCreation(csName, cmtName);
      MetadataMappingInfo mappingInfo = getMapper().getMappingInfo();

      if(!response.isSuccess()) {
        throw new MetadataMigrationException(Label.ERROR_OP_FAILED);
        return;
      }
      MetadataObjectCreator.createCustomObject(mappingInfo);
      MetadataObjectCreator.createCustomField(mappingInfo);

      migrate(mappingInfo);
    }
    catch (Exception e) {
      List<MetadataResponse.Message> messages = response.getMessages();
      if(messages == null) {
        messages = new List<MetadataResponse.Message>();
      }
      messages.add(new MetadataResponse.Message(300, e.getMessage()));
      response.setIsSuccess(false);
      response.setMessages(messages);

      return;
    }
    buildResponse();
  }

  public override void migrateAsIsMapping(String csName, String cmtName) {
    super.migrateAsIsMapping(csName, cmtName);
    buildResponse();
  }

  public override  void migrateSimpleMapping(String csNameWithField, String cmtNameWithField) {
    super.migrateSimpleMapping(csNameWithField, cmtNameWithField);
    buildResponse();
  }

  public override void migrateCustomMapping(String csName, String cmtName, String mapping) {
    super.migrateCustomMapping(csName, cmtName, mapping);
    buildResponse();
  }

  private void buildResponse() {
    if(response.IsSuccess()) {
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, Label.MSG_MIGRATION_COMPLETED));
      response.setIsSuccess(true);
      response.setMessages(messages);
    }
  }

  public override void migrate(MetadataMappingInfo mappingInfo) {
    System.debug('MetadataWrapperApiLoader.migrate -->');

    try {
      String devName;
      String label;
      Integer rowCount = 0;

      String cmdName = mappingInfo.getCustomMetadadataTypeName();
      Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();
      Map<String, String> srcTgtFieldsMap = mappingInfo.getCSToMDT_fieldMapping();

      MetadataService.Metadata[] customMetadataRecords = new MetadataService.Metadata[mappingInfo.getRecordList().size()];
      Map<String, String> fieldsAndValues = new Map<String, String>();

      for(sObject csRecord : mappingInfo.getRecordList()) {

        String typeDevName = cmdName.subString(0, cmdName.indexOf(AppConstants.MDT_SUFFIX));
        System.debug('typeDevName ->' + typeDevName);

        for(String csField : srcTgtFieldsMap.keySet()) {
          // Set Target, Source
          Schema.DescribeFieldResult descCSFieldResult = descFieldResultMap.get(csField.toLowerCase());

          if(descCSFieldResult.getType().name() == 'DATETIME') {

            if(csRecord.get(csField) != null) {
              Datetime dt = DateTime.valueOf(csRecord.get(csField));
              // TODO: Fetch date format from user pref?
              String formattedDateTime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
              fieldsAndValues.put(srcTgtFieldsMap.get(csField), formattedDateTime);
            }
          }
          else {
            fieldsAndValues.put(srcTgtFieldsMap.get(csField), String.valueOf(csRecord.get(csField)));
          }
        }

        if(csRecord.get(AppConstants.CS_NAME_ATTRIBUTE) != null) {
          fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE) );
          fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE) );
          fieldsAndValues.put(AppConstants.LABEL_ATTRIBUTE, (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE) );

          String strippedLabel = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE);
          String tempVal = strippedLabel.substring(0, 1);

          if(tempVal.isNumeric() || tempVal == '-') {
            strippedLabel = 'X' + strippedLabel;
          }

          System.debug('strippedLabel -> 1 *' + strippedLabel);
          strippedLabel = strippedLabel.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
          System.debug('strippedLabel -> 2 *' + strippedLabel);

          //default fullName to type_dev_name.label
          fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ strippedLabel);

          System.debug(AppConstants.FULL_NAME_ATTRIBUTE + ' ::: ' + typeDevName + '.' + strippedLabel);
        }
        customMetadataRecords[rowCount++] = transformToCustomMetadata(mappingInfo.getStandardFields(), fieldsAndValues);
      }
      upsertMetadataAndValidate(customMetadataRecords);

    }
    catch (Exception e) {
      System.debug('MetadataWrapperApiLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, e.getMessage()));

      response.setIsSuccess(false);
      response.setMessages(messages);

    }
  }

  /*
   * Transformation utility to turn the configuration values into custom metadata values
   * This method to modify Metadata is only approved for Custom Metadata Records. Note that the number of custom metadata
   * values which can be passed in one update has been increased to 200 values (just for custom metadata)
   * We recommend to create new type if more fields are needed.
   * Using https://github.com/financialforcedev/apex-mdapi
   */
  private MetadataService.CustomMetadata transformToCustomMetadata(Set<String> standardFields, Map<String, String> fieldsAndValues){
    MetadataService.CustomMetadata  customMetadata = new MetadataService.CustomMetadata();
    customMetadata.label = fieldsAndValues.get(AppConstants.LABEL_ATTRIBUTE);
    customMetadata.fullName = fieldsAndValues.get(AppConstants.FULL_NAME_ATTRIBUTE);
    customMetadata.description = fieldsAndValues.get(AppConstants.DESC_ATTRIBUTE);

    //custom fields
    MetadataService.CustomMetadataValue[] customMetadataValues = new List<MetadataService.CustomMetadataValue>();
    if(fieldsAndValues != null) {
      for (String fieldName : fieldsAndValues.keySet()) {
        if(!standardFields.contains(fieldName) && !AppConstants.FULL_NAME_ATTRIBUTE.equals(fieldName)){
          MetadataService.CustomMetadataValue cmRecordValue = new MetadataService.CustomMetadataValue();
          cmRecordValue.field=fieldName;
          cmRecordValue.value= fieldsAndValues.get(fieldName);
          customMetadataValues.add(cmRecordValue);
        }
      }
    }
    customMetadata.values = customMetadataValues;
    return customMetadata;
  }

  private void upsertMetadataAndValidate(MetadataService.Metadata[] records) {
    List<MetadataService.UpsertResult> results = getPort().upsertMetadata(records);
    if(results!=null) {
      for(MetadataService.UpsertResult upsertResult : results) {
        if(upsertResult==null || upsertResult.success) {
          continue;
        }
        // Construct error message and throw an exception
        if(upsertResult.errors!=null){
          List<String> messages = new List<String>();
          messages.add(
              (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
              'occured processing component ' + upsertResult.fullName + '.');
          for(MetadataService.Error error : upsertResult.errors){
            messages.add(error.message + ' (' + error.statusCode + ').' +
                ( error.fields!=null && error.fields.size()>0 ?
                    ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
          }
          if(messages.size()>0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.join(messages, ' ')));
            return;
          }
        }
        if(!upsertResult.success) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.ERROR_REQUEST_FAILED_NO_ERROR));
          return;
        }
      }
    }
  }

}
