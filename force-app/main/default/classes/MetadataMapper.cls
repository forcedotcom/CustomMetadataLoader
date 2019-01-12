/*
 * Copyright (c) 2016, salesforce.com, inc.
 * All rights reserved.
 * Licensed under the BSD 3-Clause license.
 * For full license text, see LICENSE.txt file in the repo root  or https://opensource.org/licenses/BSD-3-Clause
 */

/**
 * Interface for mapping between source object and target object fields.
 * Implementation of this interface will handle the mapping between source
 * and target object fields.
 *
 * */
public interface MetadataMapper {

  /**
   * Maps the source fields with target fields.
   *
   * @param sFrom: source object
   * @param sFrom: target object
   * @param mapping: optional param, required for custom mapping in the form of json.
   * */
  MetadataMappingInfo mapper(String sFrom, String sTo, String mapping);

  // TODO: Currently, this is not implemented, but I think we should implement to
  // validate the fields that are not supported by Custom Metadata Types.

  /**
   * Validate the fields between source and target object.
   * e.g. If source Custom Object is having a field of type 'masterdetail',
   * then we should flag it an error or warning?
   *
   * */
  boolean validate();

  /**
   * Map for source-target field mapping
   *
   * */
  void mapSourceTarget();
}