/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public class MetadataUtil {
    static MetadataService.MetadataPort port;
    //public for testing purposes only;
    public static MetadataUtil.Status mdApiStatus = Status.NOT_CHECKED;
    
    //public for testing purposes
    public enum Status {
        NOT_CHECKED,
        AVAILABLE,
        UNAVAILABLE
    }
    
    public static Boolean checkMetadataAPIConnection() {
        if (mdApiStatus == Status.NOT_CHECKED) {
            boolean success = true;
            MetadataService.FileProperties[] allCmdProps;
            try {
                MetadataService.MetadataPort service = getPort();
                List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
                MetadataService.ListMetadataQuery customMetadata = new MetadataService.ListMetadataQuery();
                customMetadata.type_x = 'CustomMetadata';
                queries.add(customMetadata);
                allCmdProps = service.listMetadata(queries, 34);
                mdApiStatus = Status.AVAILABLE;
            } catch (CalloutException e) {
                if (!e.getMessage().contains(AppConstants.ERROR_UNAUTHORIZED_ENDPOINT)) {
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
    
    public static void transformToCustomMetadataAndCreateUpdate(Set<String> standardFields, List<List<String>> fieldValues, List<String> header, String selectedType, Integer startIndex) {
        String devName;
        String label;
        Integer rowCount = 0;
        
        if (fieldValues == null)
        {
        	ApexPages.Message errMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'Field Values null');
        	ApexPages.addMessage(errMessage);
        	return;
        }
        MetadataService.Metadata[] customMetadataRecords = new MetadataService.Metadata[fieldValues.size()];
        // separated out columns as they were coming as string like: "DeveloperName;Label;Description;"
	       // it would pass the conditions under isHeadervalid() 
        Set<String> fieldNameSet = new Set<String>();  
        for (String fieldNames :header) {
            if (String.isBlank(fieldNames)) {
                continue;
            }

            fieldNameSet.addAll(fieldNames.split(';'));
        }

        for(List<String> singleRowOfValues : fieldValues) {
            if(header != null && header.size() != singleRowOfValues.size()) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.INVALID_FILE_ROW_SIZE_DOESNT_MATCH + 
                                                                       (startIndex + rowCount));
                ApexPages.addMessage(errorMessage);
                return;
            }
            
            Integer index = 0;
            String typeDevName = selectedType.subString(0, selectedType.indexOf(AppConstants.MDT_SUFFIX));
            Map<String, String> fieldsAndValues = new Map<String, String>();
        
            // separated out field values as they were coming as string like: "XXX;YYY;ZZZZ;"
            List<String> fieldValueList = new List<String>();

            for (String singleRowFieldValues :singleRowOfValues) {
                if (String.isBlank(singleRowFieldValues)) {
                    continue;
                }
            
                fieldValueList.addAll(singleRowFieldValues.split(';'));
            }
            for(String fieldName : fieldNameSet) {
                if(fieldName.equals(AppConstants.DEV_NAME_ATTRIBUTE)) {
		    if (fieldValueList.size() > index) {
                        fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ fieldValueList.get(index));
			     
                        //adding dev_name here since we might need it to default label
                        fieldsAndValues.put(fieldName, fieldValueList.get(index));
		    }
                } else {
                    if (fieldValueList.size() > index) {
                        fieldsAndValues.put(fieldName, fieldValueList.get(index));
                    }
                	//fieldsAndValues.put(fieldName, singleRowOfValues.get(index));
                }
                index++;
            }
            
            if(fieldsAndValues.get(AppConstants.FULL_NAME_ATTRIBUTE) == null) {
                String strippedLabel = fieldsAndValues.get(AppConstants.LABEL_ATTRIBUTE).replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
                //default fullName to type_dev_name.label
                fieldsAndValues.put(AppConstants.FULL_NAME_ATTRIBUTE, typeDevName + '.'+ strippedLabel);
            }else if(fieldsAndValues.get(AppConstants.LABEL_ATTRIBUTE) == null) {
                //default label to dev_name
                fieldsAndValues.put(AppConstants.LABEL_ATTRIBUTE, fieldsAndValues.get(AppConstants.DEV_NAME_ATTRIBUTE));
            }
            
            customMetadataRecords[rowCount++] = transformToCustomMetadata(standardFields, fieldsAndValues);
        }
        upsertMetadataAndValidate(customMetadataRecords);
    }
    
    /*
     * Transformation utility to turn the configuration values into custom metadata values
     * This method to modify Metadata is only approved for Custom Metadata Records. Note that the number of custom metadata 
     * values which can be passed in one update has been increased to 200 values (just for custom metadata)
     * We recommend to create new type if more fields are needed.
     * Using https://github.com/financialforcedev/apex-mdapi
     */
    private static MetadataService.CustomMetadata transformToCustomMetadata(Set<String> standardFields, Map<String, String> fieldsAndValues){
        MetadataService.CustomMetadata  customMetadata = new MetadataService.CustomMetadata();
        customMetadata.label = fieldsAndValues.get(AppConstants.LABEL_ATTRIBUTE);
        customMetadata.fullName = fieldsAndValues.get(AppConstants.FULL_NAME_ATTRIBUTE);
        customMetadata.description = fieldsAndValues.get(AppConstants.DESC_ATTRIBUTE);
        
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
        return customMetadata;
    }
    
    
    private static void upsertMetadataAndValidate(MetadataService.Metadata[] records) {
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
