//
//  DBLPSearchCompletionHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TMTBibTexEntry;
@protocol DBLPSearchCompletionHandler <NSObject>

@optional
- (void)executeCitation:(TMTBibTexEntry *)citation forBibFile:(NSString *)path;
- (void)dblpSearchAborted;
@end
