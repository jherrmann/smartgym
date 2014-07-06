//
//  SGExercise.m
//  smartgym
//
//  Created by Jan Erik Herrmann on 05.07.14.
//  Copyright (c) 2014 JHE. All rights reserved.
//

#import "SGExercise.h"

@implementation SGExercise

- (instancetype) init
{
    self = [super init];
    self.sets = [[NSMutableArray alloc]init];
    
    return self;
    
}

- (void)setReps:(int *)reps forSet:(int *)set
{
    NSNumber* intWrapper = [NSNumber numberWithInt:*set];
    [_sets replaceObjectAtIndex:(NSUInteger)reps withObject:intWrapper];
}

@end
