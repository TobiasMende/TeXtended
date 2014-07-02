//
//  MultiLineCellEditorViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Completion;
@interface MultiLineCellEditorViewController : NSViewController<NSTextViewDelegate> {
    NSValueTransformer *transformer;
}

- (id)initWithCompletion:(Completion *)completion andKeyPath:(NSString *)keyPath;

@property Completion *completion;
@property NSString *keyPath;
@property (strong) IBOutlet NSTextView *textView;

@end
