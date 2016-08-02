public class AppConstants {

    public static final String QUALIFIED_API_NAME_ATTRIBUTE = 'QualifiedApiName';
    public static final String FULL_NAME_ATTRIBUTE = 'FullName';
    public static final String LABEL_ATTRIBUTE = 'Label';
    public static final String DEV_NAME_ATTRIBUTE = 'DeveloperName';
    public static final String DESC_ATTRIBUTE = 'Description';
    public static final String MDT_SUFFIX = '__mdt';
    
    public static final String SELECT_STRING = 'Select type';
    
    
    //error messages
    public static final String FILE_MISSING = 'Please provide a comma seperated file.';
    public static final String EMPTY_FILE = 'CSV file is empty.';
    public static final String TYPE_OPTION_NOT_SELECTED = 'Please choose a valid custom metadata type.';
    public static final String HEADER_MISSING_DEVNAME_AND_LABEL = 'Header must contain atleast one of these two fields - '+ DEV_NAME_ATTRIBUTE + ', ' + LABEL_ATTRIBUTE +'.';
    public static final String INVALID_FILE_ROW_SIZE_DOESNT_MATCH = 'The number of field values does not match the number of header fields on line ';
}