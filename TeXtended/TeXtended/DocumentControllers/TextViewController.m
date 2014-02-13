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
#import "CodeNavigationAssistant.h"
#import "DocumentController.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "ForwardSynctex.h"
#import "LacheckParser.h"
#import "ChktexParser.h"
#import "PathFactory.h"
#import "BackwardSynctex.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTNotificationCenter.h"
#import "TMTTabViewItem.h"
#import "TMTTabManager.h"
#import "NSString+RegexReplace.h"
#import "NSAttributedString+Replace.h"
#import "OutlineExtractor.h"
#import "MessageCoordinator.h"

/** Delay for message collection updates in seconds */
static const double MESSAGE_UPDATE_DELAY = 1.5;
@interface TextViewController ()
/** Method for handling the initial setup of this object */
- (void) initializeAttributes;

/** Method for setting up the model observations */
- (void) registerModelObserver;

/** Method for unregistering this object as model observer */
- (void) unregisterModelObserver;

/** Method for syncing the pdf output with the HighlightingTextView
 
 @param model the model to sync for
 */
- (void) syncPDF:(DocumentModel *)model;
- (void) updateMessageCollection:(NSNotification *)note;
- (void) handleLineUpdateNotification:(NSNotification*)note;
- (void) handleBackwardSynctex:(NSNotification*)note;

- (void)messagesDidChange:(NSNotification *)note;
@end

@implementation TextViewController


- (id)initWithFirstResponder:(id<FirstResponderDelegate>)dc {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        self.firstResponderDelegate = dc;
        observers = [NSMutableSet new];
        synctex = [ForwardSynctexController new];
        [self bind:@"liveScrolling" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveScrolling] options:NULL];
        [self registerModelObserver];
        
        self.tabViewItem = [TMTTabViewItem new];
        [self.tabViewItem bind:@"title" toObject:self withKeyPath:@"model.texName" options:@{NSNullPlaceholderBindingOption: NSLocalizedString(@"Untitled", @"Untitled")}];
        [self.tabViewItem bind:@"identifier" toObject:self withKeyPath:@"model.texIdentifier" options:NULL];
        self.tabViewItem.view = self.view;
        outlineExtractor = [OutlineExtractor new];
        
        
    }
    return self;
}

- (void)setFirstResponderDelegate:(id<FirstResponderDelegate>)firstResponderDelegate {
    _firstResponderDelegate = firstResponderDelegate;
    self.textView.firstResponderDelegate = firstResponderDelegate;
    self.model = firstResponderDelegate.model;
}


- (void)registerModelObserver {
    [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(handleLineUpdateNotification:) name:TMTShowLineInTextViewNotification object:self.model];
    [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(handleBackwardSynctex:) name:TMTViewSynctexChanged object:self.model];
   
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterModelObserver {
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTShowLineInTextViewNotification object:self.model];
    
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTViewSynctexChanged object:nil];
}

- (void)setModel:(DocumentModel *)model {
    if (_model) {
        [_model removeObserver:self forKeyPath:@"texPath"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTPartialMessagesDidChangeNotification object:self.model.texPath];
    }
    _model = model;
    if (_model) {
        NSArray *messages = [[MessageCoordinator sharedMessageCoordinator] messagesForPartialDocumentPath:self.model.texPath];
        if (messages) {
            lineNumberView.messageCollection = messages;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesDidChange:) name:TMTPartialMessagesDidChangeNotification object:self.model.texPath];
        [_model addObserver:self forKeyPath:@"texPath" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)updateMessageCollection:(NSNotification *)note {
    if (!self.model.currentMainDocument) return;
    
    // save the current document, since it is probabily included
    NSError *error = nil;
    [self.model saveContent:self.content error:&error];
    if (error) {
        DDLogError(@"%@", error);
        return;
    }
    
    if (self.model.currentMainDocument.texPath && self.content) {
            if(!chktex) {
                chktex = [ChktexParser new];
            }
            if (!lacheck) {
                lacheck = [LacheckParser new];
            }
            __unsafe_unretained TextViewController* weakSelf = self;
            [chktex parseDocument:self.model.currentMainDocument.texPath callbackBlock:^(NSArray *messages) {
                if (messages) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TMTMessagesDidChangeNotification object:weakSelf.model.texPath userInfo:@{TMTMessageCollectionKey:messages, TMTMessageGeneratorTypeKey:@(TMTChktexParser)}];
                }
            }];
            [lacheck parseDocument:self.model.currentMainDocument.texPath callbackBlock:^(NSArray *messages) {
                if (messages) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TMTMessagesDidChangeNotification object:weakSelf.model.texPath userInfo:@{TMTMessageCollectionKey:messages, TMTMessageGeneratorTypeKey:@(TMTLacheckParser)}];
                }
            }];
        }
}

