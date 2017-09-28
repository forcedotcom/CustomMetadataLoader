/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public class CustomMetadataUploadController {
    static MetadataService.MetadataPort service = MetadataUtil.getPort();    
    
    private final Set<String> standardFieldsInHeader = new Set<String>();
    private List<String> nonSortedApiNames;
    
    public boolean showRecordsTable{get;set;}
    public String selectedType{get;set;}
    public Blob csvFileBody{get;set;}
    public SObject[] records{get;set;}
    public List<SelectOption> cmdTypes{public get;set;}
    public List<String> fieldNamesForDisplay{public get;set;}
    
    public CustomMetadataUploadController() {
        showRecordsTable = false;
        loadCustomMetadataMetadata();
        
        //No full name here since we don't want to allow that in the csv header. It is a generated field using type dev name and record dev name/label.
        standardFieldsInHeader.add(AppConstants.DEV_NAME_ATTRIBUTE);
        standardFieldsInHeader.add(AppConstants.LABEL_ATTRIBUTE);
        standardFieldsInHeader.add(AppConstants.DESC_ATTRIBUTE);
    }
    
    /**
      * Queries to find all custom metadata types in the org and make it available to the VF page as drop down
    */
    private void loadCustomMetadataMetadata(){
        List<SObject> entityDefinitions =[select QualifiedApiName from EntityDefinition where IsCustomizable =true];
        for(SObject entityDefinition : entityDefinitions){
            String entityQualifiedApiName = (String)entityDefinition.get(AppConstants.QUALIFIED_API_NAME_ATTRIBUTE);
            if(entityQualifiedApiName.endsWith(AppConstants.MDT_SUFFIX)){
                if(cmdTypes == null) {
                    cmdTypes = new List<SelectOption>();
                    cmdTypes.add(new SelectOption(AppConstants.SELECT_STRING, AppConstants.SELECT_STRING));
                }
                cmdTypes.add(new SelectOption(entityQualifiedApiName, entityQualifiedApiName));
            }
        }
    }
    
    public PageReference upsertCustomMetadata() {
        ApexPages.getMessages().clear();
        showRecordsTable = false;
        
        importCSVFileAndCreateUpdateCmdRecords();
        System.debug(ApexPages.getMessages());
        if(ApexPages.getMessages().size() > 0) {
            if(!(ApexPages.getMessages().size() == 1 && ApexPages.getMessages()[0].getDetail().contains('DUPLICATE_DEVELOPER_NAME'))) {
             return null;
            }
        }
        
	//reset the file variable
        csvFileBody = null;

        if(nonSortedApiNames == null) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,
                                                 'Insert/Update was successful but something went wrong fetching the records.');
            ApexPages.addMessage(errorMessage);
            return null;
        }
        
        fieldNamesForDisplay = new List<String>();
        String selectQuery = 'SELECT ';
        Integer count = 0;
        for(String selectField : nonSortedApiNames) {
            if(!selectField.equals(AppConstants.DESC_ATTRIBUTE)) { //not supported in soql
                if(count != 0) {
                    selectQuery = selectQuery + ', ';
                }
                selectQuery = selectQuery + selectField;
                fieldNamesForDisplay.add(selectField);
                count++;
        	}
        }
        selectQuery = selectQuery + ' FROM ' + selectedType;
        records = Database.query(selectQuery);
        showRecordsTable = true;
        return null;
    }
    
    public void importCSVFileAndCreateUpdateCmdRecords(){
        List<List<String>> fields;
        try{ 
           fields = CSVFileUtil.parseCSV(csvFileBody, false);
        } catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,
                                                 'An error has occured while importin data.'+
                                                 ' Please make sure input csv file is correct'  + 
                                                 '<br/>' + e.getMessage() + '<br/>' + e.getCause());
            ApexPages.addMessage(errorMessage);
            return;
        }
        
        if(ApexPages.getMessages().size() > 0) {
          return;
        }
        
        if(fields == null || (fields != null && fields.size() < 1)) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.EMPTY_FILE);
            ApexPages.addMessage(errorMessage);
            return;
        }
           
        if(selectedType == AppConstants.SELECT_STRING) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, Label.TYPE_OPTION_NOT_SELECTED);
            ApexPages.addMessage(errorMessage);
            return;
        }
        
        //validate header fields
        List<String> header = fields[0];
        /*if(!isHeaderValid(new Set<String>(header), selectedType)) {
            return;
        }*/
	// separated out columns as they were coming as string like: "DeveloperName;Label;Description;"
	// it would pass the conditions under isHeadervalid() 
	Set<String> columnSet = new Set<String>();
        
        for(String headerColumn :header) {
            if (headerColumn == null) {
                continue;
            }
            
            for (String column :headerColumn.split(';')) {
                columnSet.add(column);
            }
        }
        
        if(!isHeaderValid(columnSet, selectedType)) {
            return;
        }
        
        //transform to custom metadata - bulk size = 200 records
        Integer maxLoadSize = 200;
        for(Integer i = 1; i < fields.size(); i = i + maxLoadSize) {
            MetadataUtil.transformToCustomMetadataAndCreateUpdate(standardFieldsInHeader, subset(fields, i, maxLoadSize), header, selectedType, i);
        }
    }
    
    private boolean isHeaderValid(Set<String> fieldNamesInHeader, String selectedType) {
        //label or devName - atleast one of the two must be specified
        if(!fieldNamesInHeader.contains(AppConstants.DEV_NAME_ATTRIBUTE) && !fieldNamesInHeader.contains(AppConstants.LABEL_ATTRIBUTE)) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, AppConstants.HEADER_MISSING_DEVNAME_AND_LABEL);
            ApexPages.addMessage(errorMessage);
            return false;
        }
        
        System.debug(selectedType);
        
        
        
        Set<String> fieldApiNames = new Set<String>(standardFieldsInHeader);
        nonSortedApiNames = new List<String>(standardFieldsInHeader);
        
        DescribeSObjectResult objDef = Schema.getGlobalDescribe().get(selectedType).getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        
        for(String fieldName : fields.keySet()) {
            DescribeFieldResult fieldDesc = fields.get(fieldName).getDescribe();
            String fieldQualifiedApiName = fieldDesc.getName();
            
            if(fieldQualifiedApiName.endsWith('__c')){
                fieldApiNames.add(fieldQualifiedApiName);
                nonSortedApiNames.add(fieldQualifiedApiName);
            }
        }
        
        if(!fieldApiNames.containsAll(fieldNamesInHeader)) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Header must contain the api names of the fields. ' + '<br/>' + 
                                                                   'Fields allowed for this type: ' + nonSortedApiNames + '<br/>' +
                                                                   'Fields in file header: ' + fieldNamesInHeader);
            ApexPages.addMessage(errorMessage);
            return false;
        }
        return true;
    }
    
    //https://gist.github.com/fractastical/989792
    public static List<List<String>> subset(List<List<String>> list1, Integer startIndex, Integer count) {
        List<List<String>> returnList = new List<List<String>>();
        if(list1 != null && list1.size() > 0 && startIndex >= 0 && startIndex <= list1.size()-1 && count > 0){
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }
    
    //for tests
    public void setCsvBlobForTest(Blob file) {
        this.csvFileBody = file;
    }
    
    public void setSelectedTypeForTest(String selectedType) {
        this.selectedType = selectedType;
    }
}
