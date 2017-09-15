/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public with sharing class MetadataMapperSimple extends MetadataMapperDefault {
    
    private String csFieldName;
    private String mdtFieldName;

	public MetadataMapperSimple() {
		super();
	}

    /**
     * sFrom: e.g. VAT_Settings__c.Field_Name_CS__c
     * sTo: e.g. VAT_Settings__mdt.Field_Name_MDT__c
     * mapping: e.g. null
     */ 
    public override MetadataMappingInfo mapper(String csName, String cmtName, String mapping) {
    	fetchSourceMetadataAndRecords(csName, cmtName);
		mapSourceTarget();
    	
    	return mappingInfo;
    }
    
    private void fetchSourceMetadataAndRecords(String csNameWithField, String mdtNameWithField) {
    	try{
	        List<String> srcFieldNames = new List<String>();
			Map<String,DescribeFieldResult> srcFieldResultMap = new Map<String, DescribeFieldResult>();
	        
	        System.debug('csNameWithField->' + csNameWithField);
	        System.debug('mdtNameWithField->' + mdtNameWithField);
	        
	        String[] csArray = csNameWithField.split('\\.');
	        String[] mdtArray = mdtNameWithField.split('\\.');
	        
	        mappingInfo.setCustomSettingName(csArray[0]);
	        mappingInfo.setCustomMetadadataTypeName(mdtArray[0]);
	        
	        System.debug('csArray->' + csArray);
	        System.debug('mdtArray->' + mdtArray);
	        
	        csFieldName = csArray[1];
	        mdtFieldName = mdtArray[1];
	        
	        DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(csArray[0]).getDescribe();
	        Map<String, SObjectField> fields = objDef.fields.getMap();
	        DescribeFieldResult fieldDesc = fields.get(csFieldName).getDescribe();
            srcFieldResultMap.put(csFieldName.toLowerCase(), fieldDesc);
	        
	        srcFieldNames.add(csFieldName);
	        
	        String selectClause = 'SELECT ' + csArray[1] + ' ,Name '; 
	        String query = selectClause + ' FROM ' + csArray[0];
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
    	System.debug('MetadataMapperSimple.mapSourceTarget -->');
    	
    	Map<String, String> csToMDT_fieldMapping = mappingInfo.getCSToMDT_fieldMapping();
    	csToMDT_fieldMapping.put(csFieldName, mdtFieldName);    	
    }
     
}