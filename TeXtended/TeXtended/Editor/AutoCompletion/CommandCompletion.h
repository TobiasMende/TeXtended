//
//  CommandCompletion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Completion.h"

/**
 Class for \command completions. Just needed for identification of the completion type. May provide custom functionality later.
 
 @author Tobias Mende
 */
@interface CommandCompletion : Completion <NSCoding>

@property (strong, nonatomic) NSString *completionType;
@end
