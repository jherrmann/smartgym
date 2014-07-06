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
    NSDate *repTimer; // for measure the time between a rep
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
        
        // analyse data for rep (only call if NO execerise change just happend
        if (!exerciseTimer || [exerciseTimer timeIntervalSinceNow]<-2) {
            [self countRep:accelerometerData.acceleration];
        }
        
        // analyse data if a new exercise starts and rest reps and sets
        [self checkAndStartNewExercise:accelerometerData.acceleration];
        
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (void)countRep:(CMAcceleration)acceleration
{
    // if acceleration is over threshold then rep starts
    if(!insideRep && acceleration.z >= -0.9)
    {
        insideRep = YES;
        // start the rep time, so that we can ignore reps which are smaller then 0.xx seconds
        repTimer = [NSDate date];
        
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
    else if(insideRep && acceleration.z <= -0.98)
    {
        insideRep = NO;
        
        // only count the rep if it took longer then the threshold
       // if ([repTimer timeIntervalSinceNow]>-0.15) {
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
       // }

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
