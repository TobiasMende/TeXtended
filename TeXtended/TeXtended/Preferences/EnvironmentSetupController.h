//
//  EnvironmentSetupController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 The environment setup controller is a small controller which simply handles the selection of the correct state images for different executables. This controller is used for showing error or check symbols for the executables usally contained in the texbin directory.
 
 **Author:** Tobias Mende
 
 */
@interface EnvironmentSetupController : NSObject

/** The path to the texbin directory */
@property NSString *texbinPath;

/** The state image for the synctex executable */
- (NSImage *)synctexImage;

/** The state image for the lacheck executable */
- (NSImage *)lacheckImage;

/** The state image for the chktex executable */
- (NSImage *)chktexImage;

/** The state image for the texdoc executable */
- (NSImage *)texdocImage;


/**
 Method for getting a state image for the given path
 
 @param the path to check
 
 @return the image. A check mark, if the path points to a valid executable, an error sign otherwise.
 */
- (NSImage *)imageForPath:(NSString*)path;
@end
