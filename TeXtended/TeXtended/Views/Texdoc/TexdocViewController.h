//
//  TexdocViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTTableView;
/**
 The TexdocViewController controlls the view which is displayed when showing a list of package documentation.
 
 **Author:** Tobias Mende
 
 */
@interface TexdocViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>{
    /** An array of TexdocEntry objects */
    IBOutlet NSMutableArray *entries;
  
    
    /** The view which should be displayed if no matching entries where found */
    __unsafe_unretained IBOutlet NSView *notFoundView;
}
  /** The table view to display the entries in */
@property (weak)IBOutlet TMTTableView *listView;;
@property (weak) IBOutlet NSTextField *label;
/** The package name (returning the heading for the listView */
@property (weak, nonatomic) NSString *package;
/** Method for setting the entries 
 @param texdoc an array of TexdocEntry objects
 */
- (void) setContent:(NSMutableArray*) texdoc;

- (IBAction)click:(id)sender;
- (void)setDarkBackgroundMode;
- (void) openSelectedDoc;
@end
