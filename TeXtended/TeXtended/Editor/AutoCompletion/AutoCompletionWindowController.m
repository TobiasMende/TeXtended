//
//  AutoCompletionWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AutoCompletionWindowController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "HighlightingTextView.h"
#import "CustomTableCellView.h"
#import "CiteCompletionView.h"
#import "DefaultCompletionView.h"
#import "DBLPButtonView.h"

LOGGING_DEFAULT

@interface AutoCompletionWindowController ()

    - (NSRect)toGlobalCharBounds:(NSRect)localCharBound;

/**
 Calculates an appropriate frame for the completion window (according to the cursor position in global coordinates)
 
 @param globalCharBounds the charBounds of the last typed character
 @return the final window frame
 */
    - (NSRect)calculateFinalFrame:(NSRect)globalCharBounds;

    - (NSTableCellView *)customTableCellViewFor:(NSTableView *)view andRow:(NSInteger)row;

    - (NSInteger)totalWindowHeight;

@end

@implementation AutoCompletionWindowController

    - (id)initWithWindow:(NSWindow *)window
    {
        self = [super initWithWindow:window];
        if (self) {
            // Initialization code here.
        }
        return self;
    }

    - (void)setContent:(NSArray *)content
    {
        _content = content;

        [self.tableView reloadData];
    }


    - (void)setParent:(NSTextView *)parent
    {
        if (_parent) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextDidEndEditingNotification object:_parent];
        }
        _parent = parent;
        if (_parent) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:NSTextDidEndEditingNotification object:_parent
            ];
        }
    }

    - (void)positionWindowWithContent:(NSArray *)content andInformation:(NSDictionary *)additionalInformation
    {
        self.content = content;
        self.additionalInformation = additionalInformation;
        NSRange range = NSMakeRange(self.parent.selectedRange.location - 1, 1);
        NSRange theTextRange = [self.parent.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
        NSRect layoutRect = [self.parent.layoutManager boundingRectForGlyphRange:theTextRange inTextContainer:self.parent.textContainer];
        NSRect globalCharBound = [self toGlobalCharBounds:layoutRect];

        [self.window setFrame:[self calculateFinalFrame:globalCharBound] display:YES animate:NO];
        [self.window orderFront:self];
        if (self.tableView.numberOfRows > 0) {
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }

    }


    - (NSRect)calculateFinalFrame:(NSRect)globalCharBounds
    {
        NSSize estimatedWindowSize = NSMakeSize(self.window.frame.size.width, [self totalWindowHeight]);
        NSPoint origin;

        CGFloat screenEnd = NSMaxX([[NSScreen mainScreen] visibleFrame]);

        origin.y = (NSMinY(globalCharBounds) - estimatedWindowSize.height >= 0 ? NSMinY(globalCharBounds) - estimatedWindowSize.height : NSMaxY(globalCharBounds));
        origin.x = (NSMaxX(globalCharBounds) + estimatedWindowSize.width <= screenEnd ? NSMaxX(globalCharBounds) : screenEnd - estimatedWindowSize.width);

        NSRect finalRect;
        finalRect.size = estimatedWindowSize;
        finalRect.origin = origin;
        return finalRect;
    }

    - (NSInteger)totalWindowHeight
    {
        NSInteger rowHeight;
        switch ([(self.additionalInformation)[TMTCompletionTypeKey] intValue]) {
            case TMTCiteCompletion:
                rowHeight = [CiteCompletionView defaultViewHeight];
                break;

            default:
                rowHeight = [DefaultCompletionView defaultViewHeight];
                break;
        }
        NSInteger total = self.content.count * (rowHeight + 2);
        if ([(self.additionalInformation)[TMTShouldShowDBLPKey] boolValue]) {
            total += [DBLPButtonView defaultViewHeight] + 2;
        }
        return total;
    }


    - (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
    {
        CGFloat height;
        if (row >= 0 && (NSUInteger)row < self.content.count) {
            switch ([(self.additionalInformation)[TMTCompletionTypeKey] intValue]) {
                case TMTCiteCompletion:
                    height = [CiteCompletionView defaultViewHeight];
                    break;

                default:
                    height = [DefaultCompletionView defaultViewHeight];
                    break;
            }
        } else {
            height = [DBLPButtonView defaultViewHeight];
        }
        return height;
    }

    - (NSRect)toGlobalCharBounds:(NSRect)localCharBound
    {
        NSPoint pos = localCharBound.origin;
        NSPoint localPosition = [self.parent convertPoint:pos toView:self.window.contentView];
        NSPoint globalPosition = self.parent.window.frame.origin;
        globalPosition.x += localPosition.x;
        globalPosition.y += localPosition.y;
        return NSMakeRect(globalPosition.x, globalPosition.y - localCharBound.size.height, localCharBound.size.width, localCharBound.size.height);
    }

    - (id)initWithSelectionDidChangeCallback:(void (^)(id completion))callback
    {
        self = [super initWithWindowNibName:@"AutoCompletionWindow"];
        if (self) {
            self.selectionDidChangeCallback = callback;
        }
        return self;
    }

    - (void)windowDidLoad
    {
        [super windowDidLoad];

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

#pragma mark - Table View Delegate Methods

    - (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
    {
        NSInteger result = self.content.count;
        if ([(self.additionalInformation)[TMTShouldShowDBLPKey] boolValue]) {
            result++;
        }
        return result;
    }

    - (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
    {

        if (row >= 0 && (NSUInteger)row < self.content.count) {
            NSTableCellView *result = [self customTableCellViewFor:tableView andRow:row];
            tableView.rowHeight = [self tableView:tableView heightOfRow:row];
            id item = (self.content)[row];
            result.objectValue = item;
            return result;
        } else if ([(self.additionalInformation)[TMTShouldShowDBLPKey] boolValue]) {
            NSView *result = [tableView makeViewWithIdentifier:@"DBLPButtonView" owner:self];
            if (!result) {
                NSViewController *c = [[NSViewController alloc] initWithNibName:@"DBLPButtonView" bundle:nil];
                result = c.view;
            }
            return result;
        } else {
            return nil;
        }
    }

    - (NSTableCellView *)customTableCellViewFor:(NSTableView *)view andRow:(NSInteger)row
    {
        NSView *result;
        switch ([(self.additionalInformation)[TMTCompletionTypeKey] intValue]) {
            case TMTCiteCompletion:
                result = [view makeViewWithIdentifier:@"CiteCompletionView" owner:self];
                if (!result) {
                    NSViewController *c = [[NSViewController alloc] initWithNibName:@"CiteCompletionView" bundle:nil];
                    result = c.view;
                }
                break;

            default:
                result = [view makeViewWithIdentifier:@"DefaultCompletionView" owner:self];
                if (!result) {
                    NSViewController *c = [[NSViewController alloc] initWithNibName:@"DefaultCompletionView" bundle:nil];
                    result = c.view;
                }
                break;
        }
        return (NSTableCellView *) result;
    }

    - (void)tableViewSelectionDidChange:(NSNotification *)notification
    {
        NSInteger currentIndex = self.tableView.selectedRow;
        if (currentIndex < 0 || (NSUInteger)currentIndex >= self.content.count) {
            return;
        }

        if (![(self.additionalInformation)[TMTDropCompletionKey] boolValue]) {
            NSRange prefixRange = [self.parent rangeForUserCompletion];
            if (prefixRange.location == NSNotFound) {
                DDLogWarn(@"Got invalid prefix for user completion");
                return;
            }
        }

        id completion = (self.content)[currentIndex];
        if (self.selectionDidChangeCallback) {
            self.selectionDidChangeCallback(completion);
        }
    }

#pragma mark - Key Events

    - (void)arrowDown
    {
        NSInteger count = self.tableView.numberOfRows;
        NSInteger current = [self.tableView selectedRow];
        if (count == 0 || current < 0) {
            return;
        }
        current = (current + 1) % count;
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:current] byExtendingSelection:NO];
        [self.tableView scrollRowToVisible:current];
    }

    - (void)arrowUp
    {
        NSInteger count = self.tableView.numberOfRows;
        NSInteger current = [self.tableView selectedRow];
        if (count == 0 || current < 0) {
            return;
        }
        current = (current > 0 ? current - 1 : count - 1);
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:current] byExtendingSelection:NO];
        [self.tableView scrollRowToVisible:current];
    }

    - (void)enter
    {

    }


@end
