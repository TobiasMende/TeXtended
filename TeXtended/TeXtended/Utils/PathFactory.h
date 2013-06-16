//
//  PathFactory.h
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathFactory : NSObject
+ (NSString*) texdoc;
+ (NSString*) synctex;
+ (NSString*) texbin;
@end
