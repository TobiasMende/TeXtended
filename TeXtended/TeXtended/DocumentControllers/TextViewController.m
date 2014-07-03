//
//  TextViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//


#import "TextViewController.h"
#import "LineNumberView.h"
#import "HighlightingTextView.h"
#import "ForwardSynctex.h"
#import "LacheckParser.h"
#import "ChktexParser.h"
#import "BackwardSynctex.h"
#import "TMTTabViewItem.h"
#import "TMTTabManager.h"
#import "NSString+RegexReplace.h"
#import "NSAttributedString+Replace.h"
#import "OutlineExtractor.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/NSTextView+TMTExtensions.h>

/** Delay for message collection updates in seconds */
static const double MESSAGE_UPDATE_DELAY = 1.5;

@interface TextViewController ()

/** Method for handling the initial setup of this object */
    - (void)initializeAttributes;

/** Method for setting up the model observations */
    - (void)registerModelObserver;

/** Method for unregistering this object as model observer */
    - (void)unregisterModelObserver;

/** Method for syncing the pdf output with the HighlightingTextView
 
 @param model the model to sync for
 */
    - (void)syncPDF:(DocumentModel *)model;

    - (void)updateMessageCollection:(NSNotification *)note;

    - (void)handleLineUpdateNotification:(NSNotification *)note;

    - (void)handleBackwardSynctex:(NSNotification *)note;

@end

@implementation TextViewController


    - (id)initWithFirstResponder:(id <FirstResponderDelegate>)dc
    {
        self = [super initWithNibName:@"TextView" bundle:nil];
        if (self) {
            self.firstResponderDelegate = dc;
            observers = [NSMutableSet new];
            synctex = [ForwardSynctexController new];
            [self bind:@"liveScrolling" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveScrolling] options:NULL];

            self.tabViewItem = [TMTTabViewItem new];
            [self.tabViewItem bind:@"title" toObject:self withKeyPath:@"model.texName" options:@{NSNullPlaceholderBindingOption : NSLocalizedString(@"Untitled", @"Untitled")}];
            [self.tabViewItem bind:@"identifier" toObject:self withKeyPath:@"model.texIdentifier" options:NULL];
            self.tabViewItem.view = self.view;
            outlineExtractor = [OutlineExtractor new];

        }
        return self;
    }

    - (void)setFirstResponderDelegate:(id <FirstResponderDelegate>)firstResponderDelegate
    {
        _firstResponderDelegate = firstResponderDelegate;
        self.textView.firstResponderDelegate = firstResponderDelegate;
        self.model = firstResponderDelegate.model;
    }


    - (void)registerModelObserver
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLineUpdateNotification:) name:TMTShowLineInTextViewNotification object:self.model];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBackwardSynctex:) name:TMTViewSynctexChanged object:self.model];
        [self.model addObserver:self forKeyPath:@"messages" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
        

    }

    - (void)unregisterModelObserver
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTShowLineInTextViewNotification object:self.model];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTViewSynctexChanged object:self.model];
        [self.model removeObserver:self forKeyPath:@"messages"];
    }

    - (void)setModel:(DocumentModel *)model
    {
        if (_model) {
            [self unregisterModelObserver];
        }
        _model = model;
        if (_model) {
            lineNumberView.model = self.model;
            [self registerModelObserver];
        }
    }

    - (void)updateMessageCollection:(NSNotification *)note
    {
        if (!self.model.currentMainDocument || !self.model.currentMainDocument.texPath) return;

        // save the current document, since it is probabily included
        NSError *error = nil;
        if (self.firstResponderDelegate) {
            [self.firstResponderDelegate saveDocument:nil];
        }
        if (error) {
            return;
        }

        if (self.model.currentMainDocument.texPath && self.content) {
            if (!chktex) {
                chktex = [ChktexParser new];
            }
            if (!lacheck) {
                lacheck = [LacheckParser new];
            }
            __unsafe_unretained DocumentModel *weakMain = self.model.currentMainDocument;
            [chktex parseDocument:self.model.currentMainDocument.texPath callbackBlock:^(NSArray *messages)
            {
                if (messages) {
                    [weakMain updateMessages:messages forType:TMTChktexParser];
                }
            }];
            [lacheck parseDocument:self.model.currentMainDocument.texPath callbackBlock:^(NSArray *messages)
            {
                if (messages) {
                    [weakMain updateMessages:messages forType:TMTLacheckParser];
                }
            }];
        }
    }

    - (void)handleLineUpdateNotification:(NSNotification *)note
    {
        NSTabViewItem *view = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
        [view.tabView.window makeKeyAndOrderFront:self];
        [view.tabView selectTabViewItem:view];
        NSUInteger row = [(note.userInfo)[TMTIntegerKey] unsignedIntegerValue];
        [self.textView showLine:row];
    }

    - (void)handleBackwardSynctex:(NSNotification *)note
    {
        BackwardSynctex *first = (note.userInfo)[TMTBackwardSynctexBeginKey];
        BackwardSynctex *second = (note.userInfo)[TMTBackwardSynctexEndKey];

        NSRange firstLine = [self.textView rangeForLine:first.line];
        NSRange secondLine = [self.textView rangeForLine:second.line];
        NSRange total = NSMakeRange(NSNotFound, 0);

        if (first.column < firstLine.length) {
            firstLine.location += first.column;
            firstLine.length -= first.column;
        }
        if (second.column > 0 && second.column < secondLine.length) {
            secondLine.length = second.column;
        }
        if (firstLine.location != NSNotFound) {
            total = firstLine;
            if (secondLine.location != NSNotFound) {

                total = NSUnionRange(total, secondLine);
            }
        }
        if (total.location != NSNotFound) {
            [self.textView scrollRangeToVisible:total];
            [self.textView showFindIndicatorForRange:total];
        }
    }


    - (void)loadView
    {
        [super loadView];
        [self initializeAttributes];
        [self.textView addObserver:self forKeyPath:@"currentRow" options:NSKeyValueObservingOptionNew context:NULL];
        self.textView.firstResponderDelegate = self.firstResponderDelegate;
        [self updateMessageCollection:nil];

    }

    - (void)initializeAttributes
    {
        lineNumberView = [[LineNumberView alloc] initWithScrollView:[self scrollView]];
        lineNumberView.model = self.model;
        [self.scrollView setVerticalRulerView:lineNumberView];
        [self.scrollView setHasHorizontalRuler:NO];
        [self.scrollView setHasVerticalRuler:YES];
        [self.scrollView setRulersVisible:YES];
        
    }


    - (NSString *)content
    {
        return [[self.textView attributedString] stringByReplacingPlaceholders];
    }


    - (void)setContent:(NSString *)content
    {
        if (content) {
            NSMutableAttributedString *string = [content attributedStringBySubstitutingPlaceholders];
            [string addAttributes:self.textView.typingAttributes range:NSMakeRange(0, string.length)];
            [self.textView.textStorage setAttributedString:string];
            [self.textView.syntaxHighlighter highlightEntireDocument];
            if (NSMaxRange(self.model.selectedRange) < self.textView.string.length) {
                self.textView.selectedRange = self.model.selectedRange;
            }
        }
    }

    - (NSSet *)children
    {
        return [NSSet setWithObject:nil];
    }

    - (void)syncPDF:(DocumentModel *)model
    {
        if (model) {
            [synctex startWithInputPath:self.model.texPath outputPath:model.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol andHandler:^(ForwardSynctex *result)
            {
                if (result) {
                    NSDictionary *info = @{TMTForwardSynctexKey : result};
                    [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerSynctexChanged object:model userInfo:info];
                }
            }];
        } else {
            for (DocumentModel *m in self.model.mainDocuments) {
                [synctex startWithInputPath:self.model.texPath outputPath:m.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol andHandler:^(ForwardSynctex *result)
                {
                    if (result) {
                        NSDictionary *info = @{TMTForwardSynctexKey : result};
                        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerSynctexChanged object:m userInfo:info];
                    }
                }];
            }
        }
    }

    - (void)breakUndoCoalescing
    {
        [self.textView breakUndoCoalescing];
    }

