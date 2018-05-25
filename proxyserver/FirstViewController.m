//
//  FirstViewController.m
//  proxyserver
//
//  Created by cissu on 2017/11/7.
//  Copyright © 2017年 k. All rights reserved.
//

#import "FirstViewController.h"
#import <ProxyKit/SOCKSProxy.h>
#import <YYKit/YYKit.h>
#import "Utils.h"
#import "MDCCollectionViewTextCell.h"
#import "MDCTypography.h"
#if !D_APPSTORE
    #import <CoreLocation/CoreLocation.h>
#endif
#import <SafariServices/SafariServices.h>
#import "MDCAlertController.h"

static NSString *const kReusableIdentifierItem = @"itemCellIdentifier";
static NSString *const kADReusableIdentifierItem = @"kADReusableIdentifierItem";

#define D_DEFAULT_PORT 9050

#define D_APP_NAME @"闪跃"

@interface FirstViewController () <SOCKSProxyDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) SOCKSProxy *proxy;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) BOOL isUpdatingLocation;

#if !D_APPSTORE
@property (nonatomic, strong) CLLocationManager * locationManager;
#endif

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = D_APP_NAME;
    
    _isConnected = NO;
    _isUpdatingLocation = NO;

    
    [self.collectionView registerClass:[MDCCollectionViewTextCell class]
            forCellWithReuseIdentifier:kReusableIdentifierItem];
    
    // Register cell.
    [self.collectionView registerClass:[MDCCollectionViewTextCell class]
            forCellWithReuseIdentifier:kADReusableIdentifierItem];
    
    // Register header.
    [self.collectionView registerClass:[MDCCollectionViewTextCell class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:UICollectionElementKindSectionHeader];
    
    // Customize collection view settings.
    self.styler.cellStyle = MDCCollectionViewCellStyleCard;
    
    self.collectionView.alwaysBounceVertical = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _proxy = [SOCKSProxy new];
    _proxy.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
}

- (void)reload
{
    [self.collectionView reloadData];
}

#define COMMON_HEIGHT 60

- (CGFloat)collectionView:(UICollectionView *)collectionView cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 1:
                    return 120;
                default:
                    return COMMON_HEIGHT;
            }
        case 1:
        default:
            return COMMON_HEIGHT;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;//!
        case 1:
            return 1;//!
        case 2:
            return 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDCCollectionViewTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kADReusableIdentifierItem
                                                                                forIndexPath:indexPath];
    
    @weakify(self);
    
    //! default
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.textLabel.font = [MDCTypography subheadFont];
    cell.accessoryView = nil;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 0:
                {
                    cell.textLabel.text = @"开启代理服务";
                    UISwitch * st = [UISwitch new];
                    [st setOn:_isConnected];
                    st.tintColor = [UIColor orangeColor];
                    st.onTintColor = [UIColor orangeColor];
                    cell.accessoryView = st;
                    [st setBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch * sender) {
                        if(sender.isOn) {
                            NSNumber * isFirst = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"];
                            if (!isFirst) {
                                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isFirst"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weak_self openHelp];
                                });
                            }
                            NSError * error = nil;
                            [weak_self.proxy startProxyOnPort:D_DEFAULT_PORT error:&error];
                            _isConnected = YES;
                            if (error) {
                                [sender setOn:NO];
                                _isConnected = NO;
                            }
                            [weak_self reload];
                        }
                        else {
                            _isConnected = NO;
                            [weak_self.proxy disconnect];
                            [weak_self reload];
                        }
                    }];
                }
                    break;
                case 1:
                {
                    NSString * ip = [Utils ipV4AddressWIFI];
                    NSString * content;
                    if (ip.length == 0) content = @"无WiFi连接";
                    else if (!_isConnected) content = @"服务未开启";
                    else content = [NSString stringWithFormat:@"%@:%@", ip,@(D_DEFAULT_PORT)];
                    cell.textLabel.text = content;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:30];
                    cell.detailTextLabel.text = @"服务器地址[socks5://]";
                    
                }
                    break;
                default:
                {
                }
                    break;
            }
            break;
        case 1:
        {
#if !D_APPSTORE
            cell.textLabel.text = @"开启网络增强功能";
            
            UISwitch * st = [UISwitch new];
            [st setOn:_isUpdatingLocation];
            cell.accessoryView = st;
            
            [st setBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch * sender) {
                if(sender.isOn) {
                    NSNumber * isFirst = [[NSUserDefaults standardUserDefaults] objectForKey:@"isLocationFirst"];
                    if (!isFirst) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            MDCAlertController * alvc = [MDCAlertController alertControllerWithTitle:@"网络增强功能" message:@"网络增强功能使用iOS定位服务(GPS)来计算当前网络状况并改善 闪跃 的服务稳定性"];
                            
                            MDCAlertAction * sure = [MDCAlertAction actionWithTitle:@"了解并开启" handler:^(MDCAlertAction * _Nonnull action) {
                                [weak_self startLocation];
                                if ([CLLocationManager locationServicesEnabled]) weak_self.isUpdatingLocation = YES;
                                else if ([CLLocationManager authorizationStatus] > kCLAuthorizationStatusDenied) weak_self.isUpdatingLocation = YES;
                                else weak_self.isUpdatingLocation = NO;
                                [weak_self reload];
                                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isLocationFirst"];
                            }];

                            MDCAlertAction * notsure = [MDCAlertAction actionWithTitle:@"不想开启"  handler:^(MDCAlertAction * _Nonnull action) {
                                [sender setOn:NO];
                            }];
                            
                            [alvc addAction:sure];
                            [alvc addAction:notsure];
                            
                            [weak_self presentViewController:alvc animated:YES completion:^{

                            }];
                        });
                    }
                    else
                    {
                        [weak_self startLocation];
                        if ([CLLocationManager locationServicesEnabled]) weak_self.isUpdatingLocation = YES;
                        else if ([CLLocationManager authorizationStatus] > kCLAuthorizationStatusDenied) weak_self.isUpdatingLocation = YES;
                        else weak_self.isUpdatingLocation = NO;
                    }
                }
                else {
                    [weak_self stopLocation];
                    weak_self.isUpdatingLocation = NO;
                }
                [weak_self reload];
            }];
