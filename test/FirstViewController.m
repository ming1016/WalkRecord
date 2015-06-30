
#import "AppDelegate.h"
#import "FirstViewController.h"
#import "Config.h"

@interface FirstViewController ()

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) UILabel* lbLocationAndTime;
@property (nonatomic, strong) UILabel* lbAlreadyWalked;
@property (nonatomic, assign) double currentDistance;
@property (nonatomic, assign) double mileStoneDistance;
@property (nonatomic, assign) double howLongWayForNotification;
@property (nonatomic, strong) CLLocation* startLocation;
@property (nonatomic, strong) UILocalNotification* localNotification;

@property (weak, nonatomic) IBOutlet UIButton* btReCount;
@property (weak, nonatomic) IBOutlet UIButton* btBigWayNotification;
@property (weak, nonatomic) IBOutlet UIButton* btNormalWayNotification;
@property (weak, nonatomic) IBOutlet UIButton* btShortWayNotification;

@property (nonatomic, strong) NSMutableDictionary* wayNotificationButtons;

@property (nonatomic, strong) UIFont* fontOfLabel;
@property (nonatomic, strong) UIFont* tinyFontOfLabel;
@property (nonatomic, strong) UIFont* hugeFontOfLabel;

@property (nonatomic, strong) UILabel* coordinateLabel;
@property (nonatomic, strong) UILabel* altitudeLabel;
@property (nonatomic, strong) UILabel* courseLabel;
@property (nonatomic, strong) UILabel* speedLabel;
@property (nonatomic, strong) UILabel* timestampLabel;
@property (nonatomic, strong) UILabel* floorLabel;

@property (nonatomic, strong) UILabel* walkedLabel;
@property (nonatomic, strong) UILabel* notificationLabel;
@property (nonatomic, strong) UILabel* calorieLabel;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _localNotification = [[UILocalNotification alloc]init];
    
    //开始启用后台更新地理位置
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 8.0)
    {
        //设置定位权限 仅ios8有意义
        [self.locationManager requestWhenInUseAuthorization];// 前台定位
        [self.locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    [self.locationManager startUpdatingLocation];
    
    [self buildLabel];
    
    
    //按钮
    self.wayNotificationButtons[@1000] = self.btBigWayNotification;
    self.wayNotificationButtons[@100] = self.btNormalWayNotification;
    self.wayNotificationButtons[@10] = self.btShortWayNotification;
    [self checkSelectedWayButton];
}

- (void)buildLabel {
    //布局显示的位置
    CGFloat labelMarginLeftAndRight = 30;
    CGFloat labelMarginGap = 10;
    
    self.coordinateLabel.top = labelMarginGap + 22;
    self.coordinateLabel.left = labelMarginLeftAndRight;
    self.coordinateLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.coordinateLabel.height = self.coordinateLabel.font.lineHeight;
    
    self.altitudeLabel.top = self.coordinateLabel.bottom + labelMarginGap;
    self.altitudeLabel.left = labelMarginLeftAndRight;
    self.altitudeLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.altitudeLabel.height = self.altitudeLabel.font.lineHeight;
    
    self.courseLabel.top = self.altitudeLabel.bottom + labelMarginGap;
    self.courseLabel.left = labelMarginLeftAndRight;
    self.courseLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.courseLabel.height = self.courseLabel.font.lineHeight;
    
    self.speedLabel.top = self.courseLabel.bottom + labelMarginGap;
    self.speedLabel.left = labelMarginLeftAndRight;
    self.speedLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.speedLabel.height = self.speedLabel.font.lineHeight;
    
    self.timestampLabel.top = self.speedLabel.bottom + labelMarginGap;
    self.timestampLabel.left = labelMarginLeftAndRight;
    self.timestampLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.timestampLabel.height = self.timestampLabel.font.lineHeight;
    
    self.floorLabel.top = self.timestampLabel.bottom + labelMarginGap;
    self.floorLabel.left = labelMarginLeftAndRight;
    self.floorLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.floorLabel.height = self.floorLabel.font.lineHeight;
    
    self.walkedLabel.top = self.floorLabel.bottom + labelMarginGap;
    self.walkedLabel.left = labelMarginLeftAndRight;
    self.walkedLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.walkedLabel.height = self.walkedLabel.font.lineHeight;
    
    self.notificationLabel.top = self.walkedLabel.bottom + labelMarginGap;
    self.notificationLabel.left = labelMarginLeftAndRight;
    self.notificationLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.notificationLabel.height = self.notificationLabel.font.lineHeight;
    
    self.calorieLabel.top = self.notificationLabel.bottom + labelMarginGap;
    self.calorieLabel.left = labelMarginLeftAndRight;
    self.calorieLabel.width = self.view.width - labelMarginLeftAndRight * 2;
    self.calorieLabel.height = self.calorieLabel.font.lineHeight;
    
    
}

- (void)viewWillLayoutSubviews {
    
}

- (void)checkSelectedWayButton {
    NSArray* allKeys = self.wayNotificationButtons.allKeys;
    for (NSNumber* akey in allKeys) {
        UIButton *aButton = self.wayNotificationButtons[akey];
        if (self.howLongWayForNotification == akey.doubleValue) {
            aButton.selected = YES;
        } else {
            aButton.selected = NO;
        }
    }
}

- (IBAction)clickReCountButton:(id)sender {
    [self resetData];
}
- (IBAction)clickBigWayButton:(id)sender {
    _howLongWayForNotification = 1000;
    [self checkSelectedWayButton];
}
- (IBAction)clickNormalWayButton:(id)sender {
    _howLongWayForNotification = 100;
    [self checkSelectedWayButton];
}
- (IBAction)clickShortWayButton:(id)sender {
    _howLongWayForNotification = 10;
    [self checkSelectedWayButton];
}

- (void)resetData {
    _currentDistance = 0;
    _mileStoneDistance = 0;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if (!_startLocation) {
        self.startLocation = [[CLLocation alloc]init];
        self.startLocation = newLocation;
    }

    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        
    }
    else
    {
        
//        NSLog(@"in background");
    }
    _currentDistance += [newLocation distanceFromLocation:_startLocation];
    if (_currentDistance > _mileStoneDistance + self.howLongWayForNotification) {
        _mileStoneDistance = _currentDistance;
        //执行本地通知
        _localNotification.alertBody = [NSString stringWithFormat:@"你已经移动了%f米",_currentDistance];
        UIApplication *app = [UIApplication sharedApplication];
        [app presentLocalNotificationNow:_localNotification];
    }
    
    _startLocation = newLocation;
    [self updateWithLocationChange:newLocation withDistance:_currentDistance];
}

