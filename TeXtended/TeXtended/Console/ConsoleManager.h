//
//  ConsoleManager.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DocumentModel, ConsoleData;
@interface ConsoleManager : NSObject

@property NSMutableDictionary *consoles;
+ (ConsoleManager *)sharedConsoleManager;

- (ConsoleData *)consoleForModel:(DocumentModel *)model;
- (ConsoleData *)consoleForModel:(DocumentModel *)model byCreating:(BOOL)create;
- (void)removeConsoleForModel:(DocumentModel *)model;
@end
