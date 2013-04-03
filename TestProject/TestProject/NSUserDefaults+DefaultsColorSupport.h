//
//  NSUserDefaults+DefaultsColorSupport.h
//  TestProject
//
//  Created by Tobias Mende on 01.04.13.
//
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (DefaultsColorSupport)
- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;
@end
