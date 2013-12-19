//
//  DBLPConfiguration.h
//  DBLP Tool
//
//  Created by Tobias Mende on 11.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The DBLPConfiguration class is a container for configuration of the connection and communication with the DBLP Server
 
 This class is designed as singleton and loads the confiuration from the plist file with the same name.
 
 **Author:** Tobias Mende
 
 */
@interface DBLPConfiguration : NSObject
/**
 Getter for the singleton
 
 @return the singleton instance
 */
+(DBLPConfiguration *)sharedInstance;

/**
 The url to the DBLP server
 */
@property NSString* server;

/** The extension for the server url when searching for author names */
@property NSString *authorSearchAppendix;

/** The extension for the server url when searching for an authors key */
@property NSString *keySearchAppendix;

/** The extension for the server url when fetching bibliography informations */
@property NSString *bibtexSearchAppendix;

- (BOOL)configIsValid;
@end
