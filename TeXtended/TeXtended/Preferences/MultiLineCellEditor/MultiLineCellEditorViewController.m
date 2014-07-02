//
//  MultiLineCellEditorViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MultiLineCellEditorViewController.h"
#import "CompletionWhiteSpaceValueTransformer.h"

@interface MultiLineCellEditorViewController ()

@end

@implementation MultiLineCellEditorViewController

- (id)initWithCompletion:(Completion *)completion andKeyPath:(NSString *)keyPath {
    self = [super initWithNibName:@"MultiLineCellEditorView" bundle:nil];
    if (self) {
        self.completion = completion;
        self.keyPath = keyPath;
        transformer = [CompletionWhiteSpaceValueTransformer new];
    }
    return self;
}


- (void)loadView {
    [super loadView];
    [self.textView bind:@"value" toObject:self.completion withKeyPath:self.keyPath options:@{NSValueTransformerBindingOption: transformer,NSContinuouslyUpdatesValueBindingOption:@(YES), NSValidatesImmediatelyBindingOption:@(YES)}];
}

- (void)dealloc {
    [self.textView unbind:@"value"];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    [self.view.window close];
}
@end
