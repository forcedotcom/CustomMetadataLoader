/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public class MetadataMigrationController {
  static MetadataService.MetadataPort service = MetadataUtil.getPort();

  private final Set<String> standardFieldsInHeader = new Set<String>();
  private List<String> nonSortedApiNames;

  public boolean showRecordsTable{get;set;}
  public String selectedType{get;set;}
  public Blob csvFileBody{get;set;}
  public SObject[] records{get;set;}
  public List<SelectOption> cmdTypes{public get;set;}
  public String selectedOpTypeAsIs{get;set;}
  public String selectedOpTypeSimple{get;set;}
  public String selectedOpTypeCustom{get;set;}
  public List<SelectOption> opTypes{public get;set;}
  public List<SelectOption> objCreationOpTypes{public get;set;}

  public List<String> fieldNamesForDisplay{public get;set;}

  public String customSettingFromFieldAsIs{public get;set;}
  public String customSettingFromFieldSimple{public get;set;}
  public String cmdToFieldSimple{public get;set;}
  public String customSettingFromFieldJson{public get;set;}
  public String cmdToFieldJson{public get;set;}

  public String csFieldObjCreation {public get;set;}
  public String cmtFieldObjCreation {public get;set;}
  public String opTypeFieldObjCreation {public get;set;}

  public String csNameApexMetadata{public get;set;}
  public String cmdNameApexMetadata{public get;set;}
  public String jsonMappingApexMetadata{public get;set;}

  public String jsonMapping{public get;set;}

  public boolean asyncDeployInProgress{get;set;}

  public boolean isMessage {get;set;}

  public MetadataOpType opType = MetadataOpType.APEXWRAPPER;
  //public MetadataOpType opType = MetadataOpType.METADATAAPEX;

  public MetadataMigrationController() {

    service.timeout_x = 40000;

    isMessage = false;
    asyncDeployInProgress = false;

    showRecordsTable = false;
    loadCustomMetadataMetadata();

    //No full name here since we don't want to allow that in the csv header. It is a generated field using type dev name and record dev name/label.
    standardFieldsInHeader.add(AppConstants.DEV_NAME_ATTRIBUTE);
    standardFieldsInHeader.add(AppConstants.LABEL_ATTRIBUTE);
    standardFieldsInHeader.add(AppConstants.DESC_ATTRIBUTE);

    opTypes = new List<SelectOption>();
    opTypes.add(new SelectOption(MetadataOpType.APEXWRAPPER.name(), 'Sync Operation'));
    opTypes.add(new SelectOption(MetadataOpType.METADATAAPEX.name(), 'Async Operation'));

    objCreationOpTypes = new List<SelectOption>();
    objCreationOpTypes.add(new SelectOption(MetadataOpType.APEXWRAPPER.name(), 'Sync Operation'));

  }

  /**
   * Queries to find all custom metadata types in the org and make it available to the VF page as drop down
   */
  private void loadCustomMetadataMetadata(){
    List<SObject> entityDefinitions =[select QualifiedApiName from EntityDefinition where IsCustomizable =true];
    for(SObject entityDefinition : entityDefinitions){
      String entityQualifiedApiName = (String)entityDefinition.get(AppConstants.QUALIFIED_API_NAME_ATTRIBUTE);
      if(entityQualifiedApiName.endsWith(AppConstants.MDT_SUFFIX)) {
        if(cmdTypes == null) {
          cmdTypes = new List<SelectOption>();
          cmdTypes.add(new SelectOption(AppConstants.SELECT_STRING, AppConstants.SELECT_STRING));
        }
        cmdTypes.add(new SelectOption(entityQualifiedApiName, entityQualifiedApiName));
      }
    }
  }

  private void init(String selectedOpType) {
    opType = MetadataOpType.APEXWRAPPER;
    if(selectedOpType == MetadataOpType.METADATAAPEX.name()) {
      opType = MetadataOpType.METADATAAPEX;
    }
  }

  public PageReference migrateAsIsWithObjCreation() {
    init(opTypeFieldObjCreation);

    MetadataLoader loader = MetadataLoaderFactory.getLoader(opType);
    loader.migrateAsIsWithObjCreation(csFieldObjCreation, cmtFieldObjCreation);

    MetadataResponse response = loader.getMetadataResponse();

    if(response.isSuccess()) {
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }
    else {
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }

    return null;
  }

  public PageReference migrateAsIsMapping() {
    init(selectedOpTypeAsIs);

    MetadataLoader loader = MetadataLoaderFactory.getLoader(opType);
    loader.migrateAsIsMapping(customSettingFromFieldAsIs, selectedType);
    MetadataResponse response = loader.getMetadataResponse();

    if(response.isSuccess()) {
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }
    else {
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }

    return null;
  }

  public PageReference migrateSimpleMapping() {
    init(selectedOpTypeSimple);
    MetadataLoader loader = MetadataLoaderFactory.getLoader(opType);
    loader.migrateSimpleMapping(customSettingFromFieldSimple, cmdToFieldSimple);
    MetadataResponse response = loader.getMetadataResponse();
    if(response.isSuccess()) {
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }
    else{
      List<MetadataResponse.Message> messages = response.getMessages();
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }

    return null;
  }

  public PageReference migrateCustomMapping() {
    init(selectedOpTypeCustom);
    MetadataLoader loader = MetadataLoaderFactory.getLoader(opType);
    loader.migrateCustomMapping(customSettingFromFieldJson, cmdToFieldJson, jsonMapping);
    MetadataResponse response = loader.getMetadataResponse();
    List<MetadataResponse.Message> messages = response.getMessages();

    if(response.isSuccess()) {
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }
    else {
      for(MetadataResponse.Message message: messages) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, message.messageDetail);
        ApexPages.addMessage(msg);
      }
      isMessage = true;
    }

    return null;
  }

}