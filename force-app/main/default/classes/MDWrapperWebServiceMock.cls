/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
@isTest                        
global class MDWrapperWebServiceMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
           if(responseType == 'MetadataService.listMetadataResponse_element'){
               response.put('response_x', new MetadataService.listMetadataResponse_element()); 
           } else if (responseType == 'MetadataService.createMetadataResponse_element') {
                MetadataService.createMetadataResponse_element respElt =
                    new MetadataService.createMetadataResponse_element();
                respElt.result = new List<MetadataService.SaveResult>();
                MetadataService.SaveResult sr = new MetadataService.SaveResult();
                sr.success = true;
                respElt.result.add(sr);
                response.put('response_x', respElt);
        	} else if (responseType == 'MetadataService.upsertMetadataResponse_element') {
        		MetadataService.upsertMetadataResponse_element respElt = new MetadataService.upsertMetadataResponse_element();
        		response.put('response_x', respElt);
        	}
   }
}