//
//  LocationManager.m
//  NavCog3
//
//  Created by yoshizawr204 on 2023/01/24.
//  Copyright © 2023 HULOP. All rights reserved.
//

#import "LocationManager.h"
#import <Foundation/Foundation.h>
#import <HLPLocationManager/HLPLocationManager+Player.h>
#import "LocationEvent.h"
#import "NavDataStore.h"

@import HLPDialog;

@implementation LocationManager

static LocationManager *instance;

static NSTimeInterval lastActiveTime;
static long locationChangedTime;
static int temporaryFloor;
static int currentFloor;
static int continueFloorCount;


+ (instancetype)sharedManager
{
    if (!instance) {
        instance = [[LocationManager alloc] init];
    }
    return instance;
}

- (id)init
{
   self = [super init];
   if (self) {
       //Initialization
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableAcceleration:) name:DISABLE_ACCELEARATION object:nil];

       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableAcceleration:) name:ENABLE_ACCELEARATION object:nil];

       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableStabilizeLocalize:) name:DISABLE_STABILIZE_LOCALIZE object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableStabilizeLocalize:) name:ENABLE_STABILIZE_LOCALIZE object:nil];
       
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationRestart:) name:REQUEST_LOCATION_RESTART object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationStop:) name:REQUEST_LOCATION_STOP object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationStart:) name:REQUEST_LOCATION_START object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationHeadingReset:) name:REQUEST_LOCATION_HEADING_RESET object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationReset:) name:REQUEST_LOCATION_RESET object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationUnknown:) name:REQUEST_LOCATION_UNKNOWN object:nil];
       
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestBackgroundLocation:) name:REQUEST_BACKGROUND_LOCATION object:nil];

       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLogReplay:) name:REQUEST_LOG_REPLAY object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLogReplayStop:) name:REQUEST_LOG_REPLAY_STOP object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLocationInit:) name:REQUEST_LOCATION_INIT object:nil];

       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverConfigChanged:) name:SERVER_CONFIG_CHANGED_NOTIFICATION object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:NAV_LOCATION_CHANGED_NOTIFICATION object:nil];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildingChanged:) name:BUILDING_CHANGED_NOTIFICATION object:nil];

       lastActiveTime = [[NSDate date] timeIntervalSince1970];
   }
   return self;
}



- (void)setup {
    HLPLocationManager *manager = [HLPLocationManager sharedManager];
    manager.delegate = self;
}

- (void)serverConfigChanged:(NSNotification*)note
{
    NSMutableDictionary *config = [note.userInfo mutableCopy];
    config[@"conv_client_id"] = [NavDataStore sharedDataStore].userID;
    [DialogManager sharedManager].config = config;
}

- (void)locationChanged:(NSNotification*)note
{
    HLPLocation *loc = [NavDataStore sharedDataStore].currentLocation;
    [[DialogManager sharedManager] changeLocationWithLat:loc.lat lng:loc.lng floor:loc.floor];
}

- (void)buildingChanged:(NSNotification*)note
{
    [[DialogManager sharedManager] changeBuilding:note.userInfo[@"building"]];
}

#pragma mark - NotificationCenter Observers

- (void)disableAcceleration:(NSNotification*)note
{
    [HLPLocationManager sharedManager].isAccelerationEnabled = NO;
}

- (void)enableAcceleration:(NSNotification*)note
{
    [HLPLocationManager sharedManager].isAccelerationEnabled = YES;
}

- (void)disableStabilizeLocalize:(NSNotification*)note
{
    [HLPLocationManager sharedManager].isStabilizeLocalizeEnabled = NO;
}

- (void)enableStabilizeLocalize:(NSNotification*)note
{
    [HLPLocationManager sharedManager].isStabilizeLocalizeEnabled = YES;
}

- (void) requestLocationRestart:(NSNotification*) note
{
    [[HLPLocationManager sharedManager] restart];
}

