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
@interface TextViewController ()
- (void) initialize;
@end

@implementation TextViewController


- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        self.parent = parent;
        observers = [NSMutableSet new];
    }
    return self;
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




#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"TextViewController dealloc");
#endif
}

@end
