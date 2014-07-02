//
//  HighlightingTextView.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "HighlightingTextView.h"
#import "LatexSyntaxHighlighter.h"
#import "BracketHighlighter.h"
#import "CodeNavigationAssistant.h"
#import "Completion.h"
#import "EnvironmentCompletion.h"
#import "CompletionHandler.h"
#import "CodeExtensionEngine.h"
#import "LineNumberView.h"
#import "GoToLineSheetController.h"
#import "AutoCompletionWindowController.h"
#import "MatrixViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TextViewLayoutManager.h"
#import "DBLPIntegrator.h"
#import "QuickPreviewManager.h"
#import "CompletionManager.h"
#import "NSString+PathExtension.h"
#import "ProjectModel.h"
#import "FirstResponderDelegate.h"
#import <TMTHelperCollection/NSString+LatexExtensions.h>
#import <TMTHelperCollection/NSTextView+TMTExtensions.h>
#import <TMTHelperCollection/NSString+TMTExtensions.h>
#import "NSTextView+TMTEditorExtension.h"

static const double UPDATE_AFTER_SCROLL_DELAY = 1.0;

static const NSSet *DEFAULT_KEYS_TO_OBSERVE;

@interface HighlightingTextView ()

/**
 Method for getting the new first range after swapping two ranges.
 
 @param first a random line range
 @param second another random line range
 
 @return the first range, if it was the first range before, the second otherwise.
 */
    - (NSRange)firstRangeAfterSwapping:(NSRange)first and:(NSRange)second;

/** Method for swapping text in two ranges 
 
 @param first first range
 @param second second range
 
 */
    - (void)swapTextIn:(NSRange)first and:(NSRange)second;

/** Method for setting up all user defaults observer */
    - (void)registerUserDefaultsObserver;

