//
//  PreferencesControllerWindowController.m
//  TestProject
//
//  Created by Tobias Mende on 01.04.13.
//
//
#import <objc/runtime.h>
#import "PreferencesController.h"
#import "Document.h"
#import "NSUserDefaults+DefaultsColorSupport.h"

@implementation PreferencesController


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

# pragma mark Actions

- (IBAction) resetDefaults:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"backgroundColor"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"textColor"];
}

- (IBAction)updateDocuments:(id)sender {
    NSLog(@"updateDocuments Method is a legacy method (not needed due to cocoa bindings)");
//    NSArray *myWindows = [[NSApplication sharedApplication] windows];
//    for(NSWindow *window in myWindows) {
//        if([[window delegate] class ] == [Document class]) {
//            [(Document*)[window delegate] updateViewSettings];
//        }
//    }
}

# pragma mark Window Methods


- (void)windowDidLoad
{
    [super windowDidLoad];
    
}

- (void)windowWillClose:(id)sender {
    [[NSColorPanel sharedColorPanel] close];
}

#pragma mark Getter
- (NSColor*)backgroundColor {
    return [backgroundColor color];
}

-(NSColor*)textColor {
    return [fontColor color];
}

@end
