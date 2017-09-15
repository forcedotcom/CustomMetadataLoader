/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public with sharing class MetadataMapperCustom extends MetadataMapperDefault {
    
    private String csFieldName;
    private String mdtFieldName;
	private Map<String,String> fieldsMap; 

	public MetadataMapperCustom() {
		super();
	}

    /**
     * sFrom: e.g. VAT_Settings__c.Field_Name_CS__c
     * sTo: e.g. VAT_Settings__mdt.Field_Name_MDT__c
     * mapping: e.g. {"Field_cs_1__c", "Field_mdt_1__c"}
     */ 
    public override MetadataMappingInfo mapper(String sFrom, String sTo, String mapping) {
    	fetchSourceMetadataAndRecords(sFrom, sTo, mapping);
		mapSourceTarget();
    	
    	return mappingInfo;
    }
    
    private void fetchSourceMetadataAndRecords(String csName, String mdtName, String mapping) {
        List<String> srcFieldNames = new List<String>();
        Map<String,DescribeFieldResult> srcFieldResultMap = new Map<String, DescribeFieldResult>();
        
        try{
	        mappingInfo.setCustomSettingName(csName);
	        mappingInfo.setCustomMetadadataTypeName(mdtName);
	    
	    	DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(csName).getDescribe();
	        Map<String, SObjectField> fields = objDef.fields.getMap();
	            
	        this.fieldsMap = JsonUtilities.getValuesFromJson(mapping);
	        System.debug('fieldsMap->' + fieldsMap);
	        
	        for(String fieldName: fieldsMap.keySet()) {
	        	srcFieldNames.add(fieldName);
	        	DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
	        	srcFieldResultMap.put(fieldName.toLowerCase(), fieldDesc);
	    	}
			System.debug('srcFieldNames->' + srcFieldNames);
			
	        String selectClause = 'SELECT ' + String.join(srcFieldNames, ', ') + ' ,Name '; 
	        String query = selectClause + ' FROM ' + csName;
	        
	        List<sObject> recordList = Database.query(query);
	     	
			mappingInfo.setSrcFieldNames(srcFieldNames);
	     	mappingInfo.setRecordList(recordList);
	     	mappingInfo.setSrcFieldResultMap(srcFieldResultMap);
        
        	System.debug(recordList);
 		}
		catch(Exception e) {
			System.debug('Error Message=' + e.getMessage());
			throw e;
		}     	        	
        
    }
    
    public override boolean validate(){
    	return true;
    }
    
    public override void mapSourceTarget() {
    	mappingInfo.setCSToMDT_fieldMapping(this.fieldsMap);
    }
     
}