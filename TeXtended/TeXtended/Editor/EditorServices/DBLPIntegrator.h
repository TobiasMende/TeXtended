//
//  DBLPIntegrator.h
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"
#import "DBLPSearchCompletionHandler.h"
@class DBLPSearchViewController;
@interface DBLPIntegrator : EditorService<DBLPSearchCompletionHandler> {
    NSWindow *window;
    NSPopover *popover;
}
@property DBLPSearchViewController *vc;

- (void)initializeDBLPView;
- (void)dismissView;
@end
