//
//  ForwardSynctex.h
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class provides the functionality of doing a forward synctex synchronisation.
 *
 * It synchronizes the output pdf with the current position in the source code by getting a code position and returning the best matching position in the pdf file.
 *
 * **Author:** Tobias Mende
 *
 */
@interface ForwardSynctex : NSObject
    {
    }

    - (id)initWithOutput:(NSString *)output;

/** The page in the output file */
    @property NSUInteger page;

/** The x output of the synctex task */
    @property CGFloat x;

/** The y output of the synctex task */
    @property CGFloat y;

/** The x coordinate in the output file */
    @property CGFloat h;

/** The y coordinate in the output file */
    @property CGFloat v;

/** The W output of the synctex task */
    @property CGFloat width;

/** The H output of the synctex task */
    @property CGFloat height;
@end


@interface ForwardSynctexController : NSObject
    {
        __unsafe_unretained id weakSelf;

        NSMutableArray *tasks;
    }

/**
 * Initializes the algorithm.
 *
 * @param inPath the path to the latex file
 * @param outPath the path of the pdf file
 * @param row the line in the latex file
 * @param col the column in the latex file
 */
    - (void)startWithInputPath:(NSString *)inPath outputPath:(NSString *)outPath row:(NSUInteger)row andColumn:(NSUInteger)col andHandler:(void (^)(ForwardSynctex *result))completionHandler;


@end