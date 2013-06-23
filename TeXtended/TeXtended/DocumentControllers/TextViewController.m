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
#import "MessageCollection.h"
#import "ForwardSynctex.h"
#import "LacheckParser.h"
#import "ChktexParser.h"
#import "PathFactory.h"
@interface TextViewController ()
/** Method for handling the initial setup of this object */
- (void) initialize;

/** Method for handling the and of a compiler task
 
 @param note the TMTCompilerDidEndCompiling notification
*/
- (void) handleCompilerEnd:(NSNotification *)note;

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

/** Method for rerunning lacheck and chktex for updates of the message collection */
- (void) updateMessageCollection:(NSNotification *)note;
- (void) mergeMessageCollection:(MessageCollection *)messages;
- (void) handleLineUpdateNotification:(NSNotification*)note;
@end

@implementation TextViewController


- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        self.parent = parent;
        messageLock = [NSLock new];
        observers = [NSMutableSet new];
        backgroundQueue = [NSOperationQueue new];
        self.model = [[self.parent documentController] model];
        [self bind:@"liveScrolling" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveScrolling] options:NULL];
        [self registerModelObserver];
    }
    return self;
}

- (void)registerModelObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logMessagesChanged:) name:TMTLogMessageCollectionChanged object:self.model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLineUpdateNotification:) name:TMTShowLineInTextViewNotification object:self.model];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageCollection:) name:TMTDidSaveDocumentModelContent object:self.model];
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    for (DocumentModel *m in self.model.mainDocuments) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCompilerEnd:) name:TMTCompilerDidEndCompiling object:m];
    }
}

- (void)unregisterModelObserver {
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTLogMessageCollectionChanged object:self.model];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTShowLineInTextViewNotification object:self.model];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:nil];
}

- (void)handleLineUpdateNotification:(NSNotification *)note {
    NSInteger row = [[note.userInfo objectForKey:TMTIntegerKey] integerValue];
    [self.textView showLine:row];
}

- (void)logMessagesChanged:(NSNotification *)note {
    consoleMessages = [note.userInfo objectForKey:TMTMessageCollectionKey];
    if (countRunningParsers == 0) {
        self.messages = [consoleMessages merge:internalMessages];
        lineNumberView.messageCollection = [self.messages messagesForDocument:self.model.texPath];
        [[NSNotificationCenter defaultCenter]postNotificationName:TMTMessageCollectionChanged object:self.model userInfo:[NSDictionary dictionaryWithObject:self.messages forKey:TMTMessageCollectionKey]];
    }
}

- (void)updateMessageCollection:(NSNotification *)note {
    NSError *error;
    TMTTrackingMessageType thresh = [[[NSUserDefaults standardUserDefaults] valueForKey:TMTLatexLogLevelKey] intValue];
    if (thresh < WARNING) {
        return;
    }
    if (countRunningParsers == 0) {
        NSString *tempPath = [PathFactory pathToTemporaryStorage:self.model.texPath] ;
        [self.textView.string writeToFile:tempPath atomically:YES encoding:[self.model.encoding intValue]  error:&error];
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
            return;
        }
        countRunningParsers = 2;
        ChktexParser *chktex = [ChktexParser new];
        [chktex parseDocument:tempPath forObject:self selector:@selector(mergeMessageCollection:)];
        
        LacheckParser *lacheck = [LacheckParser new];
        [lacheck parseDocument:tempPath forObject:self selector:@selector(mergeMessageCollection:)];
    }
    
    
}

- (void)mergeMessageCollection:(MessageCollection *)messages {
    [messageLock lock];
    if (countRunningParsers == 2) {
        internalMessages = [MessageCollection new];
    }
    countRunningParsers--;
    
    
    internalMessages = [internalMessages merge:messages];
    if (countRunningParsers == 0) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[PathFactory pathToTemporaryStorage:self.model.texPath]  error:&error];
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
        }
        self.messages = [internalMessages merge:consoleMessages];
        MessageCollection *subset = [self.messages messagesForDocument:self.model.texPath];
        lineNumberView.messageCollection = subset;
        [[NSNotificationCenter defaultCenter]postNotificationName:TMTMessageCollectionChanged object:self.model userInfo:[NSDictionary dictionaryWithObject:self.messages forKey:TMTMessageCollectionKey]];
    }
    [messageLock unlock];
}

