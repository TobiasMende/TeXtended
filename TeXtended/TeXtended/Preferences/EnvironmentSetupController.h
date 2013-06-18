//
//  EnvironmentSetupController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnvironmentSetupController : NSObject
@property NSString *texbinPath;
- (NSImage *)synctexImage;
- (NSImage *)lacheckImage;
- (NSImage *)chktexImage;
- (NSImage *)texdocImage;

- (NSImage *)imageForPath:(NSString*)path;
@end