/*!
 * @brief 显示后端的更新
 *
 */
- (void)updateWithLocationChange:(CLLocation *)location withDistance:(CLLocationDistance)meters {
    
    double latitude = location.coordinate.latitude;
    double longitude = location.coordinate.longitude;
    [self.coordinateLabel setText:[NSString stringWithFormat:@"当前坐标为 纬度%.2f 经度%.2f", latitude, longitude]];
    
    double altitude = location.altitude;
    [self.altitudeLabel setText:[NSString stringWithFormat:@"海拔 %.1f", altitude]];
    
    double course = location.course;
    [self.courseLabel setText:[NSString stringWithFormat:@"偏北角度 %.2f", course]];
    
    double speed = location.speed;
    [self.speedLabel setText:[NSString stringWithFormat:@"速度每秒 %.1f米", speed]];
    

    NSString *timestamp = [location.timestamp description];
    [self.timestampLabel setText:[NSString stringWithFormat:@"时间 %@", timestamp]];
    
    NSUInteger floor = location.floor.level;
    [self.floorLabel setText:[NSString stringWithFormat:@"所在楼层 %d", (int)floor]];
    
    [self.walkedLabel setText:[NSString stringWithFormat:@"这次一共走了%.1f米", meters]];
    [self.notificationLabel setText:[NSString stringWithFormat:@"每走%.0f米会发送通知提醒一次", _howLongWayForNotification]];
    [self.calorieLabel setText:[NSString stringWithFormat:@"消耗卡路里%.1f",meters * 0.07625]];
}

