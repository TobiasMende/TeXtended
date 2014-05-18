//
//  TMTNamedEncoding.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTNamedEncoding : NSObject

    - (id)initWithEncoding:(NSNumber *)number;

    @property NSNumber *encoding;
@end
