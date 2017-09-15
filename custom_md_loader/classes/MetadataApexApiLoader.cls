/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public with sharing class MetadataApexApiLoader extends MetadataLoader {

	public MetadataDeployStatus mdDeployStatus {get;set;}
	public MetadataDeployCallback callback {get;set;}
	
	public static Id jobId1 {get;set;}
	public static Metadata.DeployStatus deployStatus1 {get;set;}
	public static boolean success1 {get;set;}

    public MetadataApexApiLoader() {
    	this.mdDeployStatus = new MetadataApexApiLoader.MetadataDeployStatus();
    	this.callback = new MetadataDeployCallback(); 
    } 
    
    public MetadataApexApiLoader.MetadataDeployStatus getMdDeployStatus() {
    	return this.mdDeployStatus;
	}
	
	public MetadataApexApiLoader.MetadataDeployCallback getCallback() {
    	return this.callback;
	}
    
    public override void migrateAsIsWithObjCreation(String csName, String cmtName) {
		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
		messages.add(new MetadataResponse.Message(100, 'Not Supported!!!'));
		response.setIsSuccess(false);
	    response.setMessages(messages);  
    }
    
    public override void migrateAsIsMapping(String csName, String cmtName) {
    	super.migrateAsIsMapping(csName, cmtName);
    	buildResponse();
    }
    
    public override void migrateSimpleMapping(String csNameWithField, String cmtNameWithField) {
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
			messages.add(new MetadataResponse.Message(100, 'Migration In Progress... Job Id: ' + getMdDeployStatus().getJobId()));
			response.setIsSuccess(true);
		    response.setMessages(messages);  
		}
    }
    
    public override void migrate(MetadataMappingInfo mappingInfo) {
    	
    	System.debug('MetadataApexApiLoader.migrate -->');
    	try{
    		Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();
			String typeDevName = mappingInfo.getCustomMetadadataTypeName()
						.subString(0, mappingInfo.getCustomMetadadataTypeName().indexOf(AppConstants.MDT_SUFFIX));
	        List<Metadata.CustomMetadata> records = new List<Metadata.CustomMetadata>();            
			for(sObject csRecord : mappingInfo.getRecordList()) {
			
	            Metadata.CustomMetadata customMetadataRecord = new Metadata.CustomMetadata();
	            customMetadataRecord.values = new List<Metadata.CustomMetadataValue>();
	            
	            if(csRecord.get(AppConstants.CS_NAME_ATTRIBURE) != null) {
	            	String strippedLabel = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE);
	            	String tempVal = strippedLabel.substring(0, 1);
	                
	                if(tempVal.isNumeric()) {
	                	strippedLabel = 'X' + strippedLabel;
	                }
	            	strippedLabel = strippedLabel.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
	                System.debug('strippedLabel ->' + strippedLabel);
	                
	                // default fullName to type_dev_name.label
					customMetadataRecord.fullName = typeDevName + '.'+ strippedLabel;
					customMetadataRecord.label = (String)csRecord.get(AppConstants.CS_NAME_ATTRIBURE);
	            }
	            for(String fieldName : mappingInfo.getCSToMDT_fieldMapping().keySet()) {
		            Schema.DescribeFieldResult descCSFieldResult = descFieldResultMap.get(fieldName.toLowerCase());
	            
	            	if(mappingInfo.getCSToMDT_fieldMapping().get(fieldName).endsWith('__c')){
	        			Metadata.CustomMetadataValue cmv = new Metadata.CustomMetadataValue();
	                	cmv.field = mappingInfo.getCSToMDT_fieldMapping().get(fieldName);
	                	if(descCSFieldResult.getType().name() == 'DATETIME') {
	                	
	                		if(csRecord.get(fieldName) != null) {
								Datetime dt = DateTime.valueOf(csRecord.get(fieldName));
								String formattedDateTime = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); // 12/22/2014 7:05 AM (MM/DD/YYYY HH:MM PERIOD)
								cmv.value = csRecord.get(formattedDateTime);
							}
							else {
								cmv.value = null;
							}
							
						}
						else{
		            		cmv.value = csRecord.get(fieldName);
	            		}
	                	
	                	customMetadataRecord.values.add(cmv);
	            	}
	        	}
	            records.add(customMetadataRecord);
	        }
	            
			
		    callback.setMdDeployStatus(mdDeployStatus);
		    
			Metadata.DeployContainer deployContainer = new Metadata.DeployContainer();
			for(Metadata.CustomMetadata record : records) {
	        	deployContainer.addMetadata(record);
	        }
			
			// Enqueue custom metadata deployment
	    	Id jobId = Metadata.Operations.enqueueDeployment(deployContainer, callback);
	    	jobId1 = jobId;
	    	
	    	mdDeployStatus.setJobId(jobId);
	    	
	    	System.debug('jobId-->' + jobId);
	    	System.debug('mdDeployStatus-->' + mdDeployStatus);
	    	System.debug('mdDeployStatus.getJobId()-->' + mdDeployStatus.getJobId());
	    }
	    catch(Exception e) {
    		List<MetadataResponse.Message> messages = new List<MetadataResponse.Message>();
    		messages.add(new MetadataResponse.Message(100, e.getMessage()));
        
    		response.setIsSuccess(false);
    	    response.setMessages(messages);  
        }
    }
    
    
    	
	public class MetadataDeployStatus {
		public Id jobId {get;set;}
		public Metadata.DeployStatus deployStatus {get;set;}
		public boolean success {get;set;}
	
		public MetadataDeployStatus() {}
		
		public Id getJobId() {
			return this.jobId;
		}
		public void setJobId(Id jobId) {
			this.jobId = jobId;
		}
		
		public Metadata.DeployStatus getDeployStatus() {
			return this.deployStatus;
		}
		public void setDeployStatus(Metadata.DeployStatus deployStatus) {
			System.debug('setDeployStatus deployStatus ===>'+ deployStatus);
			this.deployStatus = deployStatus;
		}
		
		public boolean getSuccess() {
			return this.success;
		}
		public void setSuccess(boolean success) {
			System.debug('setDeployStatus success ===>'+ success);
			this.success = success;
		}
	
	}
	    
	public class MetadataDeployCallback implements Metadata.DeployCallback {
		
		public MetadataApexApiLoader.MetadataDeployStatus mdDeployStatus1 {get;set;}

		public void setMdDeployStatus(MetadataApexApiLoader.MetadataDeployStatus mdDeployStatus) {
			this.mdDeployStatus1 = mdDeployStatus;
		}
		
		public MetadataDeployCallback() {
		}
		
		public void handleResult(Metadata.DeployResult result,
		                             Metadata.DeployCallbackContext context) {

        	deployStatus1 = result.status;
        	success1 = result.success;

	        if (result.status == Metadata.DeployStatus.Succeeded) {
	        	
				mdDeployStatus1.setSuccess(true);
	        	mdDeployStatus1.setDeployStatus(result.status);
	        	
	        	System.debug(' ===>'+ result);
	        } 
	        else if (result.status == Metadata.DeployStatus.InProgress) {
	            // Deployment In Progress
	            
	            mdDeployStatus1.setSuccess(false);
	        	mdDeployStatus1.setDeployStatus(result.status);
	            
	            System.debug(' ===> fail '+ result);
	        } 
	        else {
	        	
	        	mdDeployStatus1.setSuccess(false);
	        	mdDeployStatus1.setDeployStatus(result.status);
	        	
	            // Deployment was not successful
	            System.debug(' ===> fail '+ result);
	        }
	        
	        /*if (result.success) {
	        	success = true;
	            System.debug(' ===>'+ result);
	        }
	        */
	         
		}
	}
	
	

}
