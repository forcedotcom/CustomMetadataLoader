/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public virtual class MetadataLoader {

	public MetadataResponse response;
	public MetadataMapperDefault mapper; 
	
	public MetadataLoader() {
		response = new MetadataResponse(true, null, null); 
	}
	
	/**
     *  This will first create custom object and then migrates the records.
     *	This assumes that CS and MDT have the same API field names.
     *
     *  csName: Label, DeveloperName, Description (We might need it for migration)
     *  cmtName: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
     */
    public virtual void migrateAsIsWithObjCreation(String csName, String cmtName) {
    	
    	MetadataMappingInfo mappingInfo = null;
    	try{
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
    		mappingInfo = mapper.mapper(csName, cmtName, null);
    	}
    	catch(Exception e) {
    		System.debug('MetadataLoader.Error Message=' + e.getMessage());
			List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
			messages.add(new MetadataResponse.Message(100, 'Make sure Custom Setting exists in the org!'));
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name and Custom Metadata Types Api names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));            	
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
    	try{
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
    		mappingInfo = mapper.mapper(csName, cmtName, null);
	    	migrate(mappingInfo);
    	}
    	catch(Exception e) {
    		System.debug('MetadataLoader.Error Message=' + e.getMessage());
			List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
			messages.add(new MetadataResponse.Message(100, 'Make sure Custom Setting and Custom Metadata Types exists in the org!'));
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name and Custom Metadata Types Api names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));            	
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
    	try{
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.SIMPLE);
	    	mappingInfo = mapper.mapper(csNameAndField, cmtNameAndField, null);
	        migrate(mappingInfo);
    	}
    	catch(Exception e) {
    		System.debug('MetadataLoader.Error Message=' + e.getMessage());
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Make sure Custom Setting and Custom Metadata Types exists in the org!'));
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name/Field Name and Custom Metadata Types/Field Name names are required!'));
    		messages.add(new MetadataResponse.Message(200, 'Please check the format, <Custom Setting>.<field> and <Custom Metadata Types>.<field>'));
			messages.add(new MetadataResponse.Message(300, 'Please check the Api names!'));            	
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
    	try{
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.CUSTOM);
	    	mappingInfo = mapper.mapper(csName, cmtName, mapping);
	    	migrate(mappingInfo);
    	}
    	catch(Exception e) {
    		System.debug('MetadataLoader.Error Message=' + e.getMessage());
    		System.debug('MetadataLoader.migrateCustomMapping --> E' + e.getMessage());
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Make sure Custom Setting and Custom Metadata Types exists in the org!'));
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name, Custom Metadata Types Api and Json Mapping names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Json format!'));            	
			messages.add(new MetadataResponse.Message(300, 'Please check the Api names in Json!'));            	
			messages.add(new MetadataResponse.Message(400, e.getMessage()));
			response.setIsSuccess(false);
    	    response.setMessages(messages);  
            return;	
    	}
    }
    
    public virtual void migrate(MetadataMappingInfo mappingInfo) {
    	System.debug('MetadataLoader.migrate -->');
    }

	public MetadataMapperDefault getMapper() {
		return mapper;
	}
	
	public MetadataResponse getMetadataResponse() {
		return response;
	}
    
}
