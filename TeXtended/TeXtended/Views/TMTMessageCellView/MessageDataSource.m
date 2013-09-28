//
//  MessageDataSource.m
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageDataSource.h"
#import "TrackingMessage.h"
#import "TMTMessageCellView.h"
#import "Constants.h"
#import "MessageCollection.h"
#import "DocumentModel.h"
#import "TMTTableView.h"
#import "TMTTableRowView.h"
#import "DocumentCreationController.h"
#import "SimpleDocument.h"
#import "MessageInfoViewController.h"
#import "TMTCustomView.h"
#import "TMTLog.h"

@interface MessageDataSource ()
- (void) handleMessageUpdate:(NSNotification *)note;
- (void) handleDoubleClick:(id)sender;
- (void) handleClick:(id)sender;
@end

@implementation MessageDataSource

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    messageLock = [[NSLock alloc] init];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(handleDoubleClick:)];
    [self.tableView setAction:@selector(handleClick:)];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TMTMessageCellView *result = [tableView makeViewWithIdentifier:@"TMTMessageCellView" owner:self];
    if (!result) {
        NSViewController *c = [[NSViewController alloc] initWithNibName:@"TMTMessageCellView" bundle:nil];
        result = (TMTMessageCellView*)c.view;
    }
    if (row < self.messages.count) {
        TrackingMessage *item = [self.messages objectAtIndex:row];
        result.model = self.model;
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

- (void)handleDoubleClick:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row < self.messages.count) {
        TrackingMessage *message = [self.messages objectAtIndex:row];
        if ([message.document isEqualToString:self.model.texPath]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTShowLineInTextViewNotification object:self.model userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:message.line] forKey:TMTIntegerKey]];
        } else if(self.model.project){
            //TODO: Hanlde external path in project mode
            NSBeep();
        } else {
            // Open new single document:
            NSURL *url = [NSURL fileURLWithPath:message.document];
            [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                if (error) {
                    [[NSWorkspace sharedWorkspace] openURL:url];
                } else {
                    if ([document isKindOfClass:[SimpleDocument class]]) {
                        DocumentModel *m = [(SimpleDocument*) document model];
                        [[NSNotificationCenter defaultCenter] postNotificationName:TMTShowLineInTextViewNotification object:m userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:message.line] forKey:TMTIntegerKey]];
                         [[NSNotificationCenter defaultCenter] postNotificationName:TMTLogMessageCollectionChanged object:m userInfo:[NSDictionary dictionaryWithObject:self.collection forKey:TMTMessageCollectionKey]];
                    }
                }
            }];
        }
    }
}


- (void)handleClick:(id)sender {
    if (popover) {
        [popover close];
        popover = nil;
    }
    NSInteger row = [self.tableView clickedRow];
    if (row < 0) {
        return;
    }
    NSView *view = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
    if (row < self.messages.count) {
        TrackingMessage *message = [self.messages objectAtIndex:row];
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


- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    //[rowView setBackgroundColor:[NSColor greenColor]];
    [messageLock lock];
    if (row < self.messages.count) {
        TrackingMessage *m = [self.messages objectAtIndex:row];
        [rowView setBackgroundColor:[TrackingMessage backgroundColorForType:m.type]];
    }
    [messageLock unlock];
    
}

- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if (_model) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTMessageCollectionChanged object:_model];
        }
        _model = model;
        if (_model) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageUpdate:) name:TMTMessageCollectionChanged object:_model];
        }
    }
}


- (void)handleMessageUpdate:(NSNotification *)note {
    [messageLock lock];
    self.collection = [note.userInfo objectForKey:TMTMessageCollectionKey];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.collection.count];
    [temp addObjectsFromArray:[self.collection.set allObjects]];
    [temp sortUsingSelector:@selector(compare:)];
    self.messages = temp;
    [messageLock unlock];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    self.tableView.dataSource = nil;
    
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