- (void) requestLocationStop:(NSNotification*) note
{
    [[HLPLocationManager sharedManager] stop];
}

- (void) requestLocationStart:(NSNotification*) note
{
    [[HLPLocationManager sharedManager] start];
}

- (void) requestLocationUnknown:(NSNotification*) note
{
    [[HLPLocationManager sharedManager] makeStatusUnknown];
}

- (void) requestLocationReset:(NSNotification*) note
{
    NSDictionary *properties = [note userInfo];
    HLPLocation *loc = properties[@"location"];
    double std_dev = [[NSUserDefaults standardUserDefaults] doubleForKey:@"reset_std_dev"];
    [loc updateOrientation:NAN withAccuracy:std_dev];
    [[HLPLocationManager sharedManager] resetLocation:loc];
}

- (void) requestLocationHeadingReset:(NSNotification*) note
{
    NSDictionary *properties = [note userInfo];
    HLPLocation *loc = properties[@"location"];
    double heading = [properties[@"heading"] doubleValue];
    double std_dev = [[NSUserDefaults standardUserDefaults] doubleForKey:@"reset_std_dev"];
    [loc updateOrientation:heading withAccuracy:std_dev];
    [[HLPLocationManager sharedManager] resetLocation:loc];
}

- (void) requestLocationInit:(NSNotification*) note
{
    HLPLocationManager *manager = [HLPLocationManager sharedManager];
    manager.delegate = self;
}

- (void) requestBackgroundLocation:(NSNotification*) note
{
    BOOL backgroundMode = (note && [[note userInfo][@"value"] boolValue]) ||
    [[NSUserDefaults standardUserDefaults] boolForKey:@"background_mode"];
    [HLPLocationManager sharedManager].isBackground = backgroundMode;
}

- (void) requestLogReplay:(NSNotification*) note
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *option =
    @{
      @"replay_in_realtime": [ud valueForKey:@"replay_in_realtime"],
      @"replay_sensor": [ud valueForKey:@"replay_sensor"],
      @"replay_show_sensor_log": [ud valueForKey:@"replay_show_sensor_log"],
      @"replay_with_reset": [ud valueForKey:@"replay_with_reset"],
      };
    BOOL bNavigation = [[NSUserDefaults standardUserDefaults] boolForKey:@"replay_navigation"];
    [[HLPLocationManager sharedManager] startLogReplay:note.userInfo[@"path"] withOption:option withLogHandler:^(NSString *line) {
        if (bNavigation) {
            NSArray *v = [line componentsSeparatedByString:@" "];
            if (v.count > 3 && [v[3] hasPrefix:@"initTarget"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_PROCESS_INIT_TARGET_LOG object:self userInfo:@{@"text":line}];
                });
            }
            if (v.count > 3 && [v[3] hasPrefix:@"showRoute"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_PROCESS_SHOW_ROUTE_LOG object:self userInfo:@{@"text":line}];
                });
            }
        }
    }];
}

- (void)requestLogReplayStop:(NSNotification*) note {
    [[HLPLocationManager sharedManager] stopLogReplay];
}




#pragma mark - HLPLocationManagerDelegate

