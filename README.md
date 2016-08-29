# Custom Metadata Loader

<a href="https://githubsfdeploy.herokuapp.com">
   <img alt="Deploy to Salesforce" 
		 src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

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

#How to deploy custom metadata loader
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
