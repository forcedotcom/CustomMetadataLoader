/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class MetadataLoaderFactory {

    public static MetadataLoader getLoader(MetadataOpType mt) {
      MetadataLoader loader = null;

    if(mt == MetadataOpType.APEXWRAPPER) {
      loader = new MetadataWrapperApiLoader();
    }
    if(mt == MetadataOpType.METADATAAPEX) {
      loader = new MetadataApexApiLoader();
    }
    return loader;
    }

}