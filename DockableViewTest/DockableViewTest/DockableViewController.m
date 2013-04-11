//
//  DockableViewController.m
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DockableViewController.h"

@interface DockableViewController ()

@end

@implementation DockableViewController

-(id)init {
    NSLog(@"init");
    return [self initWithNibName:@"DockableView" bundle:nil];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isDocked = YES;
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)toggleDocking:(id)sender {
    if(self.isDocked) {
        NSWindow *old = [self.view window];
        NSRect newFrame = [old frame];
        initialSuperView = [self.view superview];
        secondWindow = [[NSWindow alloc] initWithContentRect:newFrame
                                                         styleMask:[old styleMask]
                                                           backing:NSBackingStoreBuffered
                                                             defer:YES];
        
        [secondWindow setContentView:self.view];
        [secondWindow setFrame:[old frame] display:NO];
        newFrame.origin.x += 100;
        newFrame.origin.y -= 50;
        [[self.view window] makeKeyAndOrderFront:self];
        [secondWindow setFrame:newFrame display:NO animate:YES];
        self.isDocked = NO;
    } else {
        [secondWindow setFrame:[[initialSuperView window ]frame] display:NO animate:YES];
        [initialSuperView addSubview:self.view];
        secondWindow = nil;
        self.isDocked = YES;
        [[self.view window] makeKeyAndOrderFront:self];
    }
}
- (IBAction)showDebugOutput:(id)sender {
}
@end
