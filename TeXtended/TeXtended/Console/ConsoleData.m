//
//  ConsoleData.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleData.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "TMTNotificationCenter.h"
#import "TMTLog.h"
#import "MessageCollection.h"
#import "ConsoleViewController.h"

@implementation ConsoleData

- (id)init {
    self = [super init];
    if (self) {
        self.viewController = [ConsoleViewController new];
        self.viewController.console = self;
    }
    return self;
}



- (void)setConsoleMessages:(MessageCollection *)consoleMessages {
    if (consoleMessages != _consoleMessages) {
        _consoleMessages = consoleMessages;
        if (self.model && consoleMessages) {
            [[TMTNotificationCenter centerForCompilable:self.model] postNotificationName:TMTLogMessageCollectionChanged object:self.model userInfo:[NSDictionary dictionaryWithObject:self.consoleMessages forKey:TMTMessageCollectionKey]];
        }
    }
}


- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
