//
//  BibDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "BibDocument.h"
#import "DocumentCreationController.h"
#import "EncodingController.h"
#import "HighlightingTextView.h"
#import "BibtexSyntaxHighlighter.h"
#import <TMTHelperCollection/TMTLog.h>
#import "LineNumberView.h"

@interface BibDocument ()

    - (void)executeBibdeskScript:(id)sender;

@end

@implementation BibDocument

    - (id)init
    {
        self = [super init];
        if (self) {
            // Add your subclass-specific initialization here.
        }
        return self;
    }

    - (NSString *)windowNibName
    {
        // Override returning the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
        return @"BibDocument";
    }

    - (void)windowControllerDidLoadNib:(NSWindowController *)aController
    {
        [super windowControllerDidLoadNib:aController];
        LineNumberView *lineNumberView = [[LineNumberView alloc] initWithScrollView:[self scrollView]];
        [self.scrollView setVerticalRulerView:lineNumberView];
        [self.scrollView setHasHorizontalRuler:NO];
        [self.scrollView setHasVerticalRuler:YES];
        [self.scrollView setRulersVisible:YES];
        self.contentView.completionEnabled = NO;
        self.contentView.syntaxHighlighter = [[BibtexSyntaxHighlighter alloc] initWithTextView:self.contentView];
        if (tmpContent) {
            self.contentView.string = tmpContent;
            tmpContent = nil;
        }
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    - (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * __autoreleasing *)outError
    {
        DocumentCreationController *contr = [DocumentCreationController sharedDocumentController];
        NSString *content;
        if (contr.encController.selectionDidChange) {
            self.encoding = [contr.encController selection];
            content = [NSString stringWithContentsOfURL:url encoding:self.encoding error:outError];
        } else {
            NSStringEncoding encoding;
            content = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:outError];
            self.encoding = encoding;
        }

        if (self.contentView) {
            self.contentView.string = content;
        } else {
            tmpContent = content;
        }

        return content != nil;


    }

    - (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * __autoreleasing *)outError
    {
        [self.contentView breakUndoCoalescing];
        return [self.contentView.string writeToURL:url atomically:YES encoding:self.encoding error:outError];
    }

    + (BOOL)autosavesInPlace
    {
        return YES;
    }

    - (IBAction)openInBibdesk:(id)sender
    {
        [self performSelectorInBackground:@selector(executeBibdeskScript:) withObject:nil];
    }

    - (void)executeBibdeskScript:(id)sender
    {
        NSString *source = [NSString stringWithFormat:@"tell application \"BibDesk\"\n\tactivate\n\topen POSIX file \"%@\"\nend tell", self.fileURL.path];
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
        NSDictionary *errorDict = nil;
        [script executeAndReturnError:&errorDict];
        if (errorDict) {
            DDLogError(@"Can't execute apple script: %@", errorDict);
            DDLogInfo(@"%@", source);
        }
    }

    - (BOOL)bibdeskAvailable
    {
        return [[NSWorkspace sharedWorkspace] fullPathForApplication:@"BibDesk"] != nil;
    }
@end
