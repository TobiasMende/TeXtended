//
//  NSFileManager+DirectoryExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DirectoryExtension)
- (BOOL) directoryExistsAtPath:(NSString *)path;
@end
