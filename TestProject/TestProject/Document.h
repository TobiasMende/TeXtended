//
//  Document.h
//  TestProject
//
//  Created by Tobias Mende on 28.03.13.
//
//

#import <Cocoa/Cocoa.h>
@class PreferencesController;
@interface Document : NSDocument {
    NSString *content;
}

 @property (assign) IBOutlet NSTextView *firstTextView;
@end
