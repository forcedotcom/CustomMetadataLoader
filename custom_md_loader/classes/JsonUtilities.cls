/* 
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license. 
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */
 
/**
 * Utilities class for common manipulation of json format data
 *
 */
public with sharing class JsonUtilities {

    public class JsonUtilException extends Exception {}
    
    /**
    * This basic method takes a string formatted as json and returns a map<String,String>
    * containing the name/value pairs.  If the input is empty or is not formatted correctly
    * the method throws a JsonUtilException exception.
    **/
    Public static Map<String, String> getValuesFromJson(String jsonString) {
        Map<String, Object> jsonObjMap;
        Map<String, String> jsonMap = new Map<String, String>();
        if (String.isBlank(jsonString)){               
            throw new JsonUtilException(Label.ERROR_JSON_EMPTY);
        }
        try {                
            jsonObjMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            if(jsonObjMap == null || jsonObjMap.size() == 0) {
                throw new JsonUtilException(Label.ERROR_JSON_EMPTY);
            } else {
                for (String pKey : jsonObjMap.keySet() ) {
                    try {
                        String pVal = (String)jsonObjMap.get(pKey);
                        jsonMap.put(pKey, pVal);
                    } catch (exception e) {
                        throw new JsonUtilException(Label.ERROR_JSON_BAD_FORMAT, e);
                    }
                }
            }                    
            return jsonMap;
        } catch (Exception e) {
            throw new JsonUtilException(Label.ERROR_JSON_BAD_FORMAT, e);
        }   
    }
    

}