//
//  MessageViewController.h
//  TeXtended
//
//  Created by Max Bannach on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MessageInfoViewController;
/**
 * This class handels a view for messages to diplay in a popover beside a line number.
 *
 * @author Max Bannach
 */
@interface MessageViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate> {
    
    /** Elements (messages) to diplay in the view */
    NSMutableArray *elements;
    
    /** The Popover that will be shown */
    NSPopover* popover;
    
    /** Position where the popover should be shown */
    NSRect displayPosition;
    
    /** The preferredEdge of the popover */
    NSRectEdge prefEdge;
    MessageInfoViewController *infoController;
    /** View where the popover should be shown in  */
    __unsafe_unretained NSView* displayView;
}
@property (strong) IBOutlet NSTableView *messageTable;
- (IBAction)handleClick:(id)sender;

/** Display the popover */
- (void) pop;

/** Closes the popover */
- (void) close;

/**
 * Init with a set of messages, these messages will be displayed.
 *
 * @param messages
 * @return ide
 */
- (id) initWithTrackingMessages:(NSMutableSet*) messages forRec:(NSRect)rec onView:(NSView*) view withPreferredEdge:(NSRectEdge)preferredEdge;

@property (strong) IBOutlet NSTableView *_messageTable;
@end
