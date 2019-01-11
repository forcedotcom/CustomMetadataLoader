/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Default mapping between source and target object fields based on json.
 * This assumes that source object and target object are having exactly same
 * fields metadata.
 *
 * */
public virtual with sharing class MetadataMapperDefault implements MetadataMapper {

  protected MetadataMappingInfo mappingInfo;
  private List<String> srcFieldNames;

  public MetadataMapperDefault() {
    this.mappingInfo = new MetadataMappingInfo();
  }

  /**
   * Maps the source fields with target fields.
   *
   * @param sFrom: source object
   * @param sFrom: target object
   * @param mapping: optional param, in this case, its null
   * */
  public virtual MetadataMappingInfo mapper(String sFrom, String sTo, String mapping) {
    try {
      mappingInfo.setCustomSettingName(sFrom);
      mappingInfo.setCustomMetadadataTypeName(sTo);

      fetchSourceMetadataAndRecords(sFrom);
      mapSourceTarget();
    }
    catch (Exception e) {
      throw e;
    }
    return mappingInfo;
  }

    /**
     * Fetches source object metadata and builds the mapping info
     */
  private void fetchSourceMetadataAndRecords(String customSettingApiName) {

    if(!mappingInfo.getCustomMetadadataTypeName().endsWith(AppConstants.MDT_SUFFIX)) {
      throw new MetadataMigrationException(Label.MSG_MDT_END + AppConstants.MDT_SUFFIX);
    }

    srcFieldNames = new List<String>();
    Map<String,DescribeFieldResult> srcFieldResultMap = new Map<String, DescribeFieldResult>();

    try {
      DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(customSettingApiName).getDescribe();
      Map<String, SObjectField> fields = objDef.fields.getMap();

      String selectFields = '';
      for(String fieldName : fields.keySet()) {
        DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
        String fieldQualifiedApiName = fieldDesc.getName();
        if(fieldQualifiedApiName.endsWith('__c')) {
          srcFieldNames.add(fieldQualifiedApiName);
        }
        srcFieldResultMap.put(fieldName.toLowerCase(), fieldDesc);

      }

      String selectClause = 'SELECT ' + String.join(srcFieldNames, ', ') + ' ,Name ';
      String query = selectClause + ' FROM ' + customSettingApiName  + ' LIMIT 50000';
      List<sObject> recordList = Database.query(query);

      mappingInfo.setSrcFieldNames(srcFieldNames);
      mappingInfo.setRecordList(recordList);
      mappingInfo.setSrcFieldResultMap(srcFieldResultMap);
    }
    catch (Exception e) {
      System.debug('MetadataMapperDefault.Error Message=' + e.getMessage());
      throw e;
    }
  }

  // TODO: Currently, this is not implemented (well defaulted to true), but I think
  // we should implement to validate the fields that are not supported by Custom Metadata Types.

  /**
   * Validate the fields between source and target object.
   * e.g. If source Custom Object is having a field of type 'masterdetail',
   * then we should flag it an error or warning?
   *
   * */
  public virtual boolean validate(){
    return true;
  }

  /**
   * Map for source-target field mapping
   *
   * */
  public virtual void mapSourceTarget() {
    Map<String, String> csToMDT_fieldMapping = mappingInfo.getCSToMDT_fieldMapping();
    for(String fieldName: srcFieldNames) {
      csToMDT_fieldMapping.put(fieldName, fieldName);
    }
  }

  public MetadataMappingInfo getMappingInfo() {
    return mappingInfo;
  }

}