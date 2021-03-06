//
//  LoadingViewController.m
//  PetGroup
//
//  Created by Tolecen on 13-8-20.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "LoadingViewController.h"
#import "CustomTabBar.h"
#import "MessageViewController.h"
#import "DynamicViewController.h"
#import "NearByViewController.h"
#import "ContactsViewController.h"
#import "PersonalCenterViewController.h"
#import "JSON.h"
@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * openImgStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"OpenImg"];
    if (openImgStr) {
        
        NSData * nsData= [NSData dataWithContentsOfFile:openImgStr];
        UIImage * openPic= [UIImage imageWithData:nsData];
        if (iPhone5) {
            splashImageView=[[UIImageView alloc]initWithImage:openPic];
            splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
        else
        {
            splashImageView=[[UIImageView alloc]initWithImage:openPic];
            splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
    }
    else
    {
        if (iPhone5) {
            splashImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"568screen.png"]];
            splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
        else
        {
            splashImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
            splashImageView.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
    }
    [self.view addSubview:splashImageView];
    
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"TestFirst"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [self firtOpen];
    }

    [self performSelector:@selector(toMainView) withObject:nil afterDelay:2];

	// Do any additional setup after loading the view.
}
-(void)firtOpen
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * userInfoDict = [NSMutableDictionary dictionary];
    if (![SFHFKeychainUtils getPasswordForUsername:MACADDRESS andServiceName:LOCALACCOUNT error:nil]) {
        DeviceIdentifier * dv = [[DeviceIdentifier alloc] init];
        NSString * macAddress = [dv macaddress];
        [SFHFKeychainUtils storeUsername:MACADDRESS andPassword:macAddress forServiceName:LOCALACCOUNT updateExisting:YES error:nil];
    }
    [postDict setObject:userInfoDict forKey:@"params"];
    [postDict setObject:@"1" forKey:@"channel"];
    [postDict setObject:@"open" forKey:@"method"];
    [postDict setObject:@"" forKey:@"token"];
    [postDict setObject:@"2345" forKey:@"mac"];
    [postDict setObject:@"iphone" forKey:@"imei"];
    NSTimeInterval cT = [[NSDate date] timeIntervalSince1970];
    long long a = (long long)(cT*1000);
    [postDict setObject:[NSString stringWithFormat:@"%lld",a] forKey:@"createTime"];
    [NetManager requestWithURLStr:BaseCoreUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self makeNotFirstOpen];
        NSString *receiveStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary * recDict = [receiveStr JSONValue];
        //存储返回的DeviceID，注册使用...
        [[NSUserDefaults standardUserDefaults] setObject:[recDict objectForKey:@"id"] forKey:@"DeviceID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];

}

-(void)makeNotFirstOpen
{
//    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"TestFirst"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {  
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
-(void)toMainView
{
    DynamicViewController * dynamicV = [[DynamicViewController alloc] init];
    self.NaviDynamic = [[MLNavigationController alloc] initWithRootViewController:dynamicV];
    NearByViewController * nearbyV = [[NearByViewController alloc] init];
    self.NaviNearBy = [[MLNavigationController alloc] initWithRootViewController:nearbyV];
    ContactsViewController * contactsV = [[ContactsViewController alloc] init];
    self.NaviContacts = [[MLNavigationController alloc] initWithRootViewController:contactsV];
    //    MoreViewController * moreV = [[MoreViewController alloc] init];
    PersonalCenterViewController* mpVC = [[PersonalCenterViewController alloc]init];
    self.NaviMore = [[MLNavigationController alloc] initWithRootViewController:mpVC];
    
    //为什么message放最后，因为message页面需要滑动删除cell，与MLNavigationController的手势冲突，放在最后一个当修改的时候才能修改到最后一个的页面，如果其他页面也需要这功能，暂时没想到好办法，在写一个类似于MLNavigationController的类吧...
    messageV = [[MessageViewController alloc] init];
    self.NaviMessage = [[MLNavigationController alloc] initWithRootViewController:messageV];
    
    self.NaviMessage.delegate = (id)self;
    self.NaviMessage.navigationBarHidden = YES;
    self.NaviNearBy.navigationBarHidden = YES;
    self.NaviContacts.navigationBarHidden = YES;
    self.NaviMore.navigationBarHidden = YES;
    self.NaviDynamic.navigationBarHidden = YES;
    
    NSArray * views = [NSArray arrayWithObjects:self.NaviMessage,self.NaviDynamic,self.NaviNearBy,self.NaviContacts,self.NaviMore, nil];
    NSArray * normalPic = [NSArray arrayWithObjects:@"normal_02.png",@"normal_03.png",@"normal_04.png",@"normal_05.png",@"normal_06", nil];
    NSArray * selectPic = [NSArray arrayWithObjects:@"select_02.png", @"select_03.png",@"select_04.png",@"select_05.png",@"select_06",nil];
    self.tabBarC = [[CustomTabBar alloc] initWithImages:normalPic AndSelected:selectPic AndControllers:views];
    
    [self presentModalViewController:self.tabBarC animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
