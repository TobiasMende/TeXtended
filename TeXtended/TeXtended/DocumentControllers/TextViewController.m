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
@interface TextViewController ()
- (void) initialize;
- (void) handleCompilerEnd:(NSNotification *)note;
- (void) registerModelObserver;
- (void) unregisterModelObserver;
@end

@implementation TextViewController


- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        self.parent = parent;
        observers = [NSMutableSet new];
        self.model = [[self.parent documentController] model];
        
        [self registerModelObserver];
    }
    return self;
}

- (void)registerModelObserver {
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    for (DocumentModel *m in self.model.mainDocuments) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCompilerEnd:) name:TMTCompilerDidEndCompiling object:m];
    }
}

- (void)unregisterModelObserver {
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:nil];
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
    [self.textView setDelegate:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (DocumentModel *m in self.model.mainDocuments) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCompilerEnd:) name:TMTCompilerDidEndCompiling object:m];
    }
    //TODO: reload file path?
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

- (void)removeObserver:(id<TextViewObserver>)observer {
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
    [observers makeObjectsPerformSelector:@selector(textDidChange:) withObject:notification];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.model] && self.model.faultingState >0) {
        [self unregisterModelObserver];
        if ([keyPath isEqualToString:@"mainDocuments"]) {
            [self registerModelObserver];
        }
    }
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"TextViewController dealloc");
#endif
    [self unregisterModelObserver];
}

@end
