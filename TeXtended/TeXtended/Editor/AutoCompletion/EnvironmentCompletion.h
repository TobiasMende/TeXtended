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
@interface EnvironmentCompletion : Completion

/** The extension which should be inserted directly after the `\begin{...}` tag. */
    @property (strong) NSString *firstLineExtension;

/** 
 Checks whether a firstLineExtension is available or not.
 @return `YES` if the firstLineExtension is not `nil` and not empty
 */
    - (BOOL)hasFirstLineExtension;

/**
 Getter for the firstLineExtension with substitued placeholders.
 
 @return the substituted first line extension
 */
    - (NSAttributedString *)substitutedFirstLineExtension;

    + (EnvironmentCompletion *)dummyCompletion:(NSString *)name;

@end
