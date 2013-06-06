//
//  ConsoleViewsController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

@interface ConsoleViewsController : NSViewController<DocumentControllerProtocol>

@property (weak) id<DocumentControllerProtocol> parent;
@property (strong) NSSet* children;
@property (weak) IBOutlet NSTabView *tabView;

@end
