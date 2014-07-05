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
    int reps;
    int sets;
    NSDate *setTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self setupAccelerometerAndGyro];
    // send the data to the server
    [self sendSessionData:9]; // TODO: Replace with data from accelerometer
}

-(void)setupAccelerometerAndGyro
{
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .3;
    self.motionManager.gyroUpdateInterval = .3;
    
    //accelerometerDataArray = [[NSMutableArray alloc] init];
    insideRep = NO;
    reps = 0;
    sets = 0;
    
    // tell montion manager to start sending acceleration updates
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        
        // output data
        [self outputAccelertionData:accelerometerData.acceleration];
        
        // analyse data for rep
        [self countRep:accelerometerData.acceleration];
        
        // analyse data if a new exercise starts and rest reps and sets
        [self checkAndStartNewExercise:accelerometerData.acceleration];
        
        // add accelerometer data to array
        //[accelerometerDataArray addObject:accelerometerData];
        
        //NSLog(@"X: %f Y: %f Z: %f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
        
        if(error){
            NSLog(@"%@", error);
        }
    }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];

}

- (void)countRep:(CMAcceleration)acceleration
{
    // if over treshold then rep starts
    if(!insideRep && acceleration.z >= -0.9)
    {
        insideRep = YES;
        if(setTimer)
        {
            // if 10 seconds have past since last Rep, assume that a new set is starting
            if([setTimer timeIntervalSinceNow]<-10.0)
               {
                   reps = 0;
                   sets++;
                   // update gui
                   self.repsCounter.text = [NSString stringWithFormat:@" %d", reps];
                   self.setsCounter.text = [NSString stringWithFormat:@" %d", sets];
               }
        }

    }
    // if under treshold rep ends
    else if(insideRep && acceleration.z <= -0.98)
    {
        insideRep = NO;
        reps++;
        // start and reset timeinterval to figure out if a new set is startet
        setTimer = [NSDate date];
        // update gui
        self.repsCounter.text = [NSString stringWithFormat:@" %d", reps];

    }
}

- (void)checkAndStartNewExercise:(CMAcceleration)acceleration
{
    if (acceleration.x >= 1) {
        // start new exercise rest all data
        reps = 0;
        sets = 0;
        // update gui
        self.repsCounter.text = [NSString stringWithFormat:@" %d", reps];
        self.setsCounter.text = [NSString stringWithFormat:@" %d", sets];
    }
}

- (void)sendSessionData:(int)numberOfReps
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *params = @ {@"reps":[NSNumber numberWithInteger:numberOfReps]};
    
    [manager POST:@"http://www.gymbot.me/reps.json" parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"JSON: %@", responseObject);
    }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    self.accX.text = [NSString stringWithFormat:@" %.2fg",acceleration.x];
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    self.accY.text = [NSString stringWithFormat:@" %.2fg",acceleration.y];
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    self.accZ.text = [NSString stringWithFormat:@" %.2fg",acceleration.z];
    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = acceleration.z;
    }
    
    self.maxAccX.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelX];
    self.maxAccY.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelY];
    self.maxAccZ.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelZ];

    
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    self.rotX.text = [NSString stringWithFormat:@" %.2fr/s",rotation.x];
    if(fabs(rotation.x) > fabs(currentMaxRotX))
    {
        currentMaxRotX = rotation.x;
    }
    self.rotY.text = [NSString stringWithFormat:@" %.2fr/s",rotation.y];
    if(fabs(rotation.y) > fabs(currentMaxRotY))
    {
        currentMaxRotY = rotation.y;
    }
    self.rotZ.text = [NSString stringWithFormat:@" %.2fr/s",rotation.z];
    if(fabs(rotation.z) > fabs(currentMaxRotZ))
    {
        currentMaxRotZ = rotation.z;
    }
    
    self.maxRotX.text = [NSString stringWithFormat:@" %.2f",currentMaxRotX];
    self.maxRotY.text = [NSString stringWithFormat:@" %.2f",currentMaxRotY];
    self.maxRotZ.text = [NSString stringWithFormat:@" %.2f",currentMaxRotZ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resetMaxValues:(id)sender {
    
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
}
@end
