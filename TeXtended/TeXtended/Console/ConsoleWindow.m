//
//  ConsoleWindow.m
//  TeXtended
//
//  Created by Tobias Mende on 13.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleWindow.h"
#import "ConsoleWindowController.h"

@implementation ConsoleWindow

    - (void)liveCompile:(id)sender
    {
        [self.controller refreshCompile];
    }


@end
