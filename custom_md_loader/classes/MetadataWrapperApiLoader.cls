/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public with sharing class MetadataWrapperApiLoader extends MetadataLoader {
    static MetadataService.MetadataPort port;
    //public for testing purposes only;
    public static MetadataWrapperApiLoader.Status mdApiStatus = Status.NOT_CHECKED;
    
    //public for testing purposes
    public enum Status {
        NOT_CHECKED,
        AVAILABLE,
        UNAVAILABLE
    }
    
    public Boolean checkMetadataAPIConnection() {
        if (mdApiStatus == Status.NOT_CHECKED) {
            boolean success = true;
            MetadataService.FileProperties[] allCmdProps;
            try {
                MetadataService.MetadataPort service = getPort();
                List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
                MetadataService.ListMetadataQuery customMetadata = new MetadataService.ListMetadataQuery();
                customMetadata.type_x = 'CustomMetadata';
                queries.add(customMetadata);
                allCmdProps = service.listMetadata(queries, 40);
                mdApiStatus = Status.AVAILABLE;
            } catch (CalloutException e) {
                if (!e.getMessage().contains('Unauthorized endpoint, please check Setup')) {
                    throw e;
                }
                mdApiStatus = Status.UNAVAILABLE;
            }
        }
        return mdApiStatus == Status.AVAILABLE;
    }
    
    public static MetadataService.MetadataPort getPort() {
        if (port == null) {
            port = new MetadataService.MetadataPort();
            port.sessionHeader = new MetadataService.SessionHeader_element();
            port.sessionHeader.sessionId = UserInfo.getSessionId();
        }
        return port;
    }
    
    public override void migrateAsIsWithObjCreation(String csName, String cmtName) {
		super.migrateAsIsWithObjCreation(csName, cmtName);
		MetadataMappingInfo mappingInfo = getMapper().getMappingInfo();
		
		MetadataObjectCreator.createCustomObject(mappingInfo);
        MetadataObjectCreator.createCustomField(mappingInfo);
        
		migrate(mappingInfo);
	    
	    buildResponse();
    }
    
    public override void migrateAsIsMapping(String csName, String cmtName) {
    	super.migrateAsIsMapping(csName, cmtName);
    	buildResponse();
    }
    
    public override  void migrateSimpleMapping(String csNameWithField, String cmtNameWithField) {
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
    		messages.add(new MetadataResponse.Message(100, 'Migration Completed!'));
    		response.setIsSuccess(true);
    	    response.setMessages(messages);  
		}
    }
    
    public override void migrate(MetadataMappingInfo mappingInfo) {
    	System.debug('MetadataWrapperApiLoader.migrate -->');
    
    	try{
	        String devName;
	        String label;
	        Integer rowCount = 0;
	        
	 		String cmdName = mappingInfo.getCustomMetadadataTypeName();
			Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();		
	
			MetadataService.Metadata[] customMetadataRecords = new MetadataService.Metadata[mappingInfo.getRecordList().size()];
			Map<String, String> fieldsAndValues = new Map<String, String>();
	
	        for(sObject csRecord : mappingInfo.getRecordList()) {
	        
	            String typeDevName = cmdName.subString(0, cmdName.indexOf(AppConstants.MDT_SUFFIX));
	            System.debug('typeDevName ->' + typeDevName);
	        
	            Map<String, String> srcTgtFieldsMap = mappingInfo.getCSToMDT_fieldMapping();
	        	System.debug('srcTgtFieldsMap ->' + srcTgtFieldsMap);
	        	
	        	for(String csField : srcTgtFieldsMap.keySet()) {
	        		// Set Target, Source
	        		Schema.DescribeFieldResult descCSFieldResult = descFieldResultMap.get(csField.toLowerCase());
	        		System.debug('descCSFieldResult ->' + descCSFieldResult);
	        		System.debug('csField ->' + csField);
	        		System.debug('csRecord ->' + csRecord);
	        		
	        		if(descCSFieldResult.getType().name() == 'DATETIME') {
						
						System.debug('csRecord.get(csField) ->' + csRecord.get(csField));
						//System.debug('String.valueOf(csRecord.get(csField)) ->' + String.valueOf(csRecord.get(csField)));
						
						if(csRecord.get(csField) != null) {
							Datetime dt = DateTime.valueOf(csRecord.get(csField));
							System.debug('Datetime dt ->' + dt);
							String formattedDateTime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); // 12/22/2014 7:05 AM (MM/DD/YYYY HH:MM PERIOD)
							System.debug('formattedDateTime-->' + formattedDateTime);
							
							fieldsAndValues.put(srcTgtFieldsMap.get(csField), formattedDateTime);
						}
					}
					else{
	            		fieldsAndValues.put(srcTgtFieldsMap.get(csField), String.valueOf(csRecord.get(csField)));
            		}
	        	}
	        	
	            if(csRecord.get(AppConstants.CS_NAME_ATTRIBURE) != null) {
	                fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE) );
	                fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE) );
	                fieldsAndValues.put(AppConstants.LABEL_ATTRIBUTE, (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE) );
	                
	                String strippedLabel = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE);
	                String tempVal = strippedLabel.substring(0, 1);
	                
	                if(tempVal.isNumeric() || tempVal == '-') {
	                	strippedLabel = 'X' + strippedLabel;
	                }
	                
	                System.debug('strippedLabel -> 1 *' + strippedLabel);
	                strippedLabel = strippedLabel.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
	                System.debug('strippedLabel -> 2 *' + strippedLabel);
	                
	                //default fullName to type_dev_name.label
	                fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ strippedLabel);
	                
	                System.debug(AppConstants.FULL_NAME_ATTRIBUTE + ' ::: ' + typeDevName + '.' + strippedLabel);
	            }
	            System.debug('fieldsAndValues ->' + fieldsAndValues);
	            
	            customMetadataRecords[rowCount++] = transformToCustomMetadata(mappingInfo.getStandardFields(), fieldsAndValues);
	        }
	        upsertMetadataAndValidate(customMetadataRecords);
	        
        }
        catch(Exception e) {
        	System.debug('Error Message=' + e.getMessage());
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, e.getMessage()));
        
    		response.setIsSuccess(false);
    	    response.setMessages(messages);  
        
        }
    }
    
    /*
     * Transformation utility to turn the configuration values into custom metadata values
     * This method to modify Metadata is only approved for Custom Metadata Records. Note that the number of custom metadata 
     * values which can be passed in one update has been increased to 200 values (just for custom metadata)
     * We recommend to create new type if more fields are needed.
     * Using https://github.com/financialforcedev/apex-mdapi
     */
    private MetadataService.CustomMetadata transformToCustomMetadata(Set<String> standardFields, Map<String, String> fieldsAndValues){
        MetadataService.CustomMetadata  customMetadata = new MetadataService.CustomMetadata();
        customMetadata.label = fieldsAndValues.get(AppConstants.LABEL_ATTRIBUTE);
        customMetadata.fullName = fieldsAndValues.get(AppConstants.FULL_NAME_ATTRIBUTE);
        customMetadata.description = fieldsAndValues.get(AppConstants.DESC_ATTRIBUTE);
        
        System.debug('customMetadata.label->' + customMetadata.label);
        System.debug('customMetadata.fullName->' + customMetadata.fullName);
        System.debug('customMetadata.description->' + customMetadata.description);
        
        
        //custom fields
        MetadataService.CustomMetadataValue[] customMetadataValues = new List<MetadataService.CustomMetadataValue>();
        if(fieldsAndValues != null){
            for (String fieldName : fieldsAndValues.keySet()) {
                if(!standardFields.contains(fieldName) && !AppConstants.FULL_NAME_ATTRIBUTE.equals(fieldName)){
                    MetadataService.CustomMetadataValue cmRecordValue = new MetadataService.CustomMetadataValue();
                    cmRecordValue.field=fieldName;
                    cmRecordValue.value= fieldsAndValues.get(fieldName);
                    customMetadataValues.add(cmRecordValue);
                }
            }
        }
        customMetadata.values = customMetadataValues;
        
        System.debug('customMetadata ->' + customMetadata);
        
        return customMetadata;
    }
    
    
    private void upsertMetadataAndValidate(MetadataService.Metadata[] records) {
        List<MetadataService.UpsertResult> results = getPort().upsertMetadata(records);
        if(results!=null){
            for(MetadataService.UpsertResult upsertResult : results){
                if(upsertResult==null || upsertResult.success){
                     continue;
                }
                // Construct error message and throw an exception
                if(upsertResult.errors!=null){
                    List<String> messages = new List<String>();
                    messages.add(
                        (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
                            'occured processing component ' + upsertResult.fullName + '.');
                    for(MetadataService.Error error : upsertResult.errors){
                        messages.add(error.message + ' (' + error.statusCode + ').' + 
                                     ( error.fields!=null && error.fields.size()>0 ? 
                                      ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
                    }
                    if(messages.size()>0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.join(messages, ' ')));
                        return;
                    }
                }
                if(!upsertResult.success){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Request failed with no specified error.'));
                    return;
                }
            }
        }
    }
}
