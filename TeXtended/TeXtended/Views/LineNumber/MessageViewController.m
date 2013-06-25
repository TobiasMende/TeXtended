//
//  MessageViewController.m
//  TeXtended
//
//  Created by Max Bannach on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageViewController.h"
#import "TrackingMessage.h"
#import "TMTMessageCellView.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (id) initWithTrackingMessages:(NSMutableSet*) messages {
    self = [super initWithNibName:@"MessageView" bundle:nil];
    if (self) {
        elements = [[NSMutableArray alloc] init];
        for (TrackingMessage *msg in messages) {
            [elements addObject:msg];
        }
    }
    return self;
}

- (void) awakeFromNib {
    [self setSize];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return [elements count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    TMTMessageCellView *result = [tableView makeViewWithIdentifier:@"TMTMessageCellView" owner:self];
    if (!result) {
        NSViewController *c = [[NSViewController alloc] initWithNibName:@"TMTMessageCellView" bundle:nil];
        result = (TMTMessageCellView*)c.view;
    }
    TrackingMessage *item = [elements objectAtIndex:row];
    //result.model = self.model;
    result.objectValue = item;
    return result;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    TrackingMessage *m = [elements objectAtIndex:row];
    [rowView setBackgroundColor:[TrackingMessage backgroundColorForType:m.type]];
}

- (void) setSize {
    if ([elements count] == 1) {
        [self.view setFrameSize:NSSizeFromString(@"{300,38}")];
    } else if ([elements count] == 2) {
        [self.view setFrameSize:NSSizeFromString(@"{300,74}")];
    } else {
        [self.view setFrameSize:NSSizeFromString(@"{300,110}")];
    }
}

@end
