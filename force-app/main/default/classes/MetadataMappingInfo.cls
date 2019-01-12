/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class MetadataMappingInfo {

  private final Set<String> standardFields = new Set<String>();
  private String customSettingName;
  private String customMetadadataTypeName;

  private List<String> srcFieldNames;
  private List<sObject> recordList;
  private Map<String, Schema.DescribeFieldResult> srcFieldResultMap;

  private Map<String, String> csToMDT_fieldMapping = new Map<String, String>();

  public MetadataMappingInfo() {
    standardFields.add(AppConstants.DEV_NAME_ATTRIBUTE);
    standardFields.add(AppConstants.LABEL_ATTRIBUTE);
    standardFields.add(AppConstants.DESC_ATTRIBUTE);
  }

  public Set<String> getStandardFields() {
    return standardFields;
  }

  public List<String> getSrcFieldNames() {
    return srcFieldNames;
  }

  public List<sObject> getRecordList() {
    return recordList;
  }

  public void setSrcFieldNames(List<String> names) {
    this.srcFieldNames = names;
  }

  public void setRecordList(List<sObject> records) {
    this.recordList = records;
  }

  public Map<String, String> getCSToMDT_fieldMapping() {
    return this.csToMDT_fieldMapping;
  }

  public void setCSToMDT_fieldMapping(Map<String, String> csToMDT_fieldMapping) {
    this.csToMDT_fieldMapping = csToMDT_fieldMapping;
  }

  public String getCustomSettingName() {
    return this.customSettingName;
  }

  public void setCustomSettingName(String customSettingName) {
    this.customSettingName = customSettingName;
  }

  public String getCustomMetadadataTypeName() {
    return this.customMetadadataTypeName;
  }

  public void setCustomMetadadataTypeName(String customMetadadataTypeName) {
    this.customMetadadataTypeName = customMetadadataTypeName;
  }

  public Map<String, Schema.DescribeFieldResult> getSrcFieldResultMap() {
    return this.srcFieldResultMap;
  }

  public void setSrcFieldResultMap(Map<String, Schema.DescribeFieldResult> fieldResult) {
    this.srcFieldResultMap = fieldResult;
  }

}