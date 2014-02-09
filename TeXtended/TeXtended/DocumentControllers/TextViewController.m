//
//  TextViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

/** Delay for message collection updates in seconds */
static const double MESSAGE_UPDATE_DELAY = 1.5;

#import "TextViewController.h"
#import "LineNumberView.h"
#import "HighlightingTextView.h"
#import "CodeNavigationAssistant.h"
#import "DocumentController.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "MessageCollection.h"
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

/** Notifies this object about changes in the log messages. This method updates it's messages with the new arriving message collection
 
 @param note a notification with a new MessageCollection in it's user info.
 
 */
- (void) logMessagesChanged:(NSNotification*)note;

/** Method for rerunning lacheck and chktex for updates of the message collection 
 
 @param note the notification
 */
- (void) updateMessageCollection:(NSNotification *)note;
- (void) mergeMessageCollection:(MessageCollection *)messages;
- (void) handleLineUpdateNotification:(NSNotification*)note;
- (void) handleBackwardSynctex:(NSNotification*)note;
- (void) updateCurrentMessageMainDocumentNotification:(NSNotification *)note;
- (void) adapteMessageToLevel;
@end

@implementation TextViewController


- (id)initWithFirstResponder:(id<FirstResponderDelegate>)dc {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        messageLock = [NSObject new];
        
        self.firstResponderDelegate = dc;
        observers = [NSMutableSet new];
        synctex = [ForwardSynctexController new];
        backgroundQueue = [NSOperationQueue new];
        backgroundQueue.name = @"TextViewController-BackgroundQueue";
        [self bind:@"liveScrolling" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveScrolling] options:NULL];
        [self bind:@"logLevel" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTLatexLogLevelKey] options:NULL];
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

- (void)setModel:(DocumentModel *)model {
    if (_model) {
        [[TMTNotificationCenter centerForCompilable:_model] removeObserver:self name:TMTMessageSelectedMainDocumentNotification object:nil];
    }
    _model = model;
    if (_model) {
        if (!currentMessageMainDocument) {
            currentMessageMainDocument = model.mainDocuments.firstObject;
        }
        [[TMTNotificationCenter centerForCompilable:_model] addObserver:self selector:@selector(updateCurrentMessageMainDocumentNotification:) name:TMTMessageSelectedMainDocumentNotification object:nil];
    }
}


- (void)registerModelObserver {
    [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(logMessagesChanged:) name:TMTLogMessageCollectionChanged object:self.model];
    [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(handleLineUpdateNotification:) name:TMTShowLineInTextViewNotification object:self.model];
    [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(handleBackwardSynctex:) name:TMTViewSynctexChanged object:self.model];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageCollection:) name:TMTDidSaveDocumentModelContent object:self.model];
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterModelObserver {
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTLogMessageCollectionChanged object:self.model];
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTShowLineInTextViewNotification object:self.model];
    
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self name:TMTViewSynctexChanged object:nil];
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

- (void)updateCurrentMessageMainDocumentNotification:(NSNotification *)note {
    if ([self.model.mainDocuments containsObject:note.userInfo[TMTNewSelectedMainDocumentKey]]) {
        currentMessageMainDocument = note.userInfo[TMTNewSelectedMainDocumentKey];
        if (messageUpdateTimer) {
            [messageUpdateTimer invalidate];
        }
        [self updateMessageCollection:nil];
    }
}



- (void)logMessagesChanged:(NSNotification *)note {
    MessageCollection *collection = (note.userInfo)[TMTMessageCollectionKey];
    if (collection) {
            if (currentMessageMainDocument.messages) {
                currentMessageMainDocument.messages.errorMessages = collection.errorMessages;
                if (![self.model isEqualTo:currentMessageMainDocument]) {
                    self.model.messages = [currentMessageMainDocument.messages messagesForDocument:self.model.texPath];
                }
                lineNumberView.messageCollection = self.model.messages;
            }
    }
}

- (void)updateMessageCollection:(NSNotification *)note {
    if (self.logLevel < WARNING) {
        return;
    }
    
    if (!currentMessageMainDocument) return;
    
    // save the current document, since it is probabily included
    NSError *error = nil;
    [self.model saveContent:self.content error:&error];
    if (error) {
        DDLogError(@"%@", error);
        return;
    }
    
    if (currentMessageMainDocument.texPath && self.content) {
        @synchronized(messageLock) {
            if(!chktex) {
                chktex = [ChktexParser new];
            }
            if (!lacheck) {
                lacheck = [LacheckParser new];
            }
            __unsafe_unretained id weakSelf = self;
            countRunningParsers = 2;
            [chktex parseDocument:currentMessageMainDocument.texPath callbackBlock:^(MessageCollection *messages) {
                [weakSelf mergeMessageCollection:messages];
            }];
            [lacheck parseDocument:currentMessageMainDocument.texPath callbackBlock:^(MessageCollection *messages) {
                [weakSelf mergeMessageCollection:messages];
            }];
        }
    }
}

- (void)mergeMessageCollection:(MessageCollection *)messages {
    @synchronized(messageLock) {
        if (countRunningParsers == 2) {
            [currentMessageMainDocument.messages.warningMessages removeAllObjects];
            [currentMessageMainDocument.messages.infoMessages removeAllObjects];
            [currentMessageMainDocument.messages.debugMessages removeAllObjects];
        }
        if (countRunningParsers > 0) {
            countRunningParsers--;
        }
        if (currentMessageMainDocument) {
            [[NSFileManager defaultManager] removeItemAtPath:[PathFactory pathToTemporaryStorage:self.model.texPath]  error:NULL];
            [currentMessageMainDocument.messages merge:messages];
            MessageCollection *subset;
            if (![currentMessageMainDocument isEqualTo:self.model]) {
                subset = [currentMessageMainDocument.messages messagesForDocument:self.model.texPath];
                self.model.messages = subset;
            } else {
                subset = self.model.messages;
            }
            lineNumberView.messageCollection = subset;
        }
        
    }
}


- (void)loadView {
        [super loadView];
        [self initializeAttributes];
        [self.textView addObserver:self forKeyPath:@"currentRow" options:NSKeyValueObservingOptionNew context:NULL];
        self.textView.firstResponderDelegate = self.firstResponderDelegate;
    
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
    [self updateMessageCollection:nil];
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
    if (messageUpdateTimer) {
        [messageUpdateTimer invalidate];
    }
    if (!outlineExtractor.isExtracting) {
        [outlineExtractor extractIn:self.textView.string forModel:self.model withCallback:nil];
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
    } else if([keyPath isEqualToString:@"currentRow"] && [object isEqualTo:self.textView]) {
        if (self.liveScrolling) {
            [self performSelectorInBackground:@selector(syncPDF:) withObject:nil];
        }
    } 
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
    if (item) {
        [item.tabView removeTabViewItem:item];
    }
    [lacheck terminate];
    [chktex terminate];
    [self unbind:@"liveScrolling"];
    [self unbind:@"logLevel"];
    [self unbind:@"currentMessageMainDocument"];
    [self.textView removeObserver:self forKeyPath:@"currentRow"];
    [self unregisterModelObserver];
    [backgroundQueue cancelAllOperations];
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
