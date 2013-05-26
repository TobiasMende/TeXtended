//
//  CompilerProtocol.h
//  TeXtended
//
//  Created by Max Bannach on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Defines methods for classes that can be compiled.
 *
 * @author Max Bannach
 */
@protocol CompilerProtocol <NSObject>

/**
 * Calls the compile method on the document.
 * @param draft is true, if the draft compile should be used and false for a final compile.
 */
//- (void) compile:(bool draft);

/**
 * Controlls if this compile does auto compile or not.
 * @param on is set to true, if auto compile should be used.
 */
//- (void) setAutoCompile:(bool on);

@end
