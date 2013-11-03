//
//  ConsoleData.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@class DocumentModel, MessageCollection, DocumentController, ConsoleViewController;
@interface ConsoleData : NSObject {
}
@property (weak) DocumentModel *model;
@property (weak) DocumentController *documentController;

/** Flag for showing whether the console is active or not */
@property BOOL consoleActive;

@property BOOL compileRunning;

@property ConsoleViewController *viewController;

/** The messages extracted from the latex log */
@property (nonatomic) MessageCollection *consoleMessages;

@property CompileMode compileMode;
@end
