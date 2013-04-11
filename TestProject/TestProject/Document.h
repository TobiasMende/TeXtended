//
//  Document.h
//  TestProject
//
//  Created by Tobias Mende on 28.03.13.
//
//

#import <Cocoa/Cocoa.h>
@class PreferencesController;
@interface Document : NSDocument{
    NSString *content;
}

- (IBAction)compile:(id)sender;
 @property (assign) IBOutlet NSTextView *firstTextView;
@property (retain) NSString* content;
@end