- (void)locationManager:(HLPLocationManager *)manager didLocationUpdate:(HLPLocation *)location
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DebugMode"]) {
        NSDateFormatter* dateFormatte = [[NSDateFormatter alloc] init];
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        [dateFormatte setCalendar: calendar];
        [dateFormatte setLocale:[NSLocale systemLocale]];
        [dateFormatte setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString* dateString = [dateFormatte stringFromDate:[NSDate date]];
        [self writeData: [NSString stringWithFormat: @"%@,%@,%@,%@,%@,%@,%@,%@\n", dateString, @(location.lng), @(location.lat), @(location.accuracy), @(location.floor), @(location.speed), @(location.orientation), @(location.orientationAccuracy)]];
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud boolForKey:@"CoordinateSurvey"]) {
    } else if (isnan(location.lat) || isnan(location.lng)) {
        // handle location information nan here
        return;
    }

    long now = (long)([[NSDate date] timeIntervalSince1970]*1000);

    NSMutableDictionary *data =
    [@{
       @"floor":@(location.floor),
       @"lat": @(location.lat),
       @"lng": @(location.lng),
       @"speed":@(location.speed),
       @"orientation":@(location.orientation),
       @"accuracy":@(location.accuracy),
       @"orientationAccuracy":@(location.orientationAccuracy),
       } mutableCopy];

    if ([ud boolForKey:@"CoordinateSurvey"]) {
        double floor = [ud doubleForKey:@"input_floor"];
        double latitude = [ud doubleForKey:@"input_latitude"];
        double longitude = [ud doubleForKey:@"input_longitude"];
        [data setObject:@(floor) forKey:@"floor"];
        [data setObject:@(latitude) forKey:@"lat"];
        [data setObject:@(longitude) forKey:@"lng"];
    }
    
    // Floor change continuity check
    if (temporaryFloor == location.floor) {
        continueFloorCount++;
    } else {
        continueFloorCount = 0;
    }
    temporaryFloor = location.floor;

    if ((continueFloorCount > 8) &&
        (locationChangedTime + 200 > now)) {
        currentFloor = temporaryFloor;
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_CHANGED_NOTIFICATION object:self userInfo:data];
    }
    locationChangedTime = now;
}

- (void)locationManager:(HLPLocationManager *)manager didLocationStatusUpdate:(HLPLocationStatus)status
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NAV_LOCATION_STATUS_CHANGE
                                                        object:self
                                                      userInfo:@{@"status":@(status)}];
}

- (void)locationManager:(HLPLocationManager *)manager didUpdateOrientation:(double)orientation withAccuracy:(double)accuracy
{
    NSDictionary *dic = @{
                          @"orientation": @(orientation),
                          @"orientationAccuracy": @(accuracy)
                          };

    [[NSNotificationCenter defaultCenter] postNotificationName:ORIENTATION_CHANGED_NOTIFICATION object:self userInfo:dic];
}

- (void)locationManager:(HLPLocationManager*)manager didLogText:(NSString *)text
{
    
}

#pragma mark - debug log

NSString *locationFilePath;
NSFileHandle *locationFileHandle;

- (BOOL)writeData:(NSString *)writeLine
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud boolForKey:@"DebugMode"]) {
        return NO;
    }

    if (!locationFilePath) {
        [self setFilePath];
        if (!locationFilePath) {
            return NO;
        }
    }

    NSData *data = [writeLine dataUsingEncoding: NSUTF8StringEncoding];
    [locationFileHandle writeData:data];

    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"DebugMode"]) {
        if (![change[@"new"] boolValue]) {
            locationFilePath = nil;
        } else {
            [self setFilePath];
        }
    } else {
        [[HLPLocationManager sharedManager] invalidate];
    }
}

- (void)setFilePath
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    [df setDateFormat:@"yyyyMMdd-HHmmss"];
    NSDate *now = [NSDate date];
    NSString *strNow = [df stringFromDate:now];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    locationFilePath = [directory stringByAppendingPathComponent: [NSString stringWithFormat: @"move-%@.csv", strNow]];

    BOOL isNew = false;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath: locationFilePath];
    if (!result) {
        result = [self createFile: locationFilePath];
        if (!result) {
            return;
        }
        isNew = true;
    }
    locationFileHandle = [NSFileHandle fileHandleForWritingAtPath: locationFilePath];
    
    if (isNew) {
        [self writeData: @"date,lng,lat,accuracy,floor,speed,orientation,orientationAccuracy\n"];
    }
}

- (BOOL)createFile:(NSString *)filePath
{
  return [[NSFileManager defaultManager] createFileAtPath:filePath contents:[NSData data] attributes:nil];
}

@end
