//
//  NearByViewController.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

//特别说明：网络解析结果放在nearByArray里，petArray存放的是XML解析出的宠物列表,选择“显示宠物”得时候将所有宠物信息存入appearPetArray组织显示
#import "NearByViewController.h"
#import "ProfileHeadCell.h"
#import "CustomTabBar.h"
#import "JSON.h"
#import "GDataXMLNode.h"
#import "XMLMatcher.h"
@interface NearByViewController ()

@property (nonatomic,strong)NSMutableArray* appearPetArray;
@property (nonatomic,strong)NSArray * petArray;
@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation NearByViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        personOrPet = YES;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    //[self.leveyTabBarController removeNotificatonOfIndex:1];
    if ([[TempData sharedInstance] ifPanned]) {
        [self.customTabBarController hidesTabBar:NO animated:NO];
    }
    else
    {
        [self.customTabBarController hidesTabBar:NO animated:YES];
        [[TempData sharedInstance] Panned:YES];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *TopBarBGV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"topBG.png"]];
    [TopBarBGV setFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:TopBarBGV];
    
    UIButton *filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame=CGRectMake(275, 5, 45, 32.5);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"shaixuan.png"] forState:UIControlStateNormal];
    //   [backButton setTitle:@" 返回" forState:UIControlStateNormal];
    [self.view addSubview:filterButton];
    [filterButton addTarget:self action:@selector(filterButtonDo:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 2, 220, 40)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=@"附近的人（全部）";
    [titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    self.messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-94) style:UITableViewStylePlain];
    [self.view addSubview:self.messageTable];
    self.messageTable.dataSource = self;
    self.messageTable.delegate = self;
    
    _slimeView = [[SRRefreshView alloc] init];
    _slimeView.delegate = self;
    _slimeView.upInset = 0;
    _slimeView.slimeMissWhenGoingBack = YES;
    _slimeView.slime.bodyColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    _slimeView.slime.skinColor = [UIColor whiteColor];
    _slimeView.slime.lineWith = 1;
    _slimeView.slime.shadowBlur = 4;
    _slimeView.slime.shadowColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    
    [self.messageTable addSubview:_slimeView];
    
    __weak NearByViewController *weakSelf = self;
    [self.messageTable addInfiniteScrollingWithActionHandler:^{
        if (1) {
            
          
        }
        else
        {
            [weakSelf performSelector:@selector(endrefresh) withObject:nil afterDelay:2];
        }
    }];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.delegate = self;
    hud.labelText = @"搜索中...";
    
    [self addFiterPage];
}
-(void)endrefresh
{
    [self.messageTable.infiniteScrollingView stopAnimating];
    

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.petTypeTable) {
        return 30;
    }
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.petTypeTable) {
        static NSString *identifier = @"petCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        if (indexPath.row==0) {
            cell.textLabel.text = @"所有";
        }
        else
            cell.textLabel.text = self.petArray[indexPath.row-1];
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        return cell;
    }else if(personOrPet){
        static NSString *identifier = @"userCell";
        NearByCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[NearByCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        return cell;
    }else{
        static NSString *identifier = @"petCell";

        NearByCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[NearByCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.petTypeTable) {
        [UIView animateWithDuration:0.3 animations:^(void){
            [self.petTypeTable setFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 0)];
        }];
//        [postDict setObject:[NSNumber numberWithInt:[self.typeArray[indexPath.row] intValue]] forKey:@"type"];
        NSNumber* a = 0;
        switch (petType) {
            case 5:{
                
                if (indexPath.row==0) {
                    a = [NSNumber numberWithInt:1];
                    [petCat setTitle:@"所有" forState:UIControlStateNormal];
                }
                else
                {
                    a = [XMLMatcher typeWithString1:@"Cat" andString2:self.petArray[indexPath.row-1]];
                    [petCat setTitle:self.petArray[indexPath.row-1] forState:UIControlStateNormal];
                }
                [petDog setTitle:@"狗" forState:UIControlStateNormal];
                [petOther setTitle:@"其他" forState:UIControlStateNormal];
            }break;
            case 6:{
                
                if (indexPath.row==0) {
                    a=[NSNumber numberWithInt:2];
                    [petDog setTitle:@"所有" forState:UIControlStateNormal];
                }
                else
                {
                    a = [XMLMatcher typeWithString1:@"Dog" andString2:self.petArray[indexPath.row-1]];
                    [petDog setTitle:self.petArray[indexPath.row-1] forState:UIControlStateNormal];
                }
                [petCat setTitle:@"猫" forState:UIControlStateNormal];
                [petOther setTitle:@"其他" forState:UIControlStateNormal];
            }break;
            case 7:{
                
                if (indexPath.row==0) {
                    a = [NSNumber numberWithInt:3];
                    [petOther setTitle:@"所有" forState:UIControlStateNormal];
                }
                else
                {
                    a = [XMLMatcher typeWithString1:@"Other" andString2:self.petArray[indexPath.row-1]];
                    [petOther setTitle:self.petArray[indexPath.row-1] forState:UIControlStateNormal];
                }
                [petDog setTitle:@"狗" forState:UIControlStateNormal];
                [petCat setTitle:@"猫" forState:UIControlStateNormal];
            }break;
            default:
                break;
        }
    
        
    }
    else if(personOrPet)
    {
        PersonDetailViewController * detailV = [[PersonDetailViewController alloc] init];
        [self.navigationController pushViewController:detailV animated:YES];
        [self.customTabBarController hidesTabBar:YES animated:YES];
    }else{
               

    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
//    [_slimeView performSelector:@selector(endRefresh)
//                     withObject:nil afterDelay:3
//                        inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

-(void)filterButtonDo:(id)sender
{
    [self showFilterPage];
}
-(void)showFilterPage
{
    filterPage.hidden = NO;
    filterBGV.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^(void){
        [filterPage setFrame:CGRectMake(8.25, 60, 303.5, 340)];
        
    }];
}
#pragma mark 
#pragma mark - shaixuanshutu
-(void)addFiterPage
{
    filterBGV = [[UIView alloc] initWithFrame:self.view.bounds];
    [filterBGV setBackgroundColor:[UIColor blackColor]];
    [filterBGV setAlpha:0.3];
    [self.view addSubview:filterBGV];
    filterBGV.hidden = YES;
    filterPage = [[UIView alloc] initWithFrame:CGRectMake(8.25, -400, 303.5, 340)];

    UIImageView * bgImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 303.5, 340)];
    [bgImageV setImage:[UIImage imageNamed:@"filterbg.png"]];
    [filterPage addSubview:bgImageV];
    UIButton * hostNone = [UIButton buttonWithType:UIButtonTypeCustom];
    [hostNone setFrame:CGRectMake(30, 67, 95, 39.5)];
    [hostNone setBackgroundImage:[UIImage imageNamed:@"selected-big.png"]forState:UIControlStateNormal];
    [hostNone setTitle:@"不限" forState:UIControlStateNormal];
    [hostNone.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [hostNone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:hostNone];
    hostNone.tag = 1;
    [hostNone addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * hostMale = [UIButton buttonWithType:UIButtonTypeCustom];
    [hostMale setFrame:CGRectMake(30+95+15, 67, 59, 39.5)];
    [hostMale setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"]forState:UIControlStateNormal];
    [hostMale setTitle:@"男" forState:UIControlStateNormal];
    [hostMale.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [hostMale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:hostMale];
    hostMale.tag = 2;
    [hostMale addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * hostFemale = [UIButton buttonWithType:UIButtonTypeCustom];
    [hostFemale setFrame:CGRectMake(30+95+15+59+15, 67, 59, 39.5)];
    [hostFemale setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"]forState:UIControlStateNormal];
    [hostFemale setTitle:@"女" forState:UIControlStateNormal];
    [hostFemale.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [hostFemale setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:hostFemale];
    hostFemale.tag = 3;
    [hostFemale addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * petNone = [UIButton buttonWithType:UIButtonTypeCustom];
    [petNone setFrame:CGRectMake(30, 67+102, 95, 39.5)];
    [petNone setBackgroundImage:[UIImage imageNamed:@"selected-big.png"]forState:UIControlStateNormal];
    [petNone setTitle:@"不限" forState:UIControlStateNormal];
    [petNone.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [petNone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:petNone];
    petNone.tag = 4;
    [petNone addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    petCat = [UIButton buttonWithType:UIButtonTypeCustom];
    [petCat setFrame:CGRectMake(30+95+15, 67+102, 59, 39.5)];
    [petCat setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"]forState:UIControlStateNormal];
    [petCat setTitle:@"猫" forState:UIControlStateNormal];
    [petCat.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [petCat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:petCat];
    petCat.tag = 5;
    [petCat addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    petDog = [UIButton buttonWithType:UIButtonTypeCustom];
    [petDog setFrame:CGRectMake(30+95+15+59+15, 67+102, 59, 39.5)];
    [petDog setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"]forState:UIControlStateNormal];
    [petDog setTitle:@"狗" forState:UIControlStateNormal];
    [petDog.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [petDog setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [filterPage addSubview:petDog];
    petDog.tag = 6;
    [petDog addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    petOther = [UIButton buttonWithType:UIButtonTypeCustom];
    [petOther setFrame:CGRectMake(30, 67+102+39.5+10, 95, 39.5)];
    [petOther setBackgroundImage:[UIImage imageNamed:@"selectednormal-big.png"]forState:UIControlStateNormal];
    [petOther setTitle:@"其它" forState:UIControlStateNormal];
    [petOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [petOther.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [filterPage addSubview:petOther];
    petOther.tag = 7;
    [petOther addTarget:self action:@selector(filterIt:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * showHostBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showHostBtn setFrame:CGRectMake(17, 281.5, 130, 39.5)];
    [showHostBtn setBackgroundImage:[UIImage imageNamed:@"surebtn-normal.png"]forState:UIControlStateNormal];
    [showHostBtn setTitle:@"显示主人" forState:UIControlStateNormal];
    [showHostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [filterPage addSubview:showHostBtn];
    showHostBtn.tag = 10;
    [showHostBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    showPetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showPetBtn setFrame:CGRectMake(155, 281.5, 130, 39.5)];
    [showPetBtn setBackgroundImage:[UIImage imageNamed:@"surebtn-normal.png"]forState:UIControlStateNormal];
    [showPetBtn setTitle:@"显示宠物" forState:UIControlStateNormal];
    [showPetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [filterPage addSubview:showPetBtn];
    showPetBtn.tag = 11;
    [showPetBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filterPage];
    
    self.petTypeTable = [[UITableView alloc] initWithFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 0) style:UITableViewStylePlain];
    self.petTypeTable.dataSource = self;
    self.petTypeTable.delegate = self;
    [filterPage addSubview:self.petTypeTable];
    
    filterPage.hidden = YES;
    
    hostSex = 1;
    petType = 4;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * aview = [touches anyObject];
    if ([[aview view] isEqual:filterBGV]) {
        [UIView animateWithDuration:0.3 animations:^(void){
            [filterPage setFrame:CGRectMake(8.25, -400, 303.5, 340)];
        }completion:^(BOOL finished){
            filterPage.hidden = YES;
            filterBGV.hidden = YES;
            [showPetBtn setTitle:@"显示宠物" forState:UIControlStateNormal];
        }];
    }
}
-(void)okBtnClicked:(UIButton *)sender
{
    switch (hostSex) {
        case 1:
        {

//            [locationDict removeObjectForKey:@"gender"];
            self.titleLabel.text = @"附近的人（全部）";
        }
            break;
        case 2:
        {

            self.titleLabel.text = @"附近的人（男）";
        }
            break;
        case 3:
        {

            self.titleLabel.text = @"附近的人（女）";
        }
            break;
            
        default:
            break;
    }
    if (petType == 4) {
//        [locationDict removeObjectForKey:@"type"];
    }else{

    }
    if (sender.tag==10) {
        //搜索主人
        personOrPet = YES;
    }
    else
    {
        //搜索宠物
        personOrPet = NO;
        self.titleLabel.text = @"附近的宠物";
    }
    
    [UIView animateWithDuration:0.3 animations:^(void){
        [filterPage setFrame:CGRectMake(8.25, -400, 303.5, 340)];
    }completion:^(BOOL finished){
        filterPage.hidden = YES;
        filterBGV.hidden = YES;
        [showPetBtn setTitle:@"显示宠物" forState:UIControlStateNormal];
        [hud show:YES];
    }];
    
    
}
-(void)filterIt:(UIButton *)sender
{
    if (sender.tag==1) {
        [sender setBackgroundImage:[UIImage imageNamed:@"selected-big.png"] forState:UIControlStateNormal];
        UIButton * button1 = (UIButton *)[filterPage viewWithTag:2];
        UIButton * button2 = (UIButton *)[filterPage viewWithTag:3];
        [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"] forState:UIControlStateNormal];
    }
    if (sender.tag==4||sender.tag==7) {
        [sender setBackgroundImage:[UIImage imageNamed:@"selected-big.png"] forState:UIControlStateNormal];
        for (int i = 4; i<8; ++i) {
            UIButton * button1 = (UIButton *)[filterPage viewWithTag:i];
            if (i!=sender.tag) {
                [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"] forState:UIControlStateNormal];
                if (i==7||i==4) {
                    [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-big.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
    if (sender.tag==2||sender.tag==3) {
        [sender setBackgroundImage:[UIImage imageNamed:@"selected-s.png"] forState:UIControlStateNormal];
        for (int i = 1; i<4; ++i) {
            UIButton * button1 = (UIButton *)[filterPage viewWithTag:i];
    
            if (i!=sender.tag){
                [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"] forState:UIControlStateNormal];
                if (i==1) {
                    [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-big.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
    if (sender.tag==5||sender.tag==6||sender.tag==7) {
        [sender setBackgroundImage:[UIImage imageNamed:@"selected-s.png"] forState:UIControlStateNormal];
        for (int i = 4; i<8; ++i) {
            UIButton * button1 = (UIButton *)[filterPage viewWithTag:i];

            if (i!=sender.tag){
                [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-s.png"] forState:UIControlStateNormal];
                if (i==4||i==7) {
                    [button1 setBackgroundImage:[UIImage imageNamed:@"selectednormal-big.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
    if (sender.tag == 4) {
        [petDog setTitle:@"狗" forState:UIControlStateNormal];
        [petCat setTitle:@"猫" forState:UIControlStateNormal];
        [petOther setTitle:@"其他" forState:UIControlStateNormal];
    }
    if (sender.tag==5) {

        self.petArray = [XMLMatcher allCats];
        
        [showPetBtn setTitle:@"显示猫咪" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^(void){
            [self.petTypeTable setFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 120)];
        }];
        [self.petTypeTable reloadData];
    }
    else if (sender.tag==6) {

        self.petArray = [XMLMatcher allDogs];
        
        [showPetBtn setTitle:@"显示狗狗" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^(void){
            [self.petTypeTable setFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 120)];
        }];
        [self.petTypeTable reloadData];
    }
    else if(sender.tag==7){
        [showPetBtn setTitle:@"显示宠物" forState:UIControlStateNormal];
        self.petArray = [XMLMatcher allother];
        [UIView animateWithDuration:0.3 animations:^(void){
            [self.petTypeTable setFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 120)];
        }];
        [self.petTypeTable reloadData];
    }
    else
    {
        [showPetBtn setTitle:@"显示宠物" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^(void){
            [self.petTypeTable setFrame:CGRectMake(30+95+15, 208.5, 59*2+15, 0)];
        }];
    }
    if (sender.tag==1||sender.tag==2||sender.tag==3) {
        hostSex = sender.tag;
    }
    if (sender.tag==4||sender.tag==5||sender.tag==6||sender.tag==7) {
        petType = sender.tag;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
