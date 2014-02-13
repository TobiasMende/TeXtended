//
//  MessageCoordinator.h
//  TeXtended
//
//  Created by Tobias Mende on 13.02.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@interface MessageCoordinator : NSObject {
    NSMutableDictionary *generatorToGlobalMessagesMap;
    NSMutableDictionary *generatorToLocalMessagesMap;
}

@property TMTLatexLogLevel logLevel;
+ (MessageCoordinator *)sharedMessageCoordinator;

- (NSArray *)messagesForMainDocumentPath:(NSString *)path;
- (NSArray *)messagesForPartialDocumentPath:(NSString *)path;
- (void)clearMessagesForPath:(NSString *)path;

@end
