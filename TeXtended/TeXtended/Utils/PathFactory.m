//
//  PathFactory.m
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PathFactory.h"
#import "Constants.h"

@implementation PathFactory


+ (NSString *)texbin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:TMT_PATH_TO_TEXBIN];
}


+ (NSString *)texdoc {
    return [[self texbin] stringByAppendingPathComponent:@"texdoc"];
}

+ (NSString *)synctex {
    return [[self texbin] stringByAppendingPathComponent:@"synctex"];
}
@end
