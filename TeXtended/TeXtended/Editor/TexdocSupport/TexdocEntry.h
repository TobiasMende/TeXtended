//
//  TexdocEntry.h
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TexdocEntry : NSObject
@property (strong) NSString *description;
@property (strong) NSNumber *score;
@property (strong) NSString *path;


- (id) initWithArray:(NSArray *) texdoc;
- (NSString *)fileName;
- (NSImage*) fileIcon;
@end
