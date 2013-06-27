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
    TrackingMessage *item = [self.messages objectAtIndex:row];
    result.model = self.model;
    result.objectValue = item;
    return result;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[TMTTableRowView alloc] init];
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
    NSInteger row = [self.tableView clickedRow];
    if (row < self.messages.count) {
        //TrackingMessage *message = [self.messages objectAtIndex:row];
        //TODO: show popover
    }

}


- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    //[rowView setBackgroundColor:[NSColor greenColor]];
    TrackingMessage *m = [self.messages objectAtIndex:row];
    [rowView setBackgroundColor:[TrackingMessage backgroundColorForType:m.type]];
}

- (void)setModel:(DocumentModel *)model {
    if (_model) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTMessageCollectionChanged object:_model];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if (_model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageUpdate:) name:TMTMessageCollectionChanged object:_model];
    }
}


- (void)handleMessageUpdate:(NSNotification *)note {
    self.collection = [note.userInfo objectForKey:TMTMessageCollectionKey];
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:self.collection.count];
    for (TrackingMessage *message in self.collection.set) {
        [temp addObject:message];
    }
    [temp sortUsingSelector:@selector(compare:)];
    self.messages = temp;
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
