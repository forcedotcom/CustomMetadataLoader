/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
@isTest(SeeAllData=true)
public class CustomMetadataUploadControllerTest {
    
    public static testmethod void testUploadNoFile() {
		CustomMetadataUploadController ctrl = setup(null);
        invokeCreateCMAndValidateError(ctrl, Label.FILE_MISSING);
    }
    
    public static testmethod void testUploadEmptyFile() {
		CustomMetadataUploadController ctrl = setup(Blob.valueOf(''));
        invokeCreateCMAndValidateError(ctrl, Label.EMPTY_FILE);
    }
    
    public static testmethod void testSelectedTypeMissing() {
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('Text__c'), AppConstants.SELECT_STRING);
        invokeCreateCMAndValidateError(ctrl, Label.TYPE_OPTION_NOT_SELECTED);
    }
    
    public static testmethod void testInvalidHeaderMissingFields() {
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('Text__c'));
        invokeCreateCMAndValidateError(ctrl, AppConstants.HEADER_MISSING_DEVNAME_AND_LABEL);
    }
    
    public static testmethod void testInvalidHeaderWrongFields() {
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('Label,Text__c'));
        
        ctrl.upsertCustomMetadata();
        ApexPages.Message[] msgs=ApexPages.getMessages();
		System.assert(msgs.size() == 1);
        System.assert(msgs[0].getSummary().contains('Header must contain the api names of the fields.'), 'Actual message:' + msgs[0]);
    }
    
    public static testmethod void testCreateCustomMetadata() {
        String countryLabel = 'AmericaTest'+Math.random();
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('Label,CountryCode__c,CountryName__c\n'+countryLabel+',US,America'));
        
        ctrl.upsertCustomMetadata();
        
        ApexPages.Message[] msgs = ApexPages.getMessages();
        System.assert(msgs.size() == 0, 'Error messages:' + msgs);
    }
    
    public static testmethod void testCreateCustomMetadataWithDevName() {
        String countryLabel = 'AmericaTest'+Math.random();
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('DeveloperName,CountryCode__c,CountryName__c\n'+countryLabel+',US,America'));
        
        ctrl.upsertCustomMetadata();
        
        ApexPages.Message[] msgs = ApexPages.getMessages();
        System.assert(msgs.size() == 0, 'Error messages:' + msgs);
    }
    
    public static testmethod void testInvalidFileRowSizeDoesntMatch() {
        String countryLabel = 'AmericaTest'+Math.random();
		CustomMetadataUploadController ctrl = setup(Blob.valueOf('DeveloperName,CountryCode__c,CountryName__c\n'+countryLabel+',US'));
        
        invokeCreateCMAndValidateError(ctrl, System.Label.INVALID_FILE_ROW_SIZE_DOESNT_MATCH + '1');
    }
    
    static CustomMetadataUploadController setup(Blob file) {
        return setup(file, 'CountryMapping__mdt');
    }

    static CustomMetadataUploadController setup(Blob file, String selectedType) {
        Test.setMock(WebServiceMock.class, new MDWrapperWebServiceMock());
        CustomMetadataUploadController ctrl = new CustomMetadataUploadController();
        ctrl.setSelectedTypeForTest(selectedType);
        ctrl.setCsvBlobForTest(file);
        return ctrl;
    }
    
    static void invokeCreateCMAndValidateError(CustomMetadataUploadController ctrl, String errorMsg) {
        ctrl.upsertCustomMetadata();
        ApexPages.Message[] msgs = ApexPages.getMessages();
		System.assert(msgs.size() == 1);
        System.assert(msgs[0].getSummary().equals(errorMsg), 'Actual message:' + msgs[0]);
    }
}
