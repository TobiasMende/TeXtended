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
@interface TextViewController ()
- (void) initialize;
@end

@implementation TextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"TextView" bundle:nil];
    if (self) {
        self.parent = parent;
        [self initialize];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self initialize];
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

- (void)dealloc {
    NSLog(@"TextViewController dealloc");
}

@end