- (void)handleLineUpdateNotification:(NSNotification *)note {
    NSTabViewItem *view = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
    [view.tabView.window makeKeyAndOrderFront:self];
    [view.tabView selectTabViewItem:view];
    NSInteger row = [(note.userInfo)[TMTIntegerKey] integerValue];
    [self.textView showLine:row];
}

- (void)handleBackwardSynctex:(NSNotification *)note {
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



- (void)loadView {
        [super loadView];
        [self initializeAttributes];
        [self.textView addObserver:self forKeyPath:@"currentRow" options:NSKeyValueObservingOptionNew context:NULL];
        self.textView.firstResponderDelegate = self.firstResponderDelegate;
    NSArray *messages = [[MessageCoordinator sharedMessageCoordinator] messagesForPartialDocumentPath:self.model.texPath];
    lineNumberView.messageCollection = messages;
    
}

- (void)initializeAttributes {
    lineNumberView = [[LineNumberView alloc] initWithScrollView:[self scrollView]];
    [self.scrollView setVerticalRulerView:lineNumberView];
    [self.scrollView setHasHorizontalRuler:NO];
    [self.scrollView setHasVerticalRuler:YES];
    [self.scrollView setRulersVisible:YES];
}


- (NSString *)content {
    return [[self.textView attributedString] stringByReplacingPlaceholders];
}


- (void)setContent:(NSString *)content {
    if (content) {
        NSMutableAttributedString *string = [content attributedStringBySubstitutingPlaceholders];
        [string addAttributes:self.textView.typingAttributes range:NSMakeRange(0, string.length)];
        [self.textView.textStorage setAttributedString:string];
        [self.textView.syntaxHighlighter highlightEntireDocument];
    }
}

- (NSSet *)children {
    return [NSSet setWithObject:nil];
}

- (void)syncPDF:(DocumentModel *)model {
    if (model) {
        [synctex startWithInputPath:self.model.texPath outputPath:model.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol andHandler:^(ForwardSynctex *result) {
            if (result) {
                NSDictionary *info = @{TMTForwardSynctexKey: result};
                [[TMTNotificationCenter centerForCompilable:self.model] postNotificationName:TMTCompilerSynctexChanged object:model userInfo:info];
            }
        }];
    } else {
        for (DocumentModel *m in self.model.mainDocuments) {
            [synctex startWithInputPath:self.model.texPath outputPath:m.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol andHandler:^(ForwardSynctex *result) {
                if (result) {
                    NSDictionary *info = @{TMTForwardSynctexKey: result};
                    [[TMTNotificationCenter centerForCompilable:self.model] postNotificationName:TMTCompilerSynctexChanged object:m userInfo:info];
                }
            }];
        }
    }
}

- (void)breakUndoCoalescing {
    [self.textView breakUndoCoalescing];
}

#pragma mark -
#pragma mark Observers

- (void)addObserver:(id<TextViewObserver>)observer {
    [observers addObject:[NSValue valueWithNonretainedObject:observer]];
}

- (void)removeDelegateObserver:(id<TextViewObserver>)observer {
    [observers removeObject:[NSValue valueWithNonretainedObject:observer]];
}

#pragma mark -
#pragma mark Delegate Methods


- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
    return newSelectedCharRange;
}


- (void)textViewDidChangeSelection:(NSNotification *)notification {
    [self.scrollView.verticalRulerView setNeedsDisplay:YES];
    
}


- (void)textDidChange:(NSNotification *)notification {
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.model]) {
        [self unregisterModelObserver];
        if ([keyPath isEqualToString:@"mainDocuments"]) {
            [self registerModelObserver];
        }
        if ([keyPath isEqualToString:@"texPath"]) {
            NSString *oldPath = change[NSKeyValueChangeOldKey];
            if (oldPath && oldPath != [NSNull null]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTPartialMessagesDidChangeNotification object:oldPath];
            }
            NSString *newPath = change[NSKeyValueChangeNewKey];
            if (newPath && newPath != [NSNull null]) {
                NSArray *messages = [[MessageCoordinator sharedMessageCoordinator] messagesForPartialDocumentPath:newPath];
                if (messages) {
                    lineNumberView.messageCollection = messages;
                }
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesDidChange:) name:TMTPartialMessagesDidChangeNotification object:newPath];
            }
        }
    } else if([keyPath isEqualToString:@"currentRow"] && [object isEqualTo:self.textView]) {
        if (self.liveScrolling) {
            [self performSelectorInBackground:@selector(syncPDF:) withObject:nil];
        }
    } 
}

- (void)messagesDidChange:(NSNotification *)note {
    lineNumberView.messageCollection = note.userInfo[TMTMessageCollectionKey];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [lacheck terminate];
    [chktex terminate];
    NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
    if (item) {
        [item.tabView removeTabViewItem:item];
    }
    [self unbind:@"liveScrolling"];
    [self.textView removeObserver:self forKeyPath:@"currentRow"];
    [self unregisterModelObserver];
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
