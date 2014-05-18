//
//  NSString+PathExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PathExtension)

    - (NSString *)relativePathWithBase:(NSString *)basePath;

    - (NSString *)absolutePathWithBase:(NSString *)basePath;
@end
