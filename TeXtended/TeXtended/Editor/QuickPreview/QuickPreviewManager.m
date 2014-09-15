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
#import "TextViewController.h"
#import "ExtendedPDFViewController.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

static NSString *TEMP_PREFIX = @"TMTTempQuickPreview-";

@interface QuickPreviewManager ()

    - (void)buildTempModelFor:(DocumentModel *)model;

    - (void)cleanTempFiles;

    - (void)compilerStart:(NSNotification *)note;

    - (void)compilerEnd:(NSNotification *)note;

- (void)setUpModel;
@end

@implementation QuickPreviewManager


    - (id)initWithParentView:(HighlightingTextView *)parent
    {
        self = [super initWithWindowNibName:@"QuickPreviewWindow"];
        if (self) {
            self.parentView = parent;
            [self setUpModel];
            self.pvc = [[ExtendedPDFViewController alloc] init];
            self.textViewController = [[TextViewController alloc] initWithFirstResponder:self andModel:self.model];
            self.compiler = [[Compiler alloc] initWithCompileProcessHandler:self];
            self.compiler.idleTimeForLiveCompile = 0.75;
            [self.textViewController addObserver:self.compiler];
        }
        return self;
    }

- (void)setUpModel  {
    self.model = [DocumentModel new];
    self.model.liveCompile = @YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerStart:) name:TMTCompilerDidStartCompiling object:self.model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerEnd:) name:TMTCompilerDidEndCompiling object:self.model];
}

    - (void)loadWindow
    {
        [super loadWindow];
        [self.window setLevel:NSNormalWindowLevel];
        [self.splitView addSubview:self.textViewController.view];
        [self.splitView addSubview:self.pvc.view];
        [self.splitView adjustSubviews];
        [self.window setInitialFirstResponder:self.textViewController.textView];
        [self buildTempModelFor:self.parentView.firstResponderDelegate.model];
        self.textViewController.textView.enableQuickPreviewAssistant = NO;
                    [self.pvc setModel:self.model];
    }

    - (void)showWindow:(id)sender
    {
        [super showWindow:sender];
        [self.window makeKeyAndOrderFront:sender];
        [self.window makeFirstResponder:self.textViewController.textView];
        [self updateMainCompilable];
        [self.textViewController setContent:[self.parentView.string substringWithRange:self.parentView.selectedRange]];
        [self.textViewController.textView makeKeyView];
        if (self.textViewController.content.length != 0) {
            [self liveCompile:self];
        }
    }


    - (void)buildTempModelFor:(DocumentModel *)model
    {
        if (self.parentModel) {
            [self.parentModel removeObserver:self forKeyPath:@"self.mainDocuments"];
        }
        if (self.model) {
            [self.model unbind:@"liveCompiler"];
            [self.model unbind:@"encoding"];
        }
        self.parentModel = model;

        [self.model bind:@"liveCompiler" toObject:model withKeyPath:@"liveCompiler" options:nil];
        [self.model bind:@"encoding" toObject:model withKeyPath:@"encoding" options:nil];
        [self.parentModel addObserver:self forKeyPath:@"self.mainDocuments" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];

        
       
    }

    - (void)compilerStart:(NSNotification *)note
    {
        self.isCompiling = YES;
    }

    - (void)compilerEnd:(NSNotification *)note
    {
        self.isCompiling = NO;
    }

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        self.mainDocuments = self.parentModel.mainDocuments;
        if (self.mainDocuments.count) {
            [self.mainCompilableSelection selectItemAtIndex:0];
        }
    }

- (void)saveDocument:(id)sender {
    [self updateMainCompilable];
    if (self.currentHeader) {
        NSString *body = self.textViewController.content;
        NSMutableString *content = [[NSMutableString alloc] initWithString:self.currentHeader];
        [content appendString:@"\n\\begin{document}\n"];
        [content appendString:body];
        [content appendString:@"\n\\end{document}"];
        NSError *error;
        [content writeToFile:self.model.texPath atomically:YES encoding:self.model.encoding.unsignedLongValue error:&error];
       
    } else {
        DDLogError(@"Can't get header ");
    }
    
}

    - (void)liveCompile:(id)sender
    {
        [self saveDocument:sender];
        [self compile:live];
    }

    - (void)updateMainCompilable
    {
        DocumentModel *tmp = [self.mainDocuments objectAtIndex:[self.mainCompilableSelection indexOfSelectedItem]];
        if (![tmp isEqualTo:self.mainCompilable]) {
            [self cleanTempFiles];
            self.mainCompilable = tmp;
            NSString *name = [self.mainCompilable.texPath lastPathComponent];
            NSString *folder = [self.mainCompilable.texPath stringByDeletingLastPathComponent];
            name = [TEMP_PREFIX stringByAppendingString:name];
            self.model.texPath = [folder stringByAppendingPathComponent:name];
            self.model.pdfPath = [self.model.texPath stringByAppendingPathExtension:@"pdf"];
            [self.model unbind:@"liveCompiler"];
            [self.model bind:@"liveCompiler" toObject:self.mainCompilable withKeyPath:@"liveCompiler" options:nil];
            self.currentHeader = self.mainCompilable.header;
        }
    }

    - (BOOL)isLiveCompileEnabled
    {
        return YES;
    }

    - (MainDocument *)mainDocument
    {
        return nil;
    }


    - (void)compile:(CompileMode)mode
    {
        [self.compiler compile:mode];
    }

    - (void)cleanTempFiles
    {
        if (self.model.texPath) {
            [[NSFileManager defaultManager] removeItemAtPath:self.model.texPath error:nil];
            NSError *error;
            NSString *directory = [self.model.texPath stringByDeletingLastPathComponent];
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
            if (error) {
                DDLogError(@"Can't delete temp file: %@", error.userInfo);
            } else {
                for (NSString *path in contents) {
                    if ([path hasPrefix:TEMP_PREFIX]) {
                        [[NSFileManager defaultManager] removeItemAtPath:[directory stringByAppendingPathComponent:path] error:&error];
                        if (error) {
                            DDLogWarn(@"Can't delete file at %@", path);
                            error = nil;
                        }
                    }
                }
            }
        }
    }

    - (void)abort
    {
        // Nothing should happen...
    }


#pragma mark - Actions

    - (void)commandEnter:(id)sender
    {
        // TODO: handle range
        [self.window close];
        [self.parentView replaceCharactersInRange:self.parentView.selectedRange withString:self.textViewController.content];
        [self.textViewController setContent:@""];
    }

    - (IBAction)cancel:(id)sender
    {
        [self.window close];
        [self.parentView.window makeFirstResponder:self.parentView];
    }

    - (void)windowWillClose:(NSNotification *)notification
    {
        [self.compiler abort];
        [self cleanTempFiles];
        [self.parentView makeKeyView];

    }

    - (void)dealloc
    {
        [self.compiler terminateAndKill];
    }

@end
