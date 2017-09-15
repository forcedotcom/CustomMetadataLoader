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
    	
    	System.debug('MetadataLoader.migrateAsIsObjCreation --> csName=' + csName);
    	System.debug('MetadataLoader.migrateAsIsObjCreation --> cmtName=' + cmtName);
    
    	MetadataMappingInfo mappingInfo = null;
    	try{
    		System.debug('MetadataLoader.migrateAsIsObjCreation --> 1');
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
    		mappingInfo = mapper.mapper(csName, cmtName, null);
    		System.debug('MetadataLoader.migrateAsIsObjCreation --> 2');
    	}
    	catch(Exception e) {
    		System.debug('Error Message=' + e.getMessage());
			List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name and Custom Metadata Types Api names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));            	
			messages.add(new MetadataResponse.Message(300, e.getMessage()));
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
     */
    public virtual void migrateAsIsMapping(String csName, String cmtName) {
    	
    	System.debug('MetadataLoader.migrateAsIsMapping --> csName=' + csName);
    	System.debug('MetadataLoader.migrateAsIsMapping --> cmtName=' + cmtName);
    
    	MetadataMappingInfo mappingInfo = null;
    	try{
    		System.debug('MetadataLoader.migrateAsIsMapping --> 1');
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.ASIS);
    		mappingInfo = mapper.mapper(csName, cmtName, null);
    		System.debug('MetadataLoader.migrateAsIsMapping --> 2');
    	}
    	catch(Exception e) {
    		System.debug('Error Message=' + e.getMessage());
			List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name and Custom Metadata Types Api names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));            	
			messages.add(new MetadataResponse.Message(300, e.getMessage()));
    	    response.setIsSuccess(false);
    	    response.setMessages(messages);      	
            return;	
    	}
    	System.debug('MetadataLoader.migrateAsIsMapping --> 3');
    	migrate(mappingInfo);
    	System.debug('MetadataLoader.migrateAsIsMapping --> 4');
    	
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
    	}
    	catch(Exception e) {
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name/Field Name and Custom Metadata Types/Field Name names are required!'));
    		messages.add(new MetadataResponse.Message(200, 'Please check the format, <Custom Setting>.<field> and <Custom Metadata Types>.<field>'));
			messages.add(new MetadataResponse.Message(300, 'Please check the Api names!'));            	
			messages.add(new MetadataResponse.Message(400, e.getMessage()));
    	    response.setIsSuccess(false);
    	    response.setMessages(messages);        	
            return;	
    	}
    
    	System.debug('mappingInfo.getStandardFields() ->' + mappingInfo.getStandardFields());
    	System.debug('mappingInfo ->' + mappingInfo.getSrcFieldNames());
    	System.debug('cmtNameAndField ->' + cmtNameAndField);
    	System.debug('mappingInfo.getSrcFieldResultMap() ->' + mappingInfo.getSrcFieldResultMap());
    	System.debug('mappingInfo.getCSToMDT_fieldMapping() ->' + mappingInfo.getCSToMDT_fieldMapping());
    
        migrate(mappingInfo);
    }
    
    /**
     *  This assumes that CS and MDT have the same API field names.
     *
     *  csName: Label, DeveloperName, Description (We might need it for migration)
     *  cmtName: e.g. VAT_Settings if mdt is 'VAT_Settings__mdt'
	 *  mapping: e.g. Json mapping between CS field Api and CMT field Api names     
     */
    public virtual void migrateCustomMapping(String csName, String cmtName, String mapping) {
    	System.debug('MetadataLoader.migrateCustomMapping -->');
    	MetadataMappingInfo mappingInfo = null; 
    	try{
    		mapper = MetadataMapperFactory.getMapper(MetadataMapperType.CUSTOM);
	    	mappingInfo = mapper.mapper(csName, cmtName, mapping);
	    	
	    	System.debug('MetadataLoader.migrateCustomMapping --> 2');
    	}
    	catch(Exception e) {
    		System.debug('MetadataLoader.migrateCustomMapping --> E' + e.getMessage());
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, 'Custom Setting Api Name, Custom Metadata Types Api and Json Mapping names are required!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Api names!'));
			messages.add(new MetadataResponse.Message(200, 'Please check the Json format!'));            	
			messages.add(new MetadataResponse.Message(300, 'Please check the Api names in Json!'));            	
			messages.add(new MetadataResponse.Message(400, e.getMessage()));
			response.setIsSuccess(false);
    	    response.setMessages(messages);  
            return;	
    	}
    	System.debug('MetadataLoader.migrateCustomMapping --> 3');
    	migrate(mappingInfo);
    	System.debug('MetadataLoader.migrateCustomMapping --> 4');
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