#pragma mark - getter && setter
- (NSMutableDictionary *)wayNotificationButtons {
    if (!_wayNotificationButtons) {
        return self.wayNotificationButtons = [NSMutableDictionary dictionary];
    }
    return _wayNotificationButtons;
}
- (double)howLongWayForNotification {
    if (!_howLongWayForNotification) {
        self.howLongWayForNotification = 1000;
    }
    return _howLongWayForNotification;
}
- (double)currentDistance {
    if (!_currentDistance) {
        self.currentDistance = 0;
    }
    return _currentDistance;
}
- (double)mileStoneDistance {
    if (!_mileStoneDistance) {
        self.mileStoneDistance = 0;
    }
    return _mileStoneDistance;
}
- (UILabel *)lbLocationAndTime {
    if (!_lbLocationAndTime) {
        self.lbLocationAndTime = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _lbLocationAndTime;
}
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    return _locationManager;
}
//显示信息
- (UIFont *)fontOfLabel {
    if (!_fontOfLabel) {
        self.fontOfLabel = [UIFont systemFontOfSize:15];
    }
    return _fontOfLabel;
}
- (UIFont *)tinyFontOfLabel {
    if (!_tinyFontOfLabel) {
        self.tinyFontOfLabel = [UIFont systemFontOfSize:12];
    }
    return _tinyFontOfLabel;
}
- (UIFont *)hugeFontOfLabel {
    if (!_hugeFontOfLabel) {
        self.hugeFontOfLabel = [UIFont systemFontOfSize:22];
    }
    return _hugeFontOfLabel;
}
- (UILabel *)coordinateLabel {
    if (!_coordinateLabel) {
        self.coordinateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.coordinateLabel setFont:self.fontOfLabel];
        [self.coordinateLabel setTextColor:[UIColor grayColor]];
        [self.view addSubview:self.coordinateLabel];
    }
    return _coordinateLabel;
}
- (UILabel *)altitudeLabel {
    if (!_altitudeLabel) {
        self.altitudeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.altitudeLabel setFont:self.tinyFontOfLabel];
        [self.altitudeLabel setTextColor:[UIColor greenColor]];
        [self.view addSubview:self.altitudeLabel];
    }
    return _altitudeLabel;
}
- (UILabel *)courseLabel {
    if (!_courseLabel) {
        self.courseLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.courseLabel setFont:self.fontOfLabel];
        [self.courseLabel setTextColor:[UIColor yellowColor]];
        [self.view addSubview:self.courseLabel];
    }
    return _courseLabel;
}
- (UILabel *)speedLabel {
    if (!_speedLabel) {
        self.speedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.speedLabel setFont:self.hugeFontOfLabel];
        [self.speedLabel setTextColor:[UIColor redColor]];
        [self.view addSubview:self.speedLabel];
    }
    return _speedLabel;
}
- (UILabel *)timestampLabel {
    if (!_timestampLabel) {
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.timestampLabel setFont:self.tinyFontOfLabel];
        [self.timestampLabel setTextColor:[UIColor blueColor]];
        [self.view addSubview:self.timestampLabel];
    }
    return _timestampLabel;
}
- (UILabel *)floorLabel {
    if (!_floorLabel) {
        self.floorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.floorLabel setFont:self.tinyFontOfLabel];
        [self.floorLabel setTextColor:[UIColor purpleColor]];
        [self.view addSubview:self.floorLabel];
    }
    return _floorLabel;
}
- (UILabel *)walkedLabel {
    if (!_walkedLabel) {
        self.walkedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.walkedLabel setFont:self.hugeFontOfLabel];
        [self.walkedLabel setTextColor:[UIColor redColor]];
        [self.view addSubview:self.walkedLabel];
    }
    return _walkedLabel;
}
- (UILabel *)notificationLabel {
    if (!_notificationLabel) {
        self.notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.notificationLabel setFont:self.fontOfLabel];
        [self.notificationLabel setTextColor:[UIColor blueColor]];
        [self.view addSubview:self.notificationLabel];
    }
    return _notificationLabel;
}
- (UILabel *)calorieLabel {
    if (!_calorieLabel) {
        self.calorieLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.calorieLabel setFont:self.hugeFontOfLabel];
        [self.calorieLabel setTextColor:[UIColor redColor]];
        [self.view addSubview:self.calorieLabel];
    }
    return _calorieLabel;
}

@end
