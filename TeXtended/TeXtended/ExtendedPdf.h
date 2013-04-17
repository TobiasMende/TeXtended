//
//  ExtendedPdf.h
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface ExtendedPdf : PDFView

@property (assign) int gridVerticalSpacing;
@property (assign) int gridHorizontalSpacing;
@property (assign) bool drawHorizotalLines;
@property (assign) bool drawVerticalLines;

-(void) drawGrid:(NSSize) size;
- (void) initVariables;

@end
