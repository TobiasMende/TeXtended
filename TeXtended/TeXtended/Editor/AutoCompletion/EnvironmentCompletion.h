//
//  EnvironmentCompletion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Completion.h"


/**
 Class for environment completions. Just needed for identification of the completion type. May provide custom functionality later.
 
 @author Tobias Mende
 */
@interface EnvironmentCompletion : Completion <NSCoding>
@property (strong) NSString *firstLineExtension;

- (BOOL) hasFirstLineExtension;
- (NSAttributedString*) substitutedFirstLineExtension;

@end
