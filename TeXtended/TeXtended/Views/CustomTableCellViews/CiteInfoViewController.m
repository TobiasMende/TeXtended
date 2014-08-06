//
//  CiteInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 23.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "CiteInfoViewController.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

static const NSString *SHOW_IN_BIBDESK_SCRIPT;

@interface CiteInfoViewController ()

    - (void)executeBibdeskScript:(id)sender;
@end

@implementation CiteInfoViewController

    + (void)initialize
    {
        if ([self class] == [CiteInfoViewController class]) {
            SHOW_IN_BIBDESK_SCRIPT = @"tell application \"BibDesk\"\n\tactivate\n\topen POSIX file \"%@\" as alias\n\tsearch for \"%@\"\n\tselect result\nend tell";
        }
    }


    - (id)init
    {
        self = [super initWithNibName:@"CiteInfoView" bundle:nil];
        if (self) {

        }
        return self;
    }

    - (IBAction)showInBibdesk:(id)sender
    {
        [self performSelectorInBackground:@selector(executeBibdeskScript:) withObject:sender];
    }

    - (void)executeBibdeskScript:(id)sender
    {
        NSString *source = [NSString stringWithFormat:[SHOW_IN_BIBDESK_SCRIPT copy], self.bibFilePath, [self.representedObject key]];
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
        NSDictionary *errorDict = nil;
        [script executeAndReturnError:&errorDict];
        if (errorDict) {
            DDLogError(@"Can't execute apple script: %@", errorDict);
            DDLogInfo(@"%@", source);
        }
    }

    - (BOOL)shouldShowBibDeskButton
    {
        return [[NSWorkspace sharedWorkspace] fullPathForApplication:@"BibDesk"] != nil && self.bibFilePath;
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"shouldShowBibDeskButton"]) {
            keys = [keys setByAddingObject:@"bibFilePath"];
        }
        return keys;
    }

@end
