//
//  AutoCompletionWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface AutoCompletionWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) NSDictionary *additionalInformation;
@property (nonatomic) NSArray *content;
@property (nonatomic) NSTextView *parent;

@property (readwrite, copy) void (^selectionDidChangeCallback)(id completion);

- (id)initWithSelectionDidChangeCallback:(void (^)(id completion)) callback;

- (void)  positionWindowWithContent:(NSArray *) content andInformation:(NSDictionary *)additionalInformation;

#pragma mark - Key Events
- (void) arrowDown;
- (void) arrowUp;
- (void) enter;

@end
