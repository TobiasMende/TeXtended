//
//  ProgressWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 20.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressWindowController : NSWindowController
@property (strong) IBOutlet NSProgressIndicator *progressBar;
@property NSNumber *minValue;
@property NSNumber *maxValue;
@property NSNumber *value;

@property NSString *progressInfo;
@end
