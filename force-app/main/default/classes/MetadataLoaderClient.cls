/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Please note this is just a sample usage class. You need to replace hard-coded
 * values with real values.
 *
 **/
public class MetadataLoaderClient {

  public void migrateMetatdataApex() {
  }

  /*********************************************************
   * Desc This will create custom object and then migrate Custom Settings data
   * to Custom Metadata Types records as is
   *
   * @param Name
   *            of Custom Setting Api (VAT_Settings_CS__c)
   * @param Name
   *            of Custom Metadata Types Api (VAT_Settings__mdt)
   * @return
   *********************************************************/
  public void migrateAsIsWithObjCreation(String csName, String mdtName) {
    MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
    loader.migrateAsIsWithObjCreation(csName, mdtName);
  }

  /*********************************************************
   * Desc Migrate Custom Settings data to Custom Metadata Types records as is
   *
   * @param Name
   *            of Custom Setting Api (VAT_Settings_CS__c)
   * @param Name
   *            of Custom Metadata Types Api (VAT_Settings__mdt)
   * @return
   *********************************************************/
  public void migrateAsIsMapping(String csName, String mdtName) {
    MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
    loader.migrateAsIsMapping(csName, mdtName);
  }

  /*********************************************************
   * Desc Migrate Custom Settings data to Custom Metadata Types records if you
   * have only one field mapping
   *
   * @param Name
   *            of Custom Setting Api.fieldName (VAT_Settings_CS__c.Active__c)
   * @param Name
   *            of Custom Metadata Types Api.fieldMame
   *            (VAT_Settings__mdt.IsActive__c)
   * @return
   *********************************************************/
  public void migrateSimpleMapping(String csNameWithField,
      String mdtNameWithField) {
    MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
    loader.migrateSimpleMapping(csNameWithField, mdtNameWithField);
  }

  /*********************************************************
   * Desc Migrate Custom Settings data to Custom Metadata Types records if you
   * have only different Api names in Custom Settings and Custom Metadata
   * Types
   *
   * @param Name
   *            of Custom Setting Api (VAT_Settings_CS__c)
   * @param Name
   *            of Custom Metadata Types Api (VAT_Settings__mdt)
   * @param Json
   *            Mapping (Sample below) { "Active__c" : "IsActive__c",
   *            "Timeout__c" : "GlobalTimeout__c", "EndPointURL__c" :
   *            "URL__c", }
   *
   * @return
   *********************************************************/
  public void migrateCustomMapping(String csName, String mdtName,
      String jsonMapping) {
    MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
    loader.migrateCustomMapping(csName, mdtName, jsonMapping);
  }

}