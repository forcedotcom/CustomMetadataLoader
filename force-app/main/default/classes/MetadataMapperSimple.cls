/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Simple mapping between source and target object field.
 * This option is for use-cases where you have only one field in source/target.
 *
 * */
public with sharing class MetadataMapperSimple extends MetadataMapperDefault {

  private String csFieldName;
  private String mdtFieldName;

  public MetadataMapperSimple() {
    super();
  }

  /**
   * Maps the source fields with target fields.
   *
   * @param sFrom: source object, e.g. VAT_Settings__c.IsActive__c
   * @param sFrom: target object, e.g. VAT_Settings__mdt.Active__c
   * @param mapping: in this case, mapping is null
   * */
  public override MetadataMappingInfo mapper(String csName, String cmtName, String mapping) {
    fetchSourceMetadataAndRecords(csName, cmtName);
    mapSourceTarget();

    return mappingInfo;
  }

    /**
     * Fetches source object metadata and builds the mapping info
     */
  private void fetchSourceMetadataAndRecords(String csNameWithField, String mdtNameWithField) {
    try {
      List<String> srcFieldNames = new List<String>();
      Map<String,DescribeFieldResult> srcFieldResultMap = new Map<String, DescribeFieldResult>();

      String[] csArray = csNameWithField.split('\\.');
      String[] mdtArray = mdtNameWithField.split('\\.');

      mappingInfo.setCustomSettingName(csArray[0]);
      mappingInfo.setCustomMetadadataTypeName(mdtArray[0]);

      csFieldName = csArray[1];
      mdtFieldName = mdtArray[1];

      DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(csArray[0]).getDescribe();
      Map<String, SObjectField> fields = objDef.fields.getMap();
      DescribeFieldResult fieldDesc = fields.get(csFieldName).getDescribe();
      srcFieldResultMap.put(csFieldName.toLowerCase(), fieldDesc);

      srcFieldNames.add(csFieldName);

      String selectClause = 'SELECT ' + csArray[1] + ' ,Name ';
      String query = selectClause + ' FROM ' + csArray[0] + ' LIMIT 50000';
      List<sObject> recordList = Database.query(query);

      mappingInfo.setSrcFieldNames(srcFieldNames);
      mappingInfo.setRecordList(recordList);
      mappingInfo.setSrcFieldResultMap(srcFieldResultMap);

    }
    catch (Exception e) {
      System.debug('MetadataMapperSimple.Error Message=' + e.getMessage());
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

  public override void mapSourceTarget() {
    Map<String, String> csToMDT_fieldMapping = mappingInfo.getCSToMDT_fieldMapping();
    csToMDT_fieldMapping.put(csFieldName, mdtFieldName);
  }

}