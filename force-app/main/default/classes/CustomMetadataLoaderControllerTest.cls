/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
@IsTest
public class CustomMetadataLoaderControllerTest {

    public static testmethod void testCheckMdApiSucceeds() {
        CustomMetadataLoaderController cntlr = setup();
        PageReference result = cntlr.checkMdApi();
        System.assertEquals(Page.CustomMetadataRecordUploader.getUrl(), result.getUrl());
    }
    
    public static testmethod void testCheckMdApiFails() {
        CustomMetadataLoaderController cntlr = setup();
        ApexPages.currentPage().getHeaders().put('Host', 'na1.salesforce.com');
        MetadataUtil.mdApiStatus = MetadataUtil.Status.UNAVAILABLE;
        try {
            PageReference result = cntlr.checkMdApi();
            System.assertEquals(result, null);
            System.assertEquals('na1', cntlr.prefixOrLocal);
        } finally {
            MetadataUtil.mdApiStatus = MetadataUtil.Status.NOT_CHECKED;
        }
    }
    
    public static testmethod void testDisplayMetadataResponse() {
        CustomMetadataLoaderController cntlr = setup();
        cntlr.metadataResponse = '';
        cntlr.displayMetadataResponse();
        System.assert(!cntlr.metadataConnectionWarning);
        cntlr.metadataResponse = 'Danger, Will Robinson!';
        cntlr.displayMetadataResponse();
        System.assert(cntlr.metadataConnectionWarning);
    }
    
    static CustomMetadataLoaderController setup() {
        Test.setMock(WebServiceMock.class, new MDWrapperWebServiceMock());
        return new CustomMetadataLoaderController();
    }
}
