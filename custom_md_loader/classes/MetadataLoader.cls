/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public virtual with sharing class MetadataLoader {

  public enum MetadataOpType { APEXWRAPPER, METADATAAPEX }

  public MetadataResponse response;
  public MetadataMapperDefault mapper;

  public MetadataLoader() {
    response = new MetadataResponse(true, null, null);
  }

  /**
   *  This will first create custom object and then migrates the records.
   *	This assumes that Custom Setting and MDT have the same API field names and
   *  same field data type.
   *  csName: Label, DeveloperName, Description (We might need it for migration)
   *  cmtName: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
   */
  public virtual void migrateAsIsWithObjCreation(String csName, String cmtName) {
    MetadataMappingInfo mappingInfo = null;
    try {
      mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
      mappingInfo = mapper.mapper(csName, cmtName, null);
    }
    catch (Exception e) {
      System.debug('MetadataLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, Label.MSG_CUSTOM_SETTINGS_EXISTS));
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_REQ));
      messages.add(new MetadataResponse.Message(200, Label.MSG_CHECK_API_NAMES));
      messages.add(new MetadataResponse.Message(300, e.getMessage()));
      response.setIsSuccess(false);
      response.setMessages(messages);
    }
  }

  /**
   *  This assumes that CS and MDT have the same API field names.
   *
   *  csName: Label, DeveloperName, Description (We might need it for migration)
   *  cmtName: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
   */
  public virtual void migrateAsIsMapping(String csName, String cmtName) {
    MetadataMappingInfo mappingInfo = null;
    try {
      mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
      mappingInfo = mapper.mapper(csName, cmtName, null);
      migrate(mappingInfo);
    }
    catch (Exception e) {
      System.debug('MetadataLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_EXISTS));
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_REQ));
      messages.add(new MetadataResponse.Message(200, Label.MSG_CHECK_API_NAMES));
      messages.add(new MetadataResponse.Message(300, e.getMessage()));
      response.setIsSuccess(false);
      response.setMessages(messages);
      return;
    }
  }

  /**
   *  csNameAndField: Label, DeveloperName, Description (We might need it for migration)
   *  cmtNameAndField: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
   */
  public virtual void migrateSimpleMapping(String csNameAndField, String cmtNameAndField) {
    MetadataMappingInfo mappingInfo = null;
    try {
      mapper = MetadataMapperFactory.getMapper(MetadataMapperType.SIMPLE);
      mappingInfo = mapper.mapper(csNameAndField, cmtNameAndField, null);
      migrate(mappingInfo);
    }
    catch (Exception e) {
      System.debug('MetadataLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_EXISTS));
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_FIELD_NAME_REQ));
      messages.add(new MetadataResponse.Message(200, Label.MSG_CS_MDT_FIELD_NAME_FORMAT));
      messages.add(new MetadataResponse.Message(300, Label.MSG_CHECK_API_NAMES));
      messages.add(new MetadataResponse.Message(400, e.getMessage()));
      response.setIsSuccess(false);
      response.setMessages(messages);
      return;
    }
  }

  /**
   *  This assumes that CS and MDT have the same API field names.
   *
   *  csName: Label, DeveloperName, Description (We might need it for migration)
   *  cmtName: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
   *  mapping: e.g. Json mapping between CS field Api and CMT field Api names
   */
  public virtual void migrateCustomMapping(String csName, String cmtName, String mapping) {
    MetadataMappingInfo mappingInfo = null;
    try {
      mapper = MetadataMapperFactory.getMapper(MetadataMapperType.CUSTOM);
      mappingInfo = mapper.mapper(csName, cmtName, mapping);
      migrate(mappingInfo);
    }
    catch (Exception e) {
      System.debug('MetadataLoader.Error Message=' + e.getMessage());
      List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_EXISTS));
      messages.add(new MetadataResponse.Message(100, Label.MSG_CS_MDT_MAPPING_REQ));
      messages.add(new MetadataResponse.Message(200, Label.MSG_CHECK_API_NAMES));
      messages.add(new MetadataResponse.Message(200, Label.MSG_JSON_FORMAT));
      messages.add(new MetadataResponse.Message(300, Label.MSG_JSON_API_NAMES));
      messages.add(new MetadataResponse.Message(400, e.getMessage()));
      response.setIsSuccess(false);
      response.setMessages(messages);
      return;
    }
  }

  public virtual void migrate(MetadataMappingInfo mappingInfo) {
  }

  public MetadataMapperDefault getMapper() {
    return mapper;
  }

  public MetadataResponse getMetadataResponse() {
    return response;
  }

}