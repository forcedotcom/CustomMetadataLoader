/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public with sharing class MetadataObjectCreator {

    static MetadataService.MetadataPort service = MetadataUtil.getPort();
	static String endPoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/40.0';    
    
	private static String objectRequestBodySnippet =
        '<?xml version="1.0" encoding="utf-8"?>' +
        '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
            '<env:Header>' +
                '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' +
                    '<urn:sessionId>{0}</urn:sessionId>' +
                '</urn:SessionHeader>' +
            '</env:Header>' +
            '<env:Body>' +
                '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    '<metadata xsi:type="CustomObject">' +
                        '<fullName>{1}</fullName>' +
                       // '<description>{2}</description>' +
 						'<label>{2}</label>' +
                        '<pluralLabel>{3}</pluralLabel>' +                        
                   '</metadata>' +
                '</createMetadata>' +
            '</env:Body>' +
        '</env:Envelope>';        

	private static String fieldRequestBodySnippet =
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '<env:Header>' +
                    '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' +
                        '<urn:sessionId>{0}</urn:sessionId>' +
                    '</urn:SessionHeader>' +
                '</env:Header>' +
                '<env:Body>' +
                    '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' +
                    	'{1}' +
                    '</createMetadata>' +
                '</env:Body>' +
            '</env:Envelope>';        
            
	private static String fieldRequestSnippet = 
			'<metadata xsi:type="CustomField">' +
				'<fullName>{0}</fullName>' +
                '<type>{1}</type>' +
                '<label>{2}</label>' +
                '{3}' + // length
                '{4}' + // defaultValue
                '{5}' + //  precisionValue
            '</metadata>';
            
	private static String fieldLengthSnippet = 
			'<length>{0}</length>';
	private static String fieldDefaultValueSnippet = 
			'<length>{0}</length>';
			            
	public static void createCustomObject(MetadataMappingInfo mappingInfo) {
		try{
			System.debug('createCustomObject -->');
			String fullName = mappingInfo.getCustomMetadadataTypeName();
	
			System.debug('fullName ->' + fullName);
			String strippedLabel = fullName.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
	        System.debug('strippedLabel ->' + strippedLabel);
		                
	        String pluralLabel = fullName.subString(0, fullName.indexOf(AppConstants.MDT_SUFFIX));
	        
			String label = pluralLabel;
	        pluralLabel = pluralLabel + 's'; 
	        
	        System.debug('label ->' + label);
	        System.debug('pluralLabel ->' + pluralLabel);
	
			String objectRequest = String.format(objectRequestBodySnippet, new String[]{UserInfo.getSessionId(), fullName, label, pluralLabel});
	        
			System.debug('objectRequest-->' + objectRequest);        
			HttpRequest httpReq = initHttpRequest('POST');
	        httpReq.setBody(objectRequest);
	        
		    httpReq.setEndpoint(endPoint);
	        System.debug('httpReq-->' + httpReq);
	        getResponse(httpReq);
        }
        catch(Exception e) {
        	throw e;
        }
    }
    
    public static void createCustomField(MetadataMappingInfo mappingInfo) {
    	try{
	    	System.debug('createCustomField -->');
	    	
			String fullName = mappingInfo.getCustomMetadadataTypeName();
	
			String strippedLabel = fullName.replaceAll('\\W+', '_').replaceAll('__+', '_').replaceAll('\\A[^a-zA-Z]+', '').replaceAll('_$', '');
	        System.debug('strippedLabel ->' + strippedLabel);
	
			String fieldFullName 	= '';
			String label 			= '';
	        String type_x 			= '';
			String length_x 		= '';           
	        String defaultValue 	= '';
	        String precisionValue 	= '';
	        
	        String fieldRequest 	= '';
	        String reqBody 			= '';
	        
	        Map<String, Schema.DescribeFieldResult> descFieldResultMap = mappingInfo.getSrcFieldResultMap();
	        System.debug('descFieldResultMap-->' + descFieldResultMap);
	        
	        integer counter = 0;
	        for(String csField : mappingInfo.getCSToMDT_fieldMapping().keySet()) {
	        	if(mappingInfo.getCSToMDT_fieldMapping().get(csField).endsWith('__c')){
	        		length_x = '';
	        		
	        		System.debug('csField-->' + csField);
					Schema.DescribeFieldResult descCSFieldResult = descFieldResultMap.get(csField.toLowerCase());
					System.debug('descCSFieldResult-->' + descCSFieldResult);
					
	            	String cmtField = mappingInfo.getCSToMDT_fieldMapping().get(csField);
	            	
	            	System.debug('cmtField-->' + cmtField);
	            	System.debug('fullName--> 2' + fullName);
	            	
	            	fieldFullName = fullName + '.' + cmtField;
	            	System.debug('fieldFullName--> 3' + fieldFullName);
	            	label = descCSFieldResult.getLabel();
	            	type_x = getConvertedType(descCSFieldResult.getType().name());
	            	length_x = String.valueOf(descCSFieldResult.getLength());
	            	
	            	if(descCSFieldResult.getLength() != 0 ) {
	            		length_x = String.format(fieldLengthSnippet, new String[]{length_x});
	            	}
	            	else {
	            		length_x = '';
	            	}
	            	if(type_x == 'Checkbox') {
	            		defaultValue = '<defaultValue>' + descCSFieldResult.getDefaultValue() +'</defaultValue>';
	            	}
	            	else{
	            		defaultValue = '';
	            	}
	            	if(type_x == 'Number' || type_x == 'Percent') {
	            		precisionValue = '<precision>' + descCSFieldResult.getPrecision() +'</precision>' +
	            						'<scale>' + descCSFieldResult.getScale() +'</scale>';
	            	}
	            	else{
	            		precisionValue = '';
	            	}
	            	// Length is set to 80 for Email/Phone/URL fields but no length field?
	            	if(type_x == 'Email' || type_x == 'Phone' || type_x == 'URL' || type_x == 'Url' || type_x == 'TextArea' ) {
	            		length_x = '';
	            	}
	            	
			        fieldRequest = fieldRequest + String.format(fieldRequestSnippet, new String[]{fieldFullName, type_x, label, length_x, defaultValue, precisionValue});
			        
			        System.debug('fieldFullName-->' + fieldFullName);
			        System.debug('label-->' + label);
			        System.debug('type_x-->' + type_x);
			        System.debug('length_x-->' + length_x);
			        
			        if(counter == 9) {
			        	
			        	reqBody = String.format(fieldRequestBodySnippet, new String[]{UserInfo.getSessionId() , fieldRequest});
		        
				        System.debug('reqBody-->' + reqBody);        
						HttpRequest httpReq = initHttpRequest('POST');
				        httpReq.setBody(reqBody);
					    httpReq.setEndpoint(endPoint);
				        System.debug('httpReq-->' + httpReq);
				        getResponse(httpReq);
				        
			        	fieldRequest = '';
			        }
			        
			        counter++;
			        
	        	}
	    	}
	        System.debug('fieldRequest-->' + fieldRequest);
	    	
	    	if(fieldRequest != '') {
		        reqBody = String.format(fieldRequestBodySnippet, new String[]{UserInfo.getSessionId() , fieldRequest});
		        
		        System.debug('reqBody-->' + reqBody);        
				HttpRequest httpReq = initHttpRequest('POST');
		        httpReq.setBody(reqBody);
			    httpReq.setEndpoint(endPoint);
		        System.debug('httpReq-->' + httpReq);
		        getResponse(httpReq);
	        }
		}
        catch(Exception e) {
        	throw e;
        }	        
    }
    
    private static HttpRequest initHttpRequest(String httpMethod){
		HttpRequest req = new HttpRequest();
		req.setHeader('Accept', 'application/xml');
    	req.setHeader('SOAPAction','""');
        req.setHeader('Content-Type', 'text/xml');        
		req.setMethod(httpMethod);
		return req;		
	}

	private static String getResponse(HttpRequest request) {
		Http http = new Http();				
		HttpResponse response = new HttpResponse();
		
		response = http.send(request);
		
		System.debug('---- RESPONSE RECEIVED------');
		System.debug(response);
		
		if (response.getStatusCode() == 200 || response.getStatusCode() == 201){
            System.debug('Ok Received!');
		}
		else{
            System.debug('Error Received!');
		}
		String responseBody = response.getBody();
		System.debug('responseBody-->' + responseBody);
        
		return responseBody;
	}
      
      
	private static String getConvertedType(String type_x) {
		String newtType = 'Text';
		if(type_x == 'STRING') {
			newtType = 'Text';
		}
		else if(type_x == 'BOOLEAN') {
			newtType = 'Checkbox';
		}
		else if(type_x == 'DOUBLE' || type_x == 'INTEGER') {
			newtType = 'Number';
		}
		else if(type_x == 'PERCENT' || type_x == 'Percent') {
			newtType = 'Percent';
		}
		else if(type_x == 'DATETIME') {
			newtType = 'DateTime';
		}
		else if(type_x == 'DATE') {
			newtType = 'Date';
		}
		else if(type_x == 'TEXTAREA') {
			newtType = 'TextArea';
		}
		else if(type_x == 'PICKLIST') {
			newtType = 'Picklist';
		}
		else if(type_x == 'EMAIL') {
			newtType = 'Email';
		}
		else if(type_x == 'PHONE') {
			newtType = 'Phone';
		}
		else if(type_x == 'URL') {
			newtType = 'Url';
		}
		
		else { 
			newtType = type_x;
		} 
		
		return newtType;
	
	}
	      
}
