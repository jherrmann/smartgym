//
//  SGViewController.h
//  smartgym
//
//  Created by Jan Erik Herrmann on 05.07.14.
//  Copyright (c) 2014 JHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface SGViewController : UIViewController

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) IBOutlet UILabel *reps1Counter;
@property (strong, nonatomic) IBOutlet UILabel *reps2Counter;
@property (strong, nonatomic) IBOutlet UILabel *reps3Counter;

@end
