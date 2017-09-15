/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public virtual with sharing class MetadataMapperDefault implements MetadataMapper {
    
    protected MetadataMappingInfo mappingInfo; // {get;set;} 
    private List<String> srcFieldNames;
     
    public MetadataMapperDefault() {
    	this.mappingInfo = new MetadataMappingInfo();
	}
    
    /**
     * sFrom: e.g. VAT_Settings__c
     * sTo: e.g. VAT_Settings__mdt
     * mapping: e.g. {}
     */ 
    public virtual MetadataMappingInfo mapper(String sFrom, String sTo, String mapping) {
    	try{
	        mappingInfo.setCustomSettingName(sFrom);
	        mappingInfo.setCustomMetadadataTypeName(sTo);
	
	    	fetchSourceMetadataAndRecords(sFrom);
			mapSourceTarget();
    	}
    	catch(Exception e) {
    		throw e;
    	}    	
    	return mappingInfo;
    }
    
    private void fetchSourceMetadataAndRecords(String customSettingApiName) {
    	
	 	if(!mappingInfo.getCustomMetadadataTypeName().endsWith(AppConstants.MDT_SUFFIX)){
            throw new MetadataMigrationException('Custom Metadata Types name should ends with ' + AppConstants.MDT_SUFFIX);
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
	            if(fieldQualifiedApiName.endsWith('__c')){
	                srcFieldNames.add(fieldQualifiedApiName);
	            }
	            srcFieldResultMap.put(fieldName.toLowerCase(), fieldDesc);
	            
	        }
	        
	        String selectClause = 'SELECT ' + String.join(srcFieldNames, ', ') + ' ,Name '; 
	        String query = selectClause + ' FROM ' + customSettingApiName;
	        List<sObject> recordList = Database.query(query);
	     	
			mappingInfo.setSrcFieldNames(srcFieldNames);
	     	mappingInfo.setRecordList(recordList);
	     	mappingInfo.setSrcFieldResultMap(srcFieldResultMap);
	    }
		catch(Exception e) {
			System.debug('MetadataMapperDefault.Error Message=' + e.getMessage());
			throw e;
		}     	
	}
    
    public virtual boolean validate(){
    	return true;
    }
    
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