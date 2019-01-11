/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public class CustomMetadataLoaderController {
	public String host {get; set;}
    public String metadataResponse {get; set;}
    public Boolean metadataConnectionWarning {get; set;}
    public String prefixOrLocal {get; set;}

    public PageReference checkMdApi() {
        
        if (MetadataUtil.checkMetadataAPIConnection()) {
            return continueToUploader();
        }
        // Get Host Domain
        host = ApexPages.currentPage().getHeaders().get('Host');
        // Get namespace prefix for picklist package or placeholder for pre-packaging
        prefixOrLocal = host.substringBefore('.').replaceAll('-', '_');
        metadataConnectionWarning = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to connect to the Salesforce Metadata API.'));
	    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'A Remote Site Setting must be created in your org before you can use this tool.'));
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Press the Create Remote Site Setting button to perform this step or refer to the post install step below to perform this manually.'));
        return null;
    }
    
    public PageReference continueToUploader() {
        return Page.CustomMetadataRecordUploader;
    }
    
    public PageReference displayMetadataResponse()
	{
    	// Display the response from the client side Metadata API callout
        if(metadataResponse.length()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Remote Site Setting dlrs_mdapi has been created.' ));
            metadataConnectionWarning = false;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, metadataResponse));
            metadataConnectionWarning = true;
        }
        return null;
	}
}