#pragma mark -
#pragma mark Observers

    - (void)addObserver:(id <TextViewObserver>)observer
    {
        [observers addObject:[NSValue valueWithNonretainedObject:observer]];
    }

    - (void)removeDelegateObserver:(id <TextViewObserver>)observer
    {
        [observers removeObject:[NSValue valueWithNonretainedObject:observer]];
    }

#pragma mark -
#pragma mark Delegate Methods


    - (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
    {
        return newSelectedCharRange;
    }


    - (void)textViewDidChangeSelection:(NSNotification *)notification
    {
        [self.scrollView.verticalRulerView setNeedsDisplay:YES];

    }


    - (void)textDidChange:(NSNotification *)notification
    {
        if (!outlineExtractor.isExtracting) {
            [outlineExtractor extractIn:self.textView.string forModel:self.model withCallback:nil];
        }

        if (messageUpdateTimer) {
            [messageUpdateTimer invalidate];
        }
        messageUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:MESSAGE_UPDATE_DELAY target:self selector:@selector(updateMessageCollection:) userInfo:nil repeats:NO];

        for (NSValue *observerValue in observers) {
            [[observerValue nonretainedObjectValue] performSelector:@selector(textDidChange:) withObject:notification];
        }
    }

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([keyPath isEqualToString:@"currentRow"] && [object isEqualTo:self.textView]) {
            if (self.liveScrolling) {
                [self performSelectorInBackground:@selector(syncPDF:) withObject:nil];
            }
        } else if ([keyPath isEqualToString:@"messages"]) {
            lineNumberView.messageCollection = self.model.messages;
        }
    }


#pragma mark -
#pragma mark Dealloc

- (void)firstResponderIsDeallocating {
    [messageUpdateTimer invalidate];
    [lacheck terminate];
    [chktex terminate];
    self.firstResponderDelegate = nil;
}

    - (void)dealloc
    {
        DDLogVerbose(@"dealloc [%@]", self.model.path);
        
        [self unregisterModelObserver];
        NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
        if (item) {
            [item.tabView removeTabViewItem:item];
        }
        [self unbind:@"liveScrolling"];
        [self.textView removeObserver:self forKeyPath:@"currentRow"];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }


@end
