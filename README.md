# Using CLI Commands

Salesforce CLI commands for custom metadata types are available in v49. The custom metadata loader is no longer supported or maintained. As such, Salesforce does not guarantee the functionality or performance of the loader. 

The CLI commands simplify development and help you build automation and synchronize your source from scratch orgs when working with custom metadata types. CLI commands offer more functionality than the custom metadata loader. You can create custom metadata types, generate fields, create records, bulk insert records from a CSV file, and generate custom metadata types from an sObject. In addition, there's no limit on the number of records that can be loaded. 

See the following for more information:

* [Create and Manage Custom Metadata Types Using CLI](https://help.salesforce.com/articleView?id=custommetadatatypes_cli.htm)	
* [cmdt Commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_cmdt.htm#cli_reference_force_cmdt) 

# Custom Metadata Loader

<a href="https://githubsfdeploy.herokuapp.com">
   <img alt="Deploy to Salesforce"
		 src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

v 3.0
Custom Metadata tool now supports migration of Custom Settings or Custom Objects to Custom Metadata Types along with migration of records. If you already have Custom Metadata Type, then it can just migrate the Custom Settings/Custom Objects records.

v 2.0
The Custom Metadata loader tool now supports updates of existing custom metadata records. Load the csv file with updates to existing records, and use the tool the import and update the records.
# How to use custom metadata loader to update existing records

1. Please follow the instructions below to first load/create the records for the custom metadata type.
2. Now create a csv file with record values you want to update
2. Now select the CSV file and the corresponding custom metadata type.
5. Click 'Create/Update custom metadata' to bulk update the records from the CSV file into your org.


v 1.0
Custom metadata loader is a tool for creating custom metadata records from a csv file. Create custom metadata types in your Salesforce org using Metadata API and then use custom metadata loader to bulk load the records. Behind the scenes, custom metadata loader uses Metadata API to bulk load up to 200 records with a single call.

Custom metadata loader has a sample custom metadata type CountryMapping__mdt that allows users to map country codes to country names.

# How to deploy custom metadata loader
1. Download the folder custom_md_loader and zip all the files inside this folder. Package.xml should be at the top level of the zipped file.
2. Log in to your developer organization via workbench and deploy this zip file. (migration -> deploy)

# How to use custom metadata loader

1. Once you have deployed custom metadata loader in your org, assign the permission set 'Custom Metadata Loader' to the users who need to use the tool(See Step 2, 3 on how to assign the perm set)
   These users also need the 'Customize Application' to create Custom Metadata records. Admin should have this permission by default.
2. To apply the permission set - CustomMetadataLoader to the user who is using the tool. Go to Administer->Manage Users ->Permission Sets. Click on Custom Metadata Loader.
3  You will be taken to Permission Set page - Click on Manage Assignments. Then click Add Assignments. Choose the user/users. Then click Assign. Then Done. Now the perm set should be successfully assigned.
4. Create a CSV file with a header that contains the field API names, including the org namespace. Either Label or Developer Name is required. A sample csv for CountryMapping__mdt is in the same folder as this README file.
5. Next you are ready to use the tool - Select Custom Metadata Loader from the app menu in your org, then go to the Custom Metadata Loader tab.The app will prompt you to create a remote site setting if it is missing.
6. Select the CSV file and the corresponding custom metadata type.
7. Click 'Create/Update custom metadata' to bulk load the records from the CSV file into your org.

# How to use custom metadata migrator

Use one of the below option to migrate Custom Settings or Custom Objects to Custom Metadata Types. Go to the 'Custom Metadata Migrator' tab

### Option 1: Migrate Custom Settings/Custom Objects to new Custom Metadata Type

Input the following:

	--Api name of Custom Setting or Custom Object (e.g. VAT_Settings_CS__c)
	--Api name of Custom Metadata Types (e.g. VAT_Settings__mdt)

Click on 'Migrate'

### Option 2: Migrate Custom Settings/Custom Objects to existing Custom Metadata Type

Input the following:

	--Api name of Custom Setting (e.g. VAT_Settings_CS__c)
	--Select the name of existing Custom Metadata Types

Click on 'Migrate'

### Option 3: Migrate Custom Settings/Custom Objects to existing Custom Metadata Type (using simple mapping)

Input the following:

	--Api name of Custom Setting.fieldName (e.g. VAT_Settings_CS__c.Active__c)
	--Api name of Custom Metadata Types.fieldName (e.g. VAT_Settings__mdt.Active__c)

Click on 'Migrate'

### Option 4: Migrate Custom Settings/Custom Objects to existing Custom Metadata Type (using custom mapping)

Input the following:

	--Api Name of Custom Setting (e.g. VAT_Settings_CS__c)
	--Api Name of Custom Metadata Types (e.g. VAT_Settings__mdt)
	--Json Mapping (Sample below)
	{
		"Active__c" : "IsActive__c",
		"Timeout__c" : "GlobalTimeout__c",
	}
	Please note, key should be the Custom Setting/Object field name and that the value is the CMT field name.

Click on 'Migrate'

## Custom metadata migrator: more details

1. Custom metadata migrator provides two different options to do the migration:
	- Sync Operation: Migration will happen synchronously. Maximum 200 records can be migrated.
	- Async Operation: Migration will happen asynchronously. Maximum 50000 records can be migrated.
			To check the status of async migration, go to Deploy -> Deployment Status

2. Custom Metadata Types label and names
	- Custom Setting/Custom Object record name converted into Custom Metadata Types label and name.
	- Custom Setting name special character replaced with "_" in Custom Metadata Type names
	- If Custom Setting name starts with digit, then Custom Metadata Types name will be prepended with "X"

3. Custom Settings of type hierarchy not supported.

4. Custom Objects with field types not supported in Custom Metadata Types not supported.

5. Currency field on Custom Settings can't be migrated, you can use custom mapping to either avoid mapping or to map to another field.

