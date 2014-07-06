//
//  SGExercise.h
//  smartgym
//
//  Created by Jan Erik Herrmann on 05.07.14.
//  Copyright (c) 2014 JHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGExercise : NSObject

@property (strong, nonatomic) NSString *exerciseName;
@property (strong, nonatomic) NSMutableArray *sets;

- (void)setReps:(int *)reps forSet:(int *)set;

@end
