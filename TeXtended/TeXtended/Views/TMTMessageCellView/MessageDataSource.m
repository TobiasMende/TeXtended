//
//  MessageDataSource.m
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/TMTTableView.h>
#import <TMTHelperCollection/TMTTableRowView.h>
#import <TMTHelperCollection/TMTLog.h>
#import "MessageDataSource.h"
#import "TrackingMessage.h"
#import "TMTMessageCellView.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "DocumentCreationController.h"
#import "SimpleDocument.h"
#import "MessageInfoViewController.h"
#import "TMTNotificationCenter.h"
#import "Compilable.h"
#import "TMTCustomView.h"

@interface MessageDataSource ()
- (void) handleRightClick:(id)sender;
- (void) handleClick:(id)sender;
- (void) messagesDidChange:(NSNotification *)note;
@end

@implementation MessageDataSource

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    DDLogWarn(@"START awake");
    [super awakeFromNib];
    messageLock = [[NSLock alloc] init];
    [self.tableView setTarget:self];
    [self.tableView setRightClickAction:@selector(handleRightClick:)];
    [self.tableView setAction:@selector(handleClick:)];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (void)messagesDidChange:(NSNotification *)note {
    self.messages = note.userInfo[TMTMessageCollectionKey];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TMTMessageCellView *result = [tableView makeViewWithIdentifier:@"TMTMessageCellView" owner:self];
    if (!result) {
        NSViewController *c = [[NSViewController alloc] initWithNibName:@"TMTMessageCellView" bundle:nil];
        result = (TMTMessageCellView*)c.view;
    }
    if (row < self.messages.count) {
        TrackingMessage *item = (self.messages)[row];
        result.model = [self.model modelForTexPath:item.document byCreating:NO];
        result.objectValue = item;
    }
    return result;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    TMTTableRowView *view = [tableView makeViewWithIdentifier:@"TMTTableRowView" owner:self];
    if (!view) {
        view = [[TMTTableRowView alloc] init];
    }
    return view;
}

- (void)handleRightClick:(id)sender {
    if (popover) {
        [popover close];
        popover = nil;
    }
    NSInteger row = [self.tableView selectedRow];
    if (row < 0) {
        return;
    }
    NSView *view = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
    if (row < self.messages.count) {
        TrackingMessage *message = (self.messages)[row];
        if (!infoController) {
            infoController = [[MessageInfoViewController alloc] init];
        }
        if (!popover) {
            popover = [[NSPopover alloc] init];
            popover.animates = YES;
            popover.behavior = NSPopoverBehaviorTransient;
        }
        infoController.message = message;
        infoController.model = self.model;
        [(TMTCustomView*)infoController.view setBackgroundColor:[TrackingMessage backgroundColorForType:message.type]];
        popover.contentViewController = infoController;
        [popover showRelativeToRect:self.tableView.bounds ofView:view preferredEdge:NSMaxXEdge];
    }
    
}


- (void)handleClick:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row < self.messages.count) {
        TrackingMessage *message = (self.messages)[row];
        
        [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:message.document withReferenceModel:self.model andCompletionHandler:^(DocumentModel *newModel) {
            if (newModel) {
                newModel.currentMainDocument = self.model;
                [[TMTNotificationCenter centerForCompilable:newModel] postNotificationName:TMTShowLineInTextViewNotification object:newModel userInfo:@{TMTIntegerKey: [NSNumber numberWithInteger:message.line]}];
            } else {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:message.document]];
            }
        }];
    }
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    //[rowView setBackgroundColor:[NSColor greenColor]];
    [messageLock lock];
    if (row < self.messages.count) {
        TrackingMessage *m = (self.messages)[row];
        [rowView setBackgroundColor:[TrackingMessage backgroundColorForType:m.type]];
    }
    [messageLock unlock];
    
}

- (void)setModel:(DocumentModel *)model {
    if (_model) {
        [_model removeObserver:self forKeyPath:@"texPath"];
        [[TMTNotificationCenter centerForCompilable:_model] removeObserver:self name:TMTMessagesDidChangeNotification object:_model];
    }
    _model = model;
    if (_model) {
        [[TMTNotificationCenter centerForCompilable:_model] addObserver:self selector:@selector(messagesDidChange:) name:TMTMessagesDidChangeNotification object:_model];
        NSArray *messages = [_model mergedGlobalMessages];
        if (messages) {
            self.messages = messages;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }
    }
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    self.tableView.rightClickAction = nil;
    self.tableView.singleClickAction = nil;
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
