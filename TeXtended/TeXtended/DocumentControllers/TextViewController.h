//
//  TextViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextViewObserver.h"
#import "Constants.h"
#import "ViewControllerProtocol.h"
@class HighlightingTextView, LineNumberView, DocumentModel, MessageCollection, DocumentController;

/**
 This view controller handles the HighlightingTextView and other important objects connected to it.
 
 It acts according to the DocumentControllerProtocol and is part of the DocumentController controller tree.
 
 **Author:** Tobias Mende
 
 */
@interface TextViewController : NSViewController<NSTextViewDelegate, ViewControllerProtocol> {
    /** The line number view of the HighlightingTextView */
    LineNumberView *lineNumberView;
    
    /** A set of observers which are informed by instances of this class about NSTextViewDelegate method calls */
    NSMutableSet *observers;
    NSOperationQueue *backgroundQueue;
    NSTimer *messageUpdateTimer;
    NSLock *messageLock;
    MessageCollection *internalMessages;
    MessageCollection *consoleMessages;
    NSInteger countRunningParsers;
}

@property (strong) NSTabViewItem* tabViewItem;

@property(nonatomic) TMTLatexLogLevel logLevel;
/** The view showing the latex source code to the user */
@property (strong) IBOutlet HighlightingTextView *textView;

/** The scroll view containing the LineNumberView and the HighlightingTextView */
@property (strong) IBOutlet NSScrollView *scrollView;

/** The DocumentModel which's content is displayed by the view of this controller */
@property (strong) DocumentModel *model;


@property (assign) DocumentController *documentController;

/** Flag for setting whether live scrolling is enabled or not. */
@property BOOL liveScrolling;

@property MessageCollection *messages;

/**
 Getter for the text views content
 
 return the source code
 */
- (NSString *)content;

/**
 Setter for the content of the TextViewController's view.
 
 @param content the new content
 */
- (void) setContent:(NSString*) content;

/**
 Method for adding a observer whichs needs to be informed if an NSTextViewDelegate method is called. Furthermore these observers are informed by additional methods defined in the TextViewObserver protocol.
 
 @param observer the new observer
 
 */
- (void) addObserver:(id<TextViewObserver>) observer;

/**
 Method for removing a TextViewObserver
 
 @param observer the observer to remove
 */
- (void) removeDelegateObserver:(id<TextViewObserver>) observer;

@end
