//
//  NSTextView+LatexExtensions.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (LatexExtensions)
/**
 Method for detecting whether the insertion is final or not depending on the text movement type
 
 @param movement the text movement
 
 @return `YES` if the insertion is final, `NO` otherwise.
 
 */
- (BOOL)isFinalInsertion:(NSInteger)movement;


#pragma mark - Comment & Uncomment


/**
 This method toggles the comment in each selected line.
 
 If a line has a comment sign at the beginning, it is removed otherwise a new comment sign is added.
 
 @param range the range to toggle comments for
 */
- (IBAction)toggleCommentInRange:(NSRange)range;

/**
 This method toggles the comment in each selected line.
 
 If a line has a comment sign at the beginning, it is removed otherwise a new comment sign is added.
 
 @warning This method is only used as undo target. Use the method [CodeNavigationAssistant toggleCommentInRange:] instead.
 
 @param range the string to toggle comments in
 */
- (IBAction)toggleCommentInRangeString:(NSString *)range;

/**
 This method adds a comment sign at the beginning of each line within the provided range
 
 @param range the range to comment lines in.
 */
- (IBAction)commentSelectionInRange:(NSRange)range;

/**
 This method adds a comment sign at the beginning of each line within the provided range.
 
 @warning This method is only used as undo target. Use the method [CodeNavigationAssistant commentSelectionInRange:] instead.
 
 @param range the range to comment lines in.
 */
- (IBAction)commentSelectionInRangeString:(NSString *)range;

/**
 This method removes a comment sign at the beginning of each line within the provided range
 
 @param range the range to uncomment lines in.
 */
- (IBAction)uncommentSelectionInRange:(NSRange)range;

/**
 This method removes a comment sign at the beginning of each line within the provided range
 
 @warning This method is only used as undo target. Use the method [CodeNavigationAssistant uncommentSelectionInRange:] instead.
 
 @param range the range to uncomment lines in.
 */
- (IBAction)uncommentSelectionInRangeString:(NSString *)range;



@end
