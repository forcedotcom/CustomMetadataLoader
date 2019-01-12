/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class MetadataApexApiLoader extends MetadataLoader {

  // TODO: MetadataDeployStatus: We may use in future to provide status on UI (polling or email)
  public MetadataDeployStatus mdDeployStatus {get;set;}
  // TODO: MetadataDeployCallback: We may use in future to provide status on UI (polling or email)
  public MetadataDeployCallback callback {get;set;}

  public MetadataApexApiLoader() {
    this.mdDeployStatus = new MetadataApexApiLoader.MetadataDeployStatus();
    this.callback = new MetadataDeployCallback();
  }

  public MetadataApexApiLoader.MetadataDeployStatus getMdDeployStatus() {
    return this.mdDeployStatus;
  }

  public MetadataApexApiLoader.MetadataDeployCallback getCallback() {
    return this.callback;
  }

  public override void migrateAsIsWithObjCreation(String csName, String cmtName) {
    List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    messages.add(new MetadataResponse.Message(100, Label.MSG_NOT_SUPPORTED));
    response.setIsSuccess(false);
    response.setMessages(messages);
  }

  public override void migrateAsIsMapping(String csName, String cmtName) {
    super.migrateAsIsMapping(csName, cmtName);
    buildResponse();
  }

  public override void migrateSimpleMapping(String csNameWithField, String cmtNameWithField) {
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
      messages.add(new MetadataResponse.Message(100, Label.MSG_MIGRATION_IN_PROGRESS + getMdDeployStatus().getJobId()));
      response.setIsSuccess(true);
      response.setMessages(messages);
    }
  }

  public override void migrate(MetadataMappingInfo mappingInfo) {
    System.debug('MetadataApexApiLoader.migrate -->');
    try {
      Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();
      String typeDevName = mappingInfo.getCustomMetadadataTypeName()
          .subString(0, mappingInfo.getCustomMetadadataTypeName().indexOf(AppConstants.MDT_SUFFIX));
      List<Metadata.CustomMetadata> records = new List<Metadata.CustomMetadata>();
      for(sObject csRecord : mappingInfo.getRecordList()) {

        Metadata.CustomMetadata customMetadataRecord = new Metadata.CustomMetadata();
        customMetadataRecord.values = new List<Metadata.CustomMetadataValue>();

        if(csRecord.get(AppConstants.CS_NAME_ATTRIBUTE) != null) {
          String strippedLabel = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE);
          String tempVal = strippedLabel.substring(0, 1);

          if(tempVal.isNumeric()) {
            strippedLabel = 'X' + strippedLabel;
          }
          strippedLabel = strippedLabel.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
          System.debug('strippedLabel ->' + strippedLabel);

          // default fullName to type_dev_name.label
          customMetadataRecord.fullName = typeDevName + '.'+ strippedLabel;
          customMetadataRecord.label = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBUTE);
        }
        for(String fieldName : mappingInfo.getCSToMDT_fieldMapping().keySet()) {
          Schema.DescribeFieldResult descCSFieldResult = descFieldResultMap.get(fieldName.toLowerCase());

          if(mappingInfo.getCSToMDT_fieldMapping().get(fieldName).endsWith('__c')) {
            Metadata.CustomMetadataValue cmv = new Metadata.CustomMetadataValue();
            cmv.field = mappingInfo.getCSToMDT_fieldMapping().get(fieldName);
            cmv.value = csRecord.get(fieldName);
            customMetadataRecord.values.add(cmv);
          }
        }
        records.add(customMetadataRecord);
      }

      callback.setMdDeployStatus(mdDeployStatus);

      Metadata.DeployContainer deployContainer = new Metadata.DeployContainer();
      for(Metadata.CustomMetadata record : records) {
        deployContainer.addMetadata(record);
      }

      // Enqueue custom metadata deployment
      Id jobId = Metadata.Operations.enqueueDeployment(deployContainer, callback);
      mdDeployStatus.setJobId(jobId);
    }
    catch (Exception e) {
      System.debug('MetadataApexApiLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, e.getMessage()));

      response.setIsSuccess(false);
      response.setMessages(messages);
    }
  }

  // TODO: Status is still a work in progress. In future, we may use this to provide
  // status on UI (polling or email)
  public class MetadataDeployStatus {
    public Id jobId {get;set;}
    public Metadata.DeployStatus deployStatus {get;set;}
    public boolean success {get;set;}

    public MetadataDeployStatus() {}

    public Id getJobId() {
      return this.jobId;
    }
    public void setJobId(Id jobId) {
      this.jobId = jobId;
    }

    public Metadata.DeployStatus getDeployStatus() {
      return this.deployStatus;
    }
    public void setDeployStatus(Metadata.DeployStatus deployStatus) {
      this.deployStatus = deployStatus;
    }

    public boolean getSuccess() {
      return this.success;
    }
    public void setSuccess(boolean success) {
      this.success = success;
    }
  }

  // TODO: Callback is still a work in progress. In future, we may use this to provide
  // status on UI (polling or email)
  public class MetadataDeployCallback implements Metadata.DeployCallback {

    public MetadataApexApiLoader.MetadataDeployStatus mdDeployStatus {get;set;}

    public void setMdDeployStatus(MetadataApexApiLoader.MetadataDeployStatus mdDeployStatus) {
      this.mdDeployStatus = mdDeployStatus;
    }

    public MetadataDeployCallback() {
    }

    public void handleResult(Metadata.DeployResult result,
        Metadata.DeployCallbackContext context) {

      if (result.status == Metadata.DeployStatus.Succeeded) {
        mdDeployStatus.setSuccess(true);
        mdDeployStatus.setDeployStatus(result.status);
      }
      else if (result.status == Metadata.DeployStatus.InProgress) {
        // Deployment In Progress
        mdDeployStatus.setSuccess(false);
        mdDeployStatus.setDeployStatus(result.status);
      }
      else {
        mdDeployStatus.setSuccess(false);
        mdDeployStatus.setDeployStatus(result.status);
        // Deployment was not successful
      }
    }
  }

}