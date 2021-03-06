//
//  SGViewController.m
//  smartgym
//
//  Created by Jan Erik Herrmann on 05.07.14.
//  Copyright (c) 2014 JHE. All rights reserved.
//

#import "SGViewController.h"
#import "AFNetworking.h"

@interface SGViewController ()

@end

@implementation SGViewController
{
    // *accelerometerDataArray;
    BOOL insideRep;
    int reps1;
    int reps2;
    int reps3;
    int sets;
    NSDate *setTimer; // to measure the time between a set
    NSDate *exerciseTimer;
    double rollingZ; // for high pass filter
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupAccelerometerAndGyro];
}

-(void)setupAccelerometerAndGyro
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    //accelerometerDataArray = [[NSMutableArray alloc] init];
    insideRep = NO;
    reps1 = 0;
    reps2 = 0;
    reps3 = 0;
    sets = 0;
    
    // tell motion manager to start sending acceleration updates
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        
        // add a high pass filter to prevent quick changes in acceleration from counting reps.
        if(rollingZ)
        {
            rollingZ = (accelerometerData.acceleration.z * 0.3) + (rollingZ * (1.0 - 0.3));
        }
        else
        {
            rollingZ = accelerometerData.acceleration.z;
        }
        NSLog(@"Zacc: %f",rollingZ);
        
        // analyse data for rep (only call if NO execerise change just happend
        if (!exerciseTimer || [exerciseTimer timeIntervalSinceNow]<-2) {
            [self countRep:rollingZ];
        }
        
        // analyse data if a new exercise starts and rest reps and sets
        [self checkAndStartNewExercise:accelerometerData.acceleration];
        
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (void)countRep:(double)zAcceleration
{
    // if acceleration is over threshold then rep starts
    if(!insideRep && zAcceleration >= -0.9)
    {
        insideRep = YES;
        
        if(setTimer)
        {
            // if 10 seconds have passed since last rep, assume that a new set is starting
            if([setTimer timeIntervalSinceNow]<-5.0)
               {
                   // only move to the next set, if reps where done on the previus set
                   if((reps1>0 && reps2==0) || (reps2>0 && reps3==0))
                   sets++;
               }
        }

    }
    // if acceleration is under threshold rep ends
    else if(insideRep && zAcceleration <= -0.98)
    {
        insideRep = NO;
        
        if (sets == 0) reps1++;
        if (sets == 1) reps2++;
        if (sets == 2) reps3++;
        
        // send the latest data to the server
        [self postData];
        
        // start and reset time interval to figure out if a new set is started
        setTimer = [NSDate date];
        
        // update gui
        self.reps1Counter.text = [NSString stringWithFormat:@" %d", reps1];
        self.reps2Counter.text = [NSString stringWithFormat:@" %d", reps2];
        self.reps3Counter.text = [NSString stringWithFormat:@" %d", reps3];


    }
}

- (void)checkAndStartNewExercise:(CMAcceleration)acceleration
{
    if (acceleration.x >= 1)
    {
        // start new exercise reset all data
        reps1 = 0;
        reps2 = 0;
        reps3 = 0;
        sets = 0;
        setTimer = [NSDate date];
        exerciseTimer = [NSDate date];
        
        // send the latest data to the server
        [self postData];
        
        // update gui
        self.reps1Counter.text = [NSString stringWithFormat:@" %d", reps1];
        self.reps2Counter.text = [NSString stringWithFormat:@" %d", reps2];
        self.reps3Counter.text = [NSString stringWithFormat:@" %d", reps3];
    }
}

#define zFilteringFactor 0.3
- (void)highPassFilter:(CMAcceleration)acceleration
{
    if(rollingZ)
    {
        rollingZ = (acceleration.z * zFilteringFactor) + (rollingZ * (1.0 - zFilteringFactor));
    }
    else
    {
        rollingZ = acceleration.z;
    }
}

- (void)postData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    /*
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *params = @ {@"set1":[NSNumber numberWithInteger:reps1], @"set2":[NSNumber numberWithInteger:reps2], @"set3":[NSNumber numberWithInteger:reps3]};
    
    [manager POST:@"http://10.100.85.104" parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"JSON: %@", responseObject);
    }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
    */

    [manager POST:@"http://10.100.85.142"
       parameters:@ {@"set1":[NSNumber numberWithInteger:reps1], @"set2":[NSNumber numberWithInteger:reps2], @"set3":[NSNumber numberWithInteger:reps3]}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Response: %@", responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
