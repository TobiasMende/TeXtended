//
//  Completion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Completion : NSObject <NSCoding>
@property (strong) NSString *insertion;
@property (strong) NSString* extension;
@property BOOL hasPlaceholders;


- (id)initWithInsertion:(NSString*) insertion;
- (id)initWithInsertion:(NSString*) insertion containingPlaceholders:(BOOL)flag;
- (id)initWithInsertion:(NSString*) insertion containingPlaceholders:(BOOL)flag andExtension:(NSString*) extension;
- (NSMutableDictionary*) dictionaryRepresentation;
- (id) initWithDictionary:(NSDictionary*) dict;
- (NSAttributedString*) substitutedExtension;
- (BOOL) hasExtension;
- (NSString*)key;
@end
