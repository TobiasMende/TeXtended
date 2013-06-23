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

@interface MessageDataSource ()
- (void) handleMessageUpdate:(NSNotification *)note;
- (void) handleDoubleClick:(id)sender;
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
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < self.messages.count) {
        return [self.messages objectAtIndex:row];
    }
    return nil;
}


- (void)handleDoubleClick:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row < self.messages.count) {
        TrackingMessage *message = [self.messages objectAtIndex:row];
        if ([message.document isEqualToString:self.model.texPath]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTShowLineInTextViewNotification object:self.model userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:message.line] forKey:TMTIntegerKey]];
        }
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
    MessageCollection *messages = [note.userInfo objectForKey:TMTMessageCollectionKey];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:messages.count];
    for (TrackingMessage *message in messages.set) {
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
