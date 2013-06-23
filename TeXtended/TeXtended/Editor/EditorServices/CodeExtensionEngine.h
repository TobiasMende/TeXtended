//
//  CodeExtensionEngine.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"
#import "TexdocHandlerProtocol.h"

/**
 The CodeExtensionEngine extends it's view with additional funktionality linke links and meta information for pieces of code. Example: Texdoc Links
 
 **Author:** Tobias Mende
 
 
 @warning *Imporant:* This class is designed to laying out links without the use of attributes of the views textstorage. Therefor it's not necessary to enably rich text. The use of the layout managers temporary attributes for this purpose provides a much better performance and user experience. 
 */
@interface CodeExtensionEngine : EditorService<TexdocHandlerProtocol> {
    /** The popover to use for texdoc links (and other) */
    NSPopover *popover;
    NSDate *lastUpdate;
}
/** The color for texdoc links */
@property (strong,nonatomic) NSColor *texdocColor;
/** If `YES` package links are highlighted as texdoc link */
@property (nonatomic)BOOL shouldLinkTexdoc;
/** If `YES` texdoc links are underlined */
@property (nonatomic)BOOL shouldUnderlineTexdoc;

/**
 Parses the text within a given range and updates all link attributes
 
 @param range The range to update (as small as possible)
 */
- (void)addLinksForRange:(NSRange) range;


/**
 Needs to be called if the user has clicked a link in the view
 
 @param link the link tha was clicked
 @param charIndex the index where the user clicked
 
 @return `YES` if this class was able to handle this kind of link, `NO` otherwise.
 */
- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex;

/**
 Link attributes in the layout managers temporary attributes are not detected as real links by the view itself. Therefore this method must be called whenever the user clicks somewhere in the view to check whether or not a link is set at the current carret position.
 
 @param position the carrets position (the selected range)
 */
- (void) handleLinkAt:(NSUInteger) position;
@end