- (void)handleCompilerEnd:(NSNotification *)note {
    DocumentModel *m = [note object];
    if (![self.model.mainDocuments containsObject:m]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:m];
        return;
    }
ForwardSynctex *synctex = [[ForwardSynctex alloc] initWithInputPath:self.model.texPath outputPath:m.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol];
NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:synctex,TMTForwardSynctexKey, nil];
[[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerSynctexChanged object:m userInfo:info];
}

- (void)loadView {
    [super loadView];
    [self initialize];
    [self.textView addObserver:self forKeyPath:@"currentRow" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (void)initialize {
    lineNumberView = [[LineNumberView alloc] initWithScrollView:[self scrollView]];
    [self.scrollView setVerticalRulerView:lineNumberView];
    [self.scrollView setHasHorizontalRuler:NO];
    [self.scrollView setHasVerticalRuler:YES];
    [self.scrollView setRulersVisible:YES];
}


- (NSString *)content {
    return [self.textView string];
}

- (void)setContent:(NSString *)content {
    [self.textView setString:content];
}

- (NSSet *)children {
    return [NSSet setWithObject:nil];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:nil];
    for (DocumentModel *m in self.model.mainDocuments) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCompilerEnd:) name:TMTCompilerDidEndCompiling object:m];
    }
    //TODO: reload file path?
}


- (void)syncPDF:(DocumentModel *)model {
    if (model) {
        ForwardSynctex *synctex = [[ForwardSynctex alloc] initWithInputPath:self.model.texPath outputPath:model.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:synctex,TMTForwardSynctexKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerSynctexChanged object:model userInfo:info];
    } else {
        for (DocumentModel *m in self.model.mainDocuments) {
            ForwardSynctex *synctex = [[ForwardSynctex alloc] initWithInputPath:self.model.texPath outputPath:m.pdfPath row:self.textView.currentRow andColumn:self.textView.currentCol];
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:synctex,TMTForwardSynctexKey, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerSynctexChanged object:m userInfo:info];
        }
    }
}

- (void)goToLine:(id)sender {
    NSLog(@"Go to line");
}

- (void) documentHasChangedAction {
}

- (void)breakUndoCoalescing {
    [self.textView breakUndoCoalescing];
}

- (DocumentController *)documentController {
    return [self.parent documentController];
}


#pragma mark -
#pragma mark Observers

- (void)addObserver:(id<TextViewObserver>)observer {
    [observers addObject:observer];
}

- (void)removeDelegateObserver:(id<TextViewObserver>)observer {
    [observers removeObject:observer];
}

#pragma mark -
#pragma mark Delegate Methods


- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
    
    if (self.textView.servicesOn) {
        [self.textView.codeNavigationAssistant highlightCurrentLineForegroundWithRange:newSelectedCharRange];
        
    }
    return newSelectedCharRange;
}


- (void)textViewDidChangeSelection:(NSNotification *)notification {
    [self.scrollView.verticalRulerView setNeedsDisplay:YES];
    
}

- (void)textDidChange:(NSNotification *)notification {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateMessageCollection:) object:nil];
    [backgroundQueue addOperation:op];
    [observers makeObjectsPerformSelector:@selector(textDidChange:) withObject:notification];
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.model] && self.model.faultingState >0) {
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
#ifdef DEBUG
    NSLog(@"TextViewController dealloc");
#endif
    [self unbind:@"liveScrolling"];
    [self.textView removeObserver:self forKeyPath:@"currentRow"];
    [self unregisterModelObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