#else
            cell.textLabel.text = @"屏幕常亮";
            UISwitch * st = [UISwitch new];
            [st setOn:_isUpdatingLocation];
            cell.accessoryView = st;
            [st setBlockForControlEvents:UIControlEventValueChanged block:^(UISwitch * sender) {
                if (sender.isOn) {
                    [[UIScreen mainScreen] setBrightness:0.2];
                    [UIApplication sharedApplication].idleTimerDisabled = YES;
                    weak_self.isUpdatingLocation = YES;
                }
                else {
                    [[UIScreen mainScreen] setBrightness:0.5];
                    [UIApplication sharedApplication].idleTimerDisabled = NO;
                    weak_self.isUpdatingLocation = NO;
                }
            }];
#endif
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"关于";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"帮助";
        }
            break;
        default:
        {
        
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.item) {
                case 1:
                    break;
                case 2:
                    break;
                default:
                    break;
            }
        case 1:
            break;
        case 2: //!关于
        {
            [self openAbout];
        }
            break;
        case 3: //!帮助
        {
            [self openHelp];
        }
            break;
        default:
            break;
    }
}

- (void)initLocation
{
#if !D_APPSTORE
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
#endif
}

- (void)startLocation
{
#if !D_APPSTORE
    if (!self.locationManager) [self initLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }

    [self.locationManager startUpdatingLocation];
#endif
}

- (void)stopLocation
{
#if !D_APPSTORE
    [self.locationManager stopUpdatingLocation];
#endif
}

- (void) socksProxy:(SOCKSProxy*)socksProxy clientDidConnect:(SOCKSProxySocket*)clientSocket
{
    _isConnected = YES;
}

- (void) socksProxy:(SOCKSProxy*)socksProxy clientDidDisconnect:(SOCKSProxySocket*)clientSocket
{
    _isConnected = NO;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
}

- (void)openHelp
{
    SFSafariViewController * vc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://clipweb.oss-cn-qingdao.aliyuncs.com/flash/flash.html"]];
    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)openAbout
{
    MDCAlertController * alvc = [MDCAlertController alertControllerWithTitle:@"关于" message:@"闪跃 - 由 快贴 提供技术支持"];
    MDCAlertAction * sure = [MDCAlertAction actionWithTitle:@"关闭" handler:^(MDCAlertAction * _Nonnull action) {
        
    }];

    MDCAlertAction * open = [MDCAlertAction actionWithTitle:@"了解快贴" handler:^(MDCAlertAction * _Nonnull action) {
        NSString * url = [NSString stringWithFormat:@"http://clipber.com"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
    
    [alvc addAction:open];
    [alvc addAction:sure];
    
    [self presentViewController:alvc animated:YES completion:^{
        
    }];
}

@end
