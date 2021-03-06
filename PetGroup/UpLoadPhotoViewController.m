//
//  UpLoadPhotoViewController.m
//  NewXMPPTest
//
//  Created by 阿铛 on 13-8-20.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "UpLoadPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface UpLoadPhotoViewController ()
{
    int clicked;
}
@property (nonatomic,strong)UIImageView* hostPhoto;
@property (nonatomic,strong)UIImageView* petPhoto;

@end

@implementation UpLoadPhotoViewController

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
	// Do any additional setup after loading the view.
    UIImageView * bgimgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-44)];
    [bgimgV setImage:[UIImage imageNamed:@"regBG.png"]];
    [self.view addSubview:bgimgV];
    UIImageView *TopBarBGV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topBG.png"]];
    [TopBarBGV setFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:TopBarBGV];
    
    UIButton * nextB = [UIButton buttonWithType:UIButtonTypeCustom];
    nextB.frame = CGRectMake(245, 5, 70, 34);
    [nextB setTitle:@"完成" forState:UIControlStateNormal];
    [nextB setBackgroundImage:[UIImage imageNamed:@"youshangjiao_normal"] forState:UIControlStateNormal];
    [nextB setBackgroundImage:[UIImage imageNamed:@"youshangjiao_click"] forState:UIControlStateHighlighted];
    [nextB addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextB];
    UILabel *  titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 2, 220, 40)];
    titleLabel.backgroundColor=[UIColor clearColor];
    [titleLabel setText:@"上传头像"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:titleLabel];
    
    UILabel * hostLael = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 295, 30)];
    [hostLael setText:@"上传真实头像，拉近真实的距离"];
    [hostLael setBackgroundColor:[UIColor clearColor]];
    [hostLael setFont:[UIFont boldSystemFontOfSize:18]];
    [self.view addSubview:hostLael];
    
    UIView * bg1 = [[UIView alloc] initWithFrame:CGRectMake(10, 100, 300, 130)];
    [bg1 setBackgroundColor:[UIColor whiteColor]];
    [bg1 setAlpha:0.5];
    bg1.layer.cornerRadius = 5;
    [self.view addSubview:bg1];
    
    self.hostPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(20, 110, 110, 110)];
    [_hostPhoto setImage:[UIImage imageNamed:@"zhuren"]];
    [self.view addSubview:_hostPhoto];
    
    UILabel* hostL = [[UILabel alloc]initWithFrame:CGRectMake(7, 85, 96, 17)];
    hostL.text = @"主淫头像";
    hostL.font = [UIFont boldSystemFontOfSize:13];
    hostL.textAlignment = UITextAlignmentCenter;
    hostL.textColor = [UIColor whiteColor];
    hostL.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6];
    [_hostPhoto addSubview:hostL];
    
    UIButton * tpic1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [tpic1 setFrame:CGRectMake(160, 117, 115, 30)];
    [tpic1 setImage:[UIImage imageNamed:@"xiangche-normal"] forState:UIControlStateNormal];
    [tpic1 setImage:[UIImage imageNamed:@"xiangche-click"] forState:UIControlStateHighlighted];
    [tpic1 setTag:1];
    [tpic1 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tpic1];
    
    UIButton * tpic2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [tpic2 setFrame:CGRectMake(160, 182, 115, 30)];
    [tpic2 setImage:[UIImage imageNamed:@"paizhao-normal"] forState:UIControlStateNormal];
    [tpic2 setImage:[UIImage imageNamed:@"paizhao-click"] forState:UIControlStateHighlighted];
    [tpic2 setTag:2];
    [tpic2 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tpic2];
    
    if (self.petType == PetTypeStyleNone) {
        UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame=CGRectMake(0, 0, 80, 44);
        [backButton setBackgroundImage:[UIImage imageNamed:@"back2.png"] forState:UIControlStateNormal];
        //   [backButton setTitle:@" 返回" forState:UIControlStateNormal];
        [backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [self.view addSubview:backButton];
        [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        UILabel * petLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 295, 30)];
        [petLabel setText:@"爱宠得真实头像，方便小伙伴找到它"];
        [petLabel setBackgroundColor:[UIColor clearColor]];
        [petLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [self.view addSubview:petLabel];
        
        UIView * bg2 = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 300, 130)];
        [bg2 setBackgroundColor:[UIColor whiteColor]];
        [bg2 setAlpha:0.5];
        bg2.layer.cornerRadius = 5;
        [self.view addSubview:bg2];
        
        self.petPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(20, 270, 110, 110)];
        [_petPhoto setImage:[UIImage imageNamed:@"chongwu"]];
        [self.view addSubview:_petPhoto];
        
        UILabel* petL = [[UILabel alloc]initWithFrame:CGRectMake(7, 85, 96, 17)];
        petL.text = @"宠物头像";
        petL.font = [UIFont boldSystemFontOfSize:13];
        petL.textAlignment = UITextAlignmentCenter;
        petL.textColor = [UIColor whiteColor];
        petL.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6];
        [_petPhoto addSubview:petL];
        
        UIButton * tpic21 = [UIButton buttonWithType:UIButtonTypeCustom];
        [tpic21 setFrame:CGRectMake(160, 280, 115, 30)];
        [tpic21 setImage:[UIImage imageNamed:@"xiangche-normal"] forState:UIControlStateNormal];
        [tpic21 setImage:[UIImage imageNamed:@"xiangche-click"] forState:UIControlStateHighlighted];
        [tpic21 setTag:21];
        [tpic21 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tpic21];
        
        UIButton * tpic22 = [UIButton buttonWithType:UIButtonTypeCustom];
        [tpic22 setFrame:CGRectMake(160, 340, 115, 30)];
        [tpic22 setImage:[UIImage imageNamed:@"paizhao-normal"] forState:UIControlStateNormal];
        [tpic22 setImage:[UIImage imageNamed:@"paizhao-click"] forState:UIControlStateHighlighted];
        [tpic22 setTag:22];
        [tpic22 addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tpic22];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - button action
-(void)backButton:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)next
{
    
}
-(void)btnClicked:(UIButton *)sender
{
    clicked = sender.tag;
    if (sender.tag==2||sender.tag==22) {
        UIImagePickerController * imagePicker;
        if (imagePicker==nil) {
            imagePicker=[[UIImagePickerController alloc]init];
            imagePicker.delegate=self;
            imagePicker.allowsEditing = YES;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentModalViewController:imagePicker animated:YES];
        }
        else {
            UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [cameraAlert show];
        }
        
    }
    else
    {
        UIImagePickerController * imagePicker;
        if (imagePicker==nil) {
            imagePicker=[[UIImagePickerController alloc]init];
            imagePicker.delegate=self;
            imagePicker.allowsEditing = YES;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentModalViewController:imagePicker animated:YES];
        }
        else {
            UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
            [libraryAlert show];
        }
        
    }
}
#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage*headImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (clicked==1||clicked==2) {
        [_hostPhoto setImage:headImage];
    }
    else
    {
        [_petPhoto setImage:headImage];
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

@end
