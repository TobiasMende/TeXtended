//
//  Publication.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Publication : NSObject
- initWithXMLUrl:(NSURL*)url;
@property NSXMLNode *xml;
@property NSString *key;
@property NSMutableArray *authors;
@property NSString *title;
@property NSDate *mdate;
@property NSString *type;
@property NSString *bibtex;
@end
