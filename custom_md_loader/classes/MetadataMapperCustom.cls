/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Custom mapping between source and target object fields based on json.
 *
 * */
public with sharing class MetadataMapperCustom extends MetadataMapperDefault {

    private String csFieldName;
    private String mdtFieldName;
  private Map<String,String> fieldsMap;

  public MetadataMapperCustom() {
    super();
  }

  /**
   * Maps the source fields with target fields.
   *
   * @param sFrom: source object, e.g. VAT_Settings__c
   * @param sFrom: target object, e.g. VAT_Settings__mdt
   * @param mapping: json mapping, e.g. {"Field_cs_1__c", "Field_mdt_1__c"}
   * */
  public override MetadataMappingInfo mapper(String sFrom, String sTo, String mapping) {
      try {
        fetchSourceMetadataAndRecords(sFrom, sTo, mapping);
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
    private void fetchSourceMetadataAndRecords(String csName, String mdtName, String mapping) {
    if(!mdtName.endsWith(AppConstants.MDT_SUFFIX)) {
            throw new MetadataMigrationException(Label.MSG_MDT_END + AppConstants.MDT_SUFFIX);
        }

        List<String> srcFieldNames = new List<String>();
        Map<String,DescribeFieldResult> srcFieldResultMap = new Map<String, DescribeFieldResult>();

        try {
          mappingInfo.setCustomSettingName(csName);
          mappingInfo.setCustomMetadadataTypeName(mdtName);

        DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(csName).getDescribe();
          Map<String, SObjectField> fields = objDef.fields.getMap();

          this.fieldsMap = JsonUtilities.getValuesFromJson(mapping);

          for(String fieldName: fieldsMap.keySet()) {
            srcFieldNames.add(fieldName);
            DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
            srcFieldResultMap.put(fieldName.toLowerCase(), fieldDesc);
        }

          String selectClause = 'SELECT ' + String.join(srcFieldNames, ', ') + ' ,Name ';
          String query = selectClause + ' FROM ' + csName + ' LIMIT 50000';

          List<sObject> recordList = Database.query(query);

      mappingInfo.setSrcFieldNames(srcFieldNames);
         mappingInfo.setRecordList(recordList);
         mappingInfo.setSrcFieldResultMap(srcFieldResultMap);
     }
    catch (Exception e) {
      System.debug('MetadataMapperCustom.Error Message=' + e.getMessage());
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
  public override boolean validate(){
    return true;
  }

  /**
   * Map for source-target field mapping
   *
   * */
    public override void mapSourceTarget() {
      mappingInfo.setCSToMDT_fieldMapping(this.fieldsMap);
    }

}