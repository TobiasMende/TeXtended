//
//  EditorPlaceholder.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditorPlaceholder : NSTextAttachment
- (id) initWithName:(NSString*)name;
+ (NSAttributedString*) placeholderAsAttributedStringWithName:(NSString*) name;
@end
