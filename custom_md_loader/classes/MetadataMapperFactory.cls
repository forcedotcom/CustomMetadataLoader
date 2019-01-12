/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class MetadataMapperFactory {

  public static MetadataMapperDefault getMapper(MetadataMapperType mt) {
    MetadataMapperDefault mapper = null;
    if(mt == MetadataMapperType.ASIS) {
      mapper = new MetadataMapperDefault();
    }
    if(mt == MetadataMapperType.SIMPLE) {
      mapper = new MetadataMapperSimple();
    }
    else if(mt == MetadataMapperType.CUSTOM) {
      mapper = new MetadataMapperCustom();
    }
    return mapper;
  }

}