/** Method for deleting all observations and bindings to the user defaults */
    - (void)unregisterUserDefaultsObserver;

    - (LineNumberView *)lineNumberView;

    - (void)extendedComplete:(id)sender;

    - (void)finalyUpdateTrackingAreas:(id)userInfo;

    - (void)dismissCompletionWindow;

    - (void)showDBLPSearchView;

    - (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info;

- (void)selectAndInsertDropCompletion:(NSArray *)insertions;
- (void) insertDropCompletion:(id)sender;
@end

@implementation HighlightingTextView

    + (void)initialize
    {
        if (self == [HighlightingTextView class]) {
            DEFAULT_KEYS_TO_OBSERVE = [NSSet setWithObjects:TMT_EDITOR_SELECTION_BACKGROUND_COLOR, TMT_EDITOR_SELECTION_FOREGROUND_COLOR, TMT_EDITOR_LINE_WRAP_MODE, TMT_EDITOR_HARD_WRAP_AFTER, TMT_REPLACE_INVISIBLE_SPACES, TMT_REPLACE_INVISIBLE_LINEBREAKS, TMTLineSpacing, nil];
        }
    }

    - (id)initWithFrame:(NSRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {

        }

        return self;
    }

    - (void)registerUserDefaultsObserver
    {
        for (NSString *key in DEFAULT_KEYS_TO_OBSERVE) {
            [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:key] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:NULL];
        }
    }

    - (void)unregisterUserDefaultsObserver
    {
        for (NSString *key in DEFAULT_KEYS_TO_OBSERVE) {
            [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:key]];
        }
    }

    - (void)awakeFromNib
    {

        [super awakeFromNib];
        bracketHighlighter = [[BracketHighlighter alloc] initWithTextView:self];
        _codeNavigationAssistant = [[CodeNavigationAssistant alloc] initWithTextView:self];
        completionHandler = [[CompletionHandler alloc] initWithTextView:self];
        _codeExtensionEngine = [[CodeExtensionEngine alloc] initWithTextView:self];

        [self registerUserDefaultsObserver];
        [self setCompletionEnabled:YES];
        self.servicesOn = YES;
        self.enableQuickPreviewAssistant = YES;
    }




    - (id)debugQuickLookObject {
        return self.attributedString;
    }

    - (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index additionalInformation:(NSDictionary **)info
    {
        if (!self.servicesOn) {
            return nil;
        }
        if ([completionHandler willHandleCompletionForPartialWordRange:charRange]) {
            [self.undoManager beginUndoGrouping];
            NSArray *completions = [completionHandler completionsForPartialWordRange:charRange indexOfSelectedItem:index additionalInformation:info];
            [self.undoManager endUndoGrouping];
            return completions;
        }
        return nil;
    }

    - (void)complete:(id)sender
    {
        if (self.completionEnabled) {
            [self extendedComplete:sender];
        } else {
            [super complete:sender];
        }
    }

    - (void)dismissCompletionWindow
    {
        [autoCompletionController.window orderOut:self];
        autoCompletionController = nil;
    }


    - (void)extendedComplete:(id)sender
    {
        if (!sender) {
            [self dismissCompletionWindow];
            if (self.selectedRange.length > 0) {
                [self deleteBackward:self];
            }
            return;
        }
        NSRange wordRange = [self rangeForUserCompletion];
        if (wordRange.location == NSNotFound) {
            [self dismissCompletionWindow];
            return;
        }
        NSDictionary *additionalInformation;
        NSArray *completions = [self completionsForPartialWordRange:[self rangeForUserCompletion] indexOfSelectedItem:0 additionalInformation:&additionalInformation];
        if (completions.count > 0 || [additionalInformation[TMTShouldShowDBLPKey] boolValue]) {
            if (!autoCompletionController) {
                __unsafe_unretained id weakSelf = self;
                autoCompletionController = [[AutoCompletionWindowController alloc] initWithSelectionDidChangeCallback:^(id completion)
                {
                    [weakSelf insertCompletion:completion forPartialWordRange:[weakSelf rangeForUserCompletion] movement:NSOtherTextMovement isFinal:NO];
                }];
                autoCompletionController.parent = self;
            }
            [autoCompletionController positionWindowWithContent:completions andInformation:additionalInformation];
            if (completions.count > 0) {
                [self insertCompletion:completions[0] forPartialWordRange:wordRange movement:NSOtherTextMovement isFinal:NO];
            }
        } else {
            [self dismissCompletionWindow];
        }
    }

    - (NSRange)rangeForUserCompletion
    {
        __block NSRange range = NSMakeRange(NSNotFound, 0);
        NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
        if (NSMaxRange(lineRange) >= NSMaxRange(self.selectedRange) && lineRange.location <= self.selectedRange.location) {
            NSUInteger length = self.selectedRange.location - lineRange.location;
            NSRange searchRange = NSMakeRange(lineRange.location, length);
            [self.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationByWords | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
            {
                if (NSMaxRange(substringRange) == self.selectedRange.location) {
                    range = substringRange;
                }
                *stop = YES;
            }];
        }
        return range;
    }

    - (LineNumberView *)lineNumberView
    {
        if ([self.enclosingScrollView.verticalRulerView isKindOfClass:[LineNumberView class]]) {
            return (LineNumberView *) self.enclosingScrollView.verticalRulerView;
        }
        return nil;

    }

    - (void)insertCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {
        if (!self.servicesOn) {
            return;
        }
        
        [completionHandler insertCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
        if (flag || movement == NSCancelTextMovement || movement == NSLeftTextMovement) {
            [self dismissCompletionWindow];
        }


    }

    - (void)insertDropCompletionForModel:(DocumentModel *)model
    {
        NSString *base = model.texPath ? [model.texPath stringByDeletingLastPathComponent] : nil;
        
        for (NSString *fileName in droppedFileNames) {
            NSString *path = base ? [fileName relativePathWithBase:base] : fileName;
             NSArray *insertions = [[CompletionManager sharedInstance] possibleDropCompletionsForPath:path];
            [self selectAndInsertDropCompletion:insertions];
            if (![fileName isEqualToString:droppedFileNames.lastObject]) {
                [self insertNewline:self];
            }
        }

        [self jumpToNextPlaceholder];

        // After drop operation the first responder remains the drag source
        [[self window] makeFirstResponder:self];
    }

    - (void)insertDropCompletionForPath:(NSString *)path
    {
        
        for (NSString *fileName in droppedFileNames) {
            NSArray *insertions = [[CompletionManager sharedInstance] possibleDropCompletionsForPath:[fileName relativePathWithBase:[path stringByDeletingLastPathComponent]]];
            
            [self selectAndInsertDropCompletion:insertions];
    
            
            if (![droppedFileNames isEqualTo:droppedFileNames.lastObject]) {
                [self insertNewline:self];
            }
        }

        [self jumpToNextPlaceholder];

        // After drop operation the first responder remains the drag source
        [[self window] makeFirstResponder:self];
    }

- (void)selectAndInsertDropCompletion:(NSArray *)insertions {
    if (insertions.count == 1) {
        [self insertDropCompletion:insertions.firstObject];
        return;
    }
    NSMenu *select = [NSMenu new];
    select.font = [NSFont menuBarFontOfSize:[NSFont smallSystemFontSize]];
    for (NSAttributedString *insertion in insertions) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:insertion.string action:@selector(insertDropCompletion:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = insertion;
        [select addItem:item];
    }
    
    NSPoint position = [self firstRectForCharacterRange:self.selectedRange].origin ;
    [select popUpMenuPositioningItem:select.itemArray.firstObject atLocation:position inView:nil];
}

- (void)insertDropCompletion:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        [self insertText:[self expandWhiteSpaces:[sender representedObject]]];
    } else if([sender isKindOfClass:[NSAttributedString class]]) {
        [self insertText:[self expandWhiteSpaces:sender]];

    }
}
    - (void)flagsChanged:(NSEvent *)theEvent
    {
        [super flagsChanged:theEvent];
        self.currentModifierFlags = theEvent.modifierFlags;
    }

    - (void)insertFinalCompletion:(id <CompletionProtocol>)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag
    {
        if (movement == NSCancelTextMovement || movement == NSLeftTextMovement) {
            [self delete:nil];
            [self dismissCompletionWindow];
            return;
        }
        
        if (charRange.length <= word.autoCompletionWord.length) {
            [super insertCompletion:word.autoCompletionWord forPartialWordRange:charRange movement:movement isFinal:flag];
        }
    }

    - (void)jumpToNextPlaceholder
    {
        if (!self.servicesOn) {
            return;
        }
        [self handleInsertTab];
    }

    - (void)jumpToPreviousPlaceholder
    {
        if (!self.servicesOn) {
            return;
        }
        [self handleInsertBacktab];
    }

    - (void)updateTrackingAreas
    {
        if (scrollTimer) {
            [scrollTimer invalidate];
        }
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_AFTER_SCROLL_DELAY target:self selector:@selector(finalyUpdateTrackingAreas:) userInfo:nil repeats:NO];

    }

    - (void)finalyUpdateTrackingAreas:(id)userInfo
    {
        [super updateTrackingAreas];

    }




    - (NSRange)extendRange:(NSRange)range byLines:(NSUInteger)numLines
    {
        for (NSUInteger iteration = 0 ; iteration < numLines ; iteration++) {
            BOOL update = NO;
            if (range.location > 0) {
                range.location -= 1;
                range.length += 1;
                update = YES;
            }
            if (NSMaxRange(range) < self.string.length - 1 && NSMaxRange(range) > 0) {
                range.length += 1;
                update = YES;
            }
            if (update) {
                range = [self.string lineTextRangeWithRange:range withLineTerminator:YES];
            } else {
                break;
            }
        }
        return range;
    }

    - (NSRange)extendedVisibleRange
    {
        NSRange range = [self.string lineTextRangeWithRange:self.visibleRange withLineTerminator:YES];

        return [self extendRange:range byLines:5];

    }

    - (void)insertText:(id)str
    {
        if (!self.servicesOn) {
            [super insertText:str];
            return;
        }
        if (![completionHandler shouldCompleteForInsertion:str]) {
            [self dismissCompletionWindow];
        }
        if (![bracketHighlighter shouldInsert:str]) {
            return;
        }
        [super insertText:str];
        if ([str isKindOfClass:[NSAttributedString class]]) {
            return;
        }
        NSUInteger position = [self selectedRange].location;
        // Some services should not run if a latex linebreak occures befor the current position
        if (![self.string latexLineBreakPreceedingPosition:position]) {
            if (self.completionEnabled && [completionHandler shouldCompleteForInsertion:str]) {
                [self complete:self];
            }
        } else {
            DDLogInfo(@"Latex LineBreak");
        }
        [bracketHighlighter handleBracketsOnInsertWithInsertion:str];
        NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
        [self.string lineTextRangeWithRange:self.selectedRange];
        if ([self.codeNavigationAssistant handleWrappingInLine:lineRange]) {
            [self scrollRangeToVisible:self.selectedRange];
        }

    }

    - (void)goToLine:(id)sender
    {
        if (!goToLineSheet) {
            goToLineSheet = [[GoToLineSheetController alloc] init];
        }
        goToLineSheet.line = [NSNumber numberWithInteger:self.currentRow];
        goToLineSheet.max = [NSNumber numberWithInteger:self.string.numberOfLines];
        [NSApp beginSheet:[goToLineSheet window]
           modalForWindow:[self window]
            modalDelegate:self
           didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
              contextInfo:nil];
        [NSApp runModalForWindow:[self window]];
    }

    - (IBAction)matrixView:(id)sender
    {
        if (!matrixView) {
            matrixView = [[MatrixViewController alloc] init];
        }
        [NSApp beginSheet:[matrixView window]
           modalForWindow:[self window]
            modalDelegate:self
           didEndSelector:@selector(matrixSheetDidEnd:returnCode:contextInfo:)
              contextInfo:nil];
        [NSApp runModalForWindow:[self window]];
    }

    - (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context
    {
        if (returnCode == NSRunStoppedResponse) {
            [self showLine:goToLineSheet.line.unsignedIntegerValue];
        }
    }

    - (void)matrixSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context
    {
        if (returnCode == NSRunStoppedResponse) {
            [self.undoManager beginUndoGrouping];
            EnvironmentCompletion *completion = [matrixView matrixCompletion];
            [completionHandler insertEnvironmentCompletion:completion forPartialWordRange:self.selectedRange movement:NSReturnTextMovement isFinal:YES];
            [self.undoManager endUndoGrouping];
        }
    }

    - (void)showLine:(NSUInteger)line
    {
        [self.window makeKeyAndOrderFront:self];
        if (line <= self.string.numberOfLines && line > 0) {
            NSRange lineRange = [self.string rangeForLine:line - 1];
            [self scrollRangeToVisible:lineRange];
            [self setSelectedRange:lineRange];
        } else {
            NSBeep();
        }

    }

    - (NSRange)rangeForLine:(NSUInteger)index
    {
        return [self.string rangeForLine:index - 1];
    }


    - (void)insertTab:(id)sender
    {
        if (!self.servicesOn) {
            [super insertTab:sender];
            return;
        }
        if (autoCompletionController) {
            NSInteger index = (autoCompletionController.tableView.selectedRow >= 0 ? autoCompletionController.tableView.selectedRow : 0);
            [self insertCompletion:(autoCompletionController.content)[index] forPartialWordRange:[self rangeForUserCompletion] movement:NSTabTextMovement isFinal:YES];
        } else if (![self handleInsertTab] && ![self.codeNavigationAssistant handleTabInsertion]) {
            [super insertTab:sender];
        }

    }


    - (void)insertBacktab:(id)sender
    {
        if (!self.servicesOn) {
            [super insertBacktab:sender];
            return;
        }
        if (![self handleInsertBacktab] && ![self.codeNavigationAssistant handleBacktabInsertion]) {
            [super insertBacktab:sender];
        }
    }

    - (void)insertNewline:(id)sender
    {
        if (!self.servicesOn) {
            [super insertNewline:sender];
            return;
        }
        [self.codeNavigationAssistant handleNewLineInsertion];
    }

    - (void)paste:(id)sender
    {
        [super paste:sender];
        if (!self.servicesOn) {
            return;
        }
        [self.codeExtensionEngine addLinksForRange:NSMakeRange(0, self.string.length)];
    }



#pragma mark -
#pragma mark Setter & Getter

    - (void)setLineWrapMode:(TMTLineWrappingMode)lineWrapMode
    {
        _lineWrapMode = lineWrapMode;

        if (lineWrapMode == SoftWrap) {
            [[self textContainer] setWidthTracksTextView:YES];
            [self setMaxSize:NSMakeSize(self.superview.visibleRect.size.width, FLT_MAX)];
            [self.textContainer setContainerSize:NSMakeSize(self.superview.visibleRect.size.width, FLT_MAX)];
        } else {
            [[self textContainer]
                    setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
            [[self textContainer] setWidthTracksTextView:NO];
            [self setAutoresizingMask:NSViewNotSizable];
            [self setMaxSize:NSMakeSize(FLT_MAX,
                    FLT_MAX)];

        }
    }

- (void)setPlaceholderReplacementEnabled:(BOOL)enable {
    completionHandler.shouldReplacePlaceholders = enable;
}



#pragma mark -
#pragma mark Input Actions

    - (void)selectCurrentBlock:(id)sender
    {
        NSRange blockRange = [self.string blockRangeForPosition:self.selectedRange.location];
        if (blockRange.location != NSNotFound) {
            self.selectedRange = blockRange;
        } else {
            NSBeep();
        }
    }

    - (void)gotoBlockBegin:(id)sender
    {
        NSRange beginRange = [self.string beginRangeForPosition:self.selectedRange.location];
        if (beginRange.location != NSNotFound) {
            self.selectedRange = NSMakeRange(NSMaxRange(beginRange), 0);
        } else {
            NSBeep();
        }
    }

    - (void)gotoBlockEnd:(id)sender
    {
        NSRange endRange = [self.string endRangeForPosition:self.selectedRange.location];
        if (endRange.location != NSNotFound) {
            self.selectedRange = NSMakeRange(endRange.location, 0);
        } else {
            NSBeep();
        }
    }

    - (void)moveLeft:(id)sender
    {
        [super moveLeft:sender];
        [self dismissCompletionWindow];
        if (!self.servicesOn) {
            return;
        }
        [bracketHighlighter highlightOnMoveLeft];


    }

    - (void)moveRight:(id)sender
    {
        [super moveRight:sender];
        [self dismissCompletionWindow];
        if (!self.servicesOn) {
            return;
        }
        [bracketHighlighter highlightOnMoveRight];
    }


    - (void)keyDown:(NSEvent *)theEvent
    {
        if (autoCompletionController) {
            switch (theEvent.keyCode) {
                case TMTArrowDownKeyCode:
                    [autoCompletionController arrowDown];
                    return;
                case TMTArrowUpKeyCode:
                    [autoCompletionController arrowUp];
                    return;
                case TMTBackKeyCode:
                    [self dismissCompletionWindow];
                    break;
                case TMTReturnKeyCode: { // Brackets are needed here due to compiler issues
                    if (autoCompletionController.tableView.selectedRow >= autoCompletionController.content.count) {
                        if ([(autoCompletionController.additionalInformation)[TMTShouldShowDBLPKey] boolValue]) {
                            [self showDBLPSearchView];
                        }
                    } else {
                        NSUInteger index = (NSUInteger) (autoCompletionController.tableView.selectedRow >= 0 ? autoCompletionController.tableView.selectedRow : 0);

                        if ([(autoCompletionController.additionalInformation)[TMTDropCompletionKey] boolValue]) {
                            NSDictionary *pathDioctionary = (autoCompletionController.content)[index];
                            NSString *path = [[self.firstResponderDelegate.model.project.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[pathDioctionary objectForKey:@"key"]];
                            [self insertDropCompletionForPath:path];
                            [self dismissCompletionWindow];
                        }
                        else {
                            [self insertCompletion:(autoCompletionController.content)[index] forPartialWordRange:[self rangeForUserCompletion] movement:NSReturnTextMovement isFinal:YES];
                        }
                    }
                    return;
                }
                default:
                    break;
            }

        }

        if (theEvent.keyCode == TMTTabKeyCode && theEvent.modifierFlags & NSAlternateKeyMask) {
            if (theEvent.modifierFlags & NSShiftKeyMask) {
                [self.codeNavigationAssistant handleBacktabInsertion];
            } else {
                [self.codeNavigationAssistant handleTabInsertion];
            }
        } else {
            [super keyDown:theEvent];
        }

        if (!self.servicesOn) {
            return;
        }
        [self.codeNavigationAssistant highlightCarret];
    }


    - (void)showDBLPSearchView
    {
        [self dismissCompletionWindow];
        if (!dblpIntegrator) {
            dblpIntegrator = [[DBLPIntegrator alloc] initWithTextView:self];
        }
        [dblpIntegrator initializeDBLPView];
    }

    - (void)showQuickPreviewAssistant:(id)sender
    {
        if (!quickPreview) {
            quickPreview = [[QuickPreviewManager alloc] initWithParentView:self];
        }
        [quickPreview showWindow:self];
    }


    - (void)mouseDown:(NSEvent *)theEvent
    {
        [super mouseDown:theEvent];
        if (!self.servicesOn) {
            return;
        }
        if (autoCompletionController) {
            [autoCompletionController close];
            autoCompletionController = nil;
        }
        [self.codeNavigationAssistant highlightCarret];
        if (self.selectedRanges.count == 1 || self.selectedRange.length == 0) {
            NSUInteger position = self.selectedRange.location;
            [self.codeExtensionEngine handleLinkAt:position];
        }

    }

    - (void)hardWrapText:(id)sender
    {

        TMTLineWrappingMode current = self.lineWrapMode;
        stopTextDidChangeNotifications = YES;
        self.lineWrapMode = HardWrap;
        [self.codeNavigationAssistant handleWrappingInRange:NSMakeRange(0, self.string.length)];
        self.lineWrapMode = current;
        stopTextDidChangeNotifications = NO;
        [self didChangeText];

    }

    - (IBAction)deleteLines:(id)sender
    {
        if (self.selectedRanges.count != 1) {
            return;
        }
        NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange withLineTerminator:YES];

        [self deleteTextInRange:[NSValue valueWithRange:totalRange] withActionName:NSLocalizedString(@"Delete Lines", @"line deletion")];


    }

    - (IBAction)moveLinesDown:(id)sender
    {
        if (self.selectedRanges.count != 1) {
            return;
        }
        NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
        if (NSMaxRange(totalRange) < self.string.length) {
            stopTextDidChangeNotifications = YES;
            NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
            NSRange nextLine = [self.string lineTextRangeWithRange:NSMakeRange(NSMaxRange(totalRange) + 1, 0)];
            [self.undoManager beginUndoGrouping];
            [self swapTextIn:totalRange and:nextLine];
            [self setSelectedRange:[self firstRangeAfterSwapping:totalRange and:nextLine]];
            [self.undoManager setActionName:actionName];
            [self.undoManager endUndoGrouping];
            stopTextDidChangeNotifications = NO;
            [self didChangeText];
        }
    }

    - (BOOL)respondsToSelector:(SEL)aSelector
    {
        if (aSelector == @selector(moveLinesUp:)) {
            NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
            return totalRange.location != 0;
        } else if (aSelector == @selector(moveLinesDown:)) {
            NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
            return NSMaxRange(totalRange) < self.string.length;
        } else if (aSelector == @selector(commentSelection:) || aSelector == @selector(uncommentSelection:) || aSelector == @selector(toggleComment:)) {
            return self.selectedRanges.count == 1;
        } else if (aSelector == @selector(jumpNextAnchor:) || aSelector == @selector(jumpPreviousAnchor:)) {
            return self.lineNumberView && self.lineNumberView.anchoredLines.count > 0;
        } else if (aSelector == @selector(showQuickPreviewAssistant:)) {
            return self.enableQuickPreviewAssistant && self.firstResponderDelegate.model.texPath && self.firstResponderDelegate.model.texPath.length > 0;
        } else {
            return [super respondsToSelector:aSelector] || (self.firstResponderDelegate && [self.firstResponderDelegate respondsToSelector:aSelector]);
        }
    }


    - (IBAction)moveLinesUp:(id)sender
    {
        if (self.selectedRanges.count != 1) {
            return;
        }
        NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
        if (totalRange.location > 0) {
            stopTextDidChangeNotifications = YES;
            NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
            NSRange lineBefore = [self.string lineTextRangeWithRange:NSMakeRange(totalRange.location - 1, 0)];
            [self.undoManager beginUndoGrouping];
            [self swapTextIn:lineBefore and:totalRange];
            [self setSelectedRange:NSMakeRange(lineBefore.location, totalRange.length)];
            [self.undoManager setActionName:actionName];
            [self.undoManager endUndoGrouping];
            stopTextDidChangeNotifications = NO;
            [self didChangeText];
        }
    }


- (void)didChangeText {
    if (!stopTextDidChangeNotifications) {
        [super didChangeText];
    }
}

    - (NSRange)firstRangeAfterSwapping:(NSRange)first and:(NSRange)second
    {
        if (second.length > first.length) {
            NSUInteger lengthDif = second.length - first.length;
            first.location = second.location + lengthDif;
            return first;
        } else if (first.length > second.length) {
            NSUInteger lengthDif = first.length - second.length;
            first.location = second.location - lengthDif;
            return first;
        }
        return second;
    }

    - (void)swapTextIn:(NSRange)first and:(NSRange)second
    {
        if (first.location > second.location) {
            // Ensure that first range ist before second range
            NSRange tmp = first;
            first = second;
            second = tmp;
        }

        NSAttributedString *secondStr;
        if (second.length == 0) {
            NSUInteger pos = second.location > 0 ? second.location - 1 : 0;
            NSDictionary *attr = [self.textStorage attributesAtIndex:pos effectiveRange:NULL];
            secondStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
        } else {

            secondStr = [self.textStorage attributedSubstringFromRange:second];
        }
        NSAttributedString *firstStr;
        if (first.length == 0) {
            NSUInteger pos = first.location > 0 ? first.location - 1 : 0;
            NSDictionary *attr = [self.textStorage attributesAtIndex:pos effectiveRange:NULL];
            firstStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
        } else {

            firstStr = [self.textStorage attributedSubstringFromRange:first];
        }
        if (first.length == 0) {
            [self deleteTextInRange:[NSValue valueWithRange:second] withActionName:@""];
        } else {
            [self insertText:firstStr replacementRange:second];
        }
        if (second.length == 0) {
            [self deleteTextInRange:[NSValue valueWithRange:first] withActionName:@""];
        } else {
            [self insertText:secondStr replacementRange:first];
        }

    }


    - (void)commentSelection:(id)sender
    {
        [self.codeNavigationAssistant commentSelectionInRange:self.selectedRange];
    }

    - (void)uncommentSelection:(id)sender
    {
        [self.codeNavigationAssistant uncommentSelectionInRange:self.selectedRange];
    }

    - (void)toggleComment:(id)sender
    {
        [self.codeNavigationAssistant toggleCommentInRange:self.selectedRange];
    }

    - (void)jumpNextAnchor:(id)sender
    {
        NSUInteger current = [self currentRow];
        NSArray *anchors = self.lineNumberView.anchoredLines;
        anchors = [anchors sortedArrayUsingSelector:@selector(compare:)];
        NSUInteger nextLine = NSNotFound;
        for (NSNumber *line in anchors) {
            if (nextLine == NSNotFound) {
                nextLine = line.unsignedIntegerValue
                        ;
            }
            if (line.integerValue > current) {
                nextLine = line.unsignedIntegerValue;
                break;
            }
        }
        [self showLine:nextLine];
    }

    - (void)jumpPreviousAnchor:(id)sender
    {
        NSUInteger current = [self currentRow];
        NSArray *anchors = self.lineNumberView.anchoredLines;
        anchors = [anchors sortedArrayUsingSelector:@selector(compare:)];
        NSUInteger nextLine = NSNotFound;
        for (NSNumber *line in [anchors reverseObjectEnumerator]) {
            if (nextLine == NSNotFound) {
                nextLine = line.unsignedIntegerValue;
            }
            if (line.integerValue < current) {
                nextLine = line.unsignedIntegerValue;
                break;
            }
        }
        [self showLine:nextLine];
    }

#pragma mark -
#pragma mark Drag & Drop

    - (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
    {

        NSPasteboard *pb = [sender draggingPasteboard];
        NSDragOperation dragOperation = [sender draggingSourceOperationMask];

        if ([[pb types] containsObject:NSFilenamesPboardType]) {
            if (dragOperation & NSDragOperationCopy) {
                return NSDragOperationCopy;
            }
        }
        if ([[pb types] containsObject:NSPasteboardTypeString]) {
            if (dragOperation & NSDragOperationCopy) {
                return NSDragOperationCopy;
            }
        }

        return NSDragOperationNone;

    }

    - (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
    {

        NSPasteboard *pb = [sender draggingPasteboard];

        if ([[pb types] containsObject:NSFilenamesPboardType]) {

            NSPoint draggingLocation = [sender draggingLocation];
            draggingLocation = [self convertPoint:draggingLocation fromView:nil];
            NSUInteger characterIndex = [self characterIndexOfPoint:draggingLocation];
            [self setSelectedRange:NSMakeRange(characterIndex, 0)];

            droppedFileNames = [pb propertyListForType:NSFilenamesPboardType];

            DocumentModel *model = self.firstResponderDelegate.model;

            if (model.mainDocuments.count > 1) {
                NSMutableSet *dirs = [[NSMutableSet alloc] init];
                for (DocumentModel *temp in model.mainDocuments) {
                    [dirs addObject:[[temp.path stringByDeletingLastPathComponent] relativePathWithBase:[temp.project.path stringByDeletingLastPathComponent]]];
                }
                if (dirs.count > 1) {
                    // Insert absolute path
                    [self insertDropCompletionForModel:nil];
                }
                else {
                    [self insertDropCompletionForModel:[model.mainDocuments firstObject]];
                }
            } else if (model.mainDocuments.count == 1) {
                [self insertDropCompletionForModel:[model.mainDocuments firstObject]];
            }

        }

        else {
            return [super performDragOperation:sender];
        }

        return YES;

    }



#pragma mark -
#pragma mark Drawing Actions

    - (void)drawViewBackgroundInRect:(NSRect)rect
    {
        [super drawViewBackgroundInRect:rect];
        if (self.servicesOn) {
            [self.codeNavigationAssistant highlightCurrentLine];
        }

    }

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]] || [keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]]) {
            NSColor *textColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]];
            NSColor *backgroundColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]];
            NSDictionary *selectionAttributes = @{NSForegroundColorAttributeName : textColor, NSBackgroundColorAttributeName : backgroundColor};
            [self setSelectedTextAttributes:selectionAttributes];
        } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_LINE_WRAP_MODE]]) {
            self.lineWrapMode = (TMTLineWrappingMode) [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_LINE_WRAP_MODE] intValue];
        } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_HARD_WRAP_AFTER]]) {
            self.hardWrapAfter = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_HARD_WRAP_AFTER];
        } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_REPLACE_INVISIBLE_SPACES]]) {
            [self setNeedsDisplay:YES];
        } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_REPLACE_INVISIBLE_LINEBREAKS]]) {
            [self setNeedsDisplay:YES];
        } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTLineSpacing]]) {
            NSMutableParagraphStyle *ps = self.typingAttributes[NSParagraphStyleAttributeName];
            if (!ps) {
                ps = [NSMutableParagraphStyle new];
            }
            CGFloat spacing = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMTLineSpacing] floatValue];
            ps.paragraphSpacing = spacing;
            [self.textStorage addAttribute:NSParagraphStyleAttributeName value:ps range:NSMakeRange(0, self.string.length)];
            NSMutableDictionary *typingAttributes = [self.typingAttributes mutableCopy];
            typingAttributes[NSParagraphStyleAttributeName] = ps;
            self.typingAttributes = typingAttributes;
        }
    }

    - (BOOL)resignFirstResponder
    {
        BOOL result = [super resignFirstResponder];
        if (result && autoCompletionController) {
            if (self.selectedRange.length > 0) {
                [self delete:self];
            }
            [self dismissCompletionWindow];
        }
        return result;
    }


    - (void)dealloc
    {
        [self unregisterUserDefaultsObserver];

    }

# pragma mark - First Responder Chain

    - (id)performSelector:(SEL)aSelector withObject:(id)object
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([super respondsToSelector:aSelector]) {
            [super performSelector:aSelector withObject:object];
        } else if (self.firstResponderDelegate && [self.firstResponderDelegate respondsToSelector:aSelector]) {
            [self.firstResponderDelegate performSelector:aSelector withObject:object];
        }
#pragma clang diagnostic pop
        return nil;
    }

    - (BOOL)becomeFirstResponder
    {
        [self makeKeyView];
        return [super becomeFirstResponder];
    }

    - (void)makeKeyView
    {
        if (self.firstResponderDelegate) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTFirstResponderDelegateChangeNotification object:self.firstResponderDelegate.model.mainCompilable userInfo:@{TMTFirstResponderKey : self.firstResponderDelegate, TMTNotificationSourceWindowKey: self.window}];
        }
    }


@end
