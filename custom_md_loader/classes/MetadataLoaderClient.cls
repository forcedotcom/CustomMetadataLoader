/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
public class MetadataLoaderClient {

	/*********************************************************
	 * Desc        	This will create custom object and then migrate 
	 				Custom Settings data to Custom Metadata Types records as is
	 * @param      	Name of Custom Setting Api (VAT_Settings_CS__c)
	 * @param      	Name of Custom Metadata Types Api (VAT_Settings__mdt)	 
	 * @return	   
	 *********************************************************/
	public void migrateAsIsWithObjCreation() {
		MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
        loader.migrateAsIsWithObjCreation('VAT_Settings_CS__c', 'VAT_Settings__mdt');
    }

	/*********************************************************
	 * Desc        	Migrate Custom Settings data to Custom Metadata Types records as is
	 * @param      	Name of Custom Setting Api (VAT_Settings_CS__c)
	 * @param      	Name of Custom Metadata Types Api (VAT_Settings__mdt)	 
	 * @return	   
	 *********************************************************/
	public void migrateAsIsMapping() {
		MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
        loader.migrateAsIsMapping('VAT_Settings_CS__c', 'VAT_Settings__mdt');
    }

	/*********************************************************
	 * Desc     	Migrate Custom Settings data to Custom Metadata Types records if you have only 
	 *				one field mapping
	 * @param      	Name of Custom Setting Api.fieldName (VAT_Settings_CS__c.Active__c)  
	 * @param      	Name of Custom Metadata Types Api.fieldMame	 (VAT_Settings__mdt.IsActive__c) 
	 * @return	   
	 *********************************************************/
    public void migrateSimpleMapping() {
    	MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
        loader.migrateSimpleMapping('VAT_Settings_CS__c.Active__c', 'VAT_Settings__mdt.IsActive__c');
    }

	/*********************************************************
	 * Desc     	Migrate Custom Settings data to Custom Metadata Types records if you have only 
	 *				different Api names in Custom Settings and Custom Metadata Types
	 * @param      	Name of Custom Setting Api (VAT_Settings_CS__c)
	 * @param      	Name of Custom Metadata Types Api (VAT_Settings__mdt)
	 * @param      	Json Mapping (Sample below)
	 					{        
							"Active__c" : "IsActive__c",
							"Timeout__c" : "GlobalTimeout__c",        
							"EndPointURL__c" : "URL__c",
						}
							 					
	 * @return	   
	 *********************************************************/
    public void migrateCustomMapping() {
    	String jsonMapping = '{'+        
							'"Active__c" : "Active__c",'+
							'"Timeout__c" : "Timeout__c",'+        
							'"EndPointURL__c" : "EndPointURL__c",'+
						'};';
    	
    	MetadataLoader loader = MetadataLoaderFactory.getLoader(MetadataOpType.APEXWRAPPER);
        loader.migrateCustomMapping('VAT_Settings_CS__c', 'VAT_Settings__mdt', jsonMapping);
    }

    public void migrateMetatdataApex() {
    }

}
