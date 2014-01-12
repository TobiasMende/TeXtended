//
//  MergeWindowController.m
//  TeXtended
//
//  Created by Tobias Hecht on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MergeWindowController.h"
#import "NSString+PathExtension.h"
#import <TMTHelperCollection/TMTLog.h>

@interface MergeWindowController ()

@end

@implementation MergeWindowController

-(id)init
{
    self = [super initWithWindowNibName:@"MergeWindow"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString*)getMergedContentOfFile:(NSString *)path withBase:(NSString *)base {
    NSArray *commandsToReplace = [NSArray arrayWithObjects:@"\\\\include\\{", @"\\\\input\\{", nil];
 
    NSError *error;
    NSString* content = [[NSMutableString alloc] initWithContentsOfFile:path usedEncoding:0 error:&error];
    
    if (error) {
        return [NSString stringWithFormat:@"Error while loading file: %@",path];
    }
    
    NSMutableString *retContent = [NSMutableString stringWithString:content];
    
    for (NSString *command in commandsToReplace) {
        NSString* regExString =  [command stringByAppendingString:@"(.*)\\}"];
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:regExString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regEx matchesInString:retContent options:0 range:NSMakeRange(0, [retContent length])];
        for (NSTextCheckingResult* match in matches.reverseObjectEnumerator) {
            NSString *newFilename = [[retContent substringWithRange:[match rangeAtIndex:1]] absolutePathWithBase:base];
            if (![[newFilename pathExtension] isEqualToString:@"tex"]) {
                newFilename = [newFilename stringByAppendingPathExtension:@"tex"];
            }
            NSString *newContent = [self getMergedContentOfFile:newFilename withBase:base];
            [retContent replaceCharactersInRange:[match rangeAtIndex:0] withString:newContent];
        }
    }
    
    return (NSString*)retContent;
}


- (IBAction)cancelDialog:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet: self.window returnCode:NSRunAbortedResponse];
    [self.window orderOut: self];
}

- (IBAction)OKDialog:(id)sender {
    [NSApp stopModal];
    [NSApp endSheet: self.window];
    [self.window orderOut: self];
}

@end
