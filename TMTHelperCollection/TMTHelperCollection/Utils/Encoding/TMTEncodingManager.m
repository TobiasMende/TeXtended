//
//  TMTEncodingManager.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTEncodingManager.h"

@implementation TMTEncodingManager

- (NSArray *)stringEncodings {
    const NSStringEncoding *encodings = [NSString availableStringEncodings];
    NSMutableArray *allEncodings = [[NSMutableArray alloc] init];
    while (*encodings != 0) {
        [allEncodings addObject:@(*encodings)];
        encodings++;
    }
    [allEncodings sortUsingComparator:^NSComparisonResult(id first, id second) {
        NSString *firstName = [NSString localizedNameOfStringEncoding:[first intValue]];
        NSString *secondName = [NSString localizedNameOfStringEncoding:[second intValue]];
        return [firstName compare:secondName];
    }];
    return allEncodings;
}

+ (TMTEncodingManager *) sharedManager {
    static dispatch_once_t pred;
    static TMTEncodingManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[TMTEncodingManager alloc] init];
    });
    return sharedInstance;
}
@end
