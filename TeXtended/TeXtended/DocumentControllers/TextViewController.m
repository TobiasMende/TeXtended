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

@end

@implementation TextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lineNumberView = [[LineNumberView alloc] initWithScrollView:[self scrollView]];
        [self.scrollView setVerticalRulerView:lineNumberView];
        [self.scrollView setHasHorizontalRuler:NO];
        [self.scrollView setHasVerticalRuler:YES];
        [self.scrollView setRulersVisible:YES];
    }
    
    return self;
}


- (NSString *)content {
    return [self.textView string];
}

- (void)setContent:(NSString *)content {
    [self.textView setString:content];
}

@end
