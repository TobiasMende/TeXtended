//
//  QuickPreviewManager.m
//  TeXtended
//
//  Created by Tobias Mende on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "QuickPreviewManager.h"
#import "HighlightingTextView.h"
#import "Compiler.h"
#import "DocumentModel.h"
#import "Compiler.h"
#import "TextViewController.h"
#import "ExtendedPDFViewController.h"
#import <TMTHelperCollection/TMTLog.h>

static const NSString *TEMP_PREFIX = @"TMTTempQuickPreview-";
@interface QuickPreviewManager ()
- (void) buildTempModelFor:(DocumentModel *)model;
- (void) cleanTempFiles;

@end
@implementation QuickPreviewManager


- (id)initWithParentView:(HighlightingTextView *)parent {
    self = [super initWithWindowNibName:@"QuickPreviewWindow"];
    if (self) {
        self.parentView = parent;
        self.pvc = [[ExtendedPDFViewController alloc] init];
        [self buildTempModelFor:parent.firstResponderDelegate.model];
        self.textViewController = [[TextViewController alloc] initWithFirstResponder:self];
        self.compiler = [[Compiler alloc] initWithCompileProcessHandler:self];
        [self.textViewController addObserver:self.compiler];
    }
    return self;
}

- (void)loadWindow {
    [super loadWindow];
   
    [self.splitView addSubview:self.textViewController.view];
    [self.splitView addSubview:self.pvc.view];
    [self.splitView adjustSubviews];
    [self.textViewController setContent:[self.parentView.string substringWithRange:self.parentView.selectedRange]];
    [self.window setInitialFirstResponder:self.textViewController.textView];
    [self updateMainCompilable];
}

- (void)buildTempModelFor:(DocumentModel *)model {
    self.model = [DocumentModel new];
    self.model.liveCompile = @YES;
    self.model.liveCompiler = model.liveCompiler;
    self.model.encoding = model.encoding;
    self.mainDocuments = [model.mainDocuments allObjects];
    [self.pvc setModel:self.model];
}

- (void)liveCompile:(id)sender {
    // TODO: clean files
    [self updateMainCompilable];
    if (self.currentHeader) {
        NSString *body = self.textViewController.content;
        NSMutableString *content = [[NSMutableString alloc]initWithString:self.currentHeader];
        [content appendString:@"\n\\begin{document}\n"];
        [content appendString:body];
        [content appendString:@"\n\\end{document}"];
        DDLogInfo(@"%@",content);
        NSError *error;
        [content writeToFile:self.model.texPath atomically:YES encoding:self.model.encoding.unsignedLongValue error:&error];
        if (error) {
            DDLogError(@"Can't save: %@", error.userInfo);
        } else {
            [self compile:live];
        }
    } else {
        DDLogError(@"Can't get header ");
    }
}

- (void) updateMainCompilable {
    DocumentModel *mainDocument = [self.mainDocuments objectAtIndex:[self.mainCompilableSelection indexOfSelectedItem]];
    
    NSString *name = [mainDocument.texPath lastPathComponent];
    NSString *folder = [mainDocument.texPath stringByDeletingLastPathComponent];
    name = [TEMP_PREFIX stringByAppendingString:name];
    self.model.texPath = [folder stringByAppendingPathComponent:name];
    self.model.pdfPath = [self.model.texPath stringByAppendingPathExtension:@"pdf"];
    self.currentHeader = mainDocument.header;
}

- (BOOL)isLiveCompileEnabled {
    return YES;
}

- (MainDocument *)mainDocument {
    return nil;
}

- (void)documentHasChangedAction {
    
}

- (void)compile:(CompileMode)mode {
    [self.compiler compile:mode];
}

- (void)cleanTempFiles {
    if (self.model.texPath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.model.texPath error:nil];
        // TODO: extend for other endings (pdf, gz, synctex, log)
    }
}




#pragma mark - Actions
- (IBAction)insertCode:(id)sender {
    // TODO: handle range
    [self.window close];
    [self.parentView replaceCharactersInRange:self.parentView.selectedRange withString:self.textViewController.content];
}

- (IBAction)cancel:(id)sender {
    [self.textViewController setContent:@""];
    
    [self.window close];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self.compiler terminateAndKill];
}
@end
