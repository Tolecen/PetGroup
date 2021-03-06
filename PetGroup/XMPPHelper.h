//
//  XMPPHelper.h
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProcessFriendDelegate.h"
@class XMPPStream;
@class XMPPRosterMemoryStorage;
@class XMPPvCardCoreDataStorage;
@class XMPPvCardTempModule;
@class XMPPvCardAvatarModule;
@class XMPPvCardTemp;
@class Message;
@class XMPPPresence;
@class XMPPRoster;

@interface XMPPHelper : NSObject

typedef void (^CallBackBlock) (void);
typedef void (^XMPPRosterMemoryStorageCallBack) (XMPPRosterMemoryStorage *rosters);
typedef void (^CallBackBlockErr) (NSError *result);

typedef enum {
    reg,
    login
}xmppType;

@property (nonatomic,strong) XMPPStream *xmppStream;
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic,strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic,strong) XMPPvCardTemp *xmppvCardTemp;

@property (nonatomic,strong) NSString *account;
@property (nonatomic,strong) NSString *password;

@property (nonatomic, retain)id addReqDelegate;
@property (nonatomic, retain)id buddyListDelegate;
@property (nonatomic, retain)id chatDelegate;
@property (nonatomic, retain)id xmpprosterDelegate;
@property (nonatomic,retain) id processFriendDelegate;
@property (nonatomic,retain) id notConnect;
@property (nonatomic) xmppType xmpptype;

@property (strong,nonatomic) CallBackBlock success;
@property (strong,nonatomic) CallBackBlockErr fail;
@property (strong,nonatomic) CallBackBlock regsuccess;
@property (strong,nonatomic) CallBackBlockErr regfail;
@property (strong,nonatomic) XMPPRosterMemoryStorageCallBack xmppRosterscallback;
@property (strong,nonatomic) XMPPvCardTemp *myVcardTemp;
@property (strong,nonatomic) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;
@property (strong,nonatomic) XMPPRoster *xmppRoster;

@property (strong,nonatomic) NSMutableArray * rosters;

- (void) setupStream;
- (void) goOnline;
- (void) goOffline;
-(BOOL)ifXMPPConnected;
-(BOOL)connect:(NSString *)account password:(NSString *)password host:(NSString *)host success:(CallBackBlock)Success fail:(CallBackBlockErr)Fail;
-(void) reg:(NSString *)account password:(NSString *)password host:(NSString *)host success:(CallBackBlock)success fail:(CallBackBlockErr)fail;

- (void)updateVCard:(XMPPvCardTemp *)vcard success:(CallBackBlock)success fail:(CallBackBlockErr)fail;
-(XMPPvCardTemp *)getmyvcard;
-(XMPPvCardTemp *)getvcard:(NSString *)account;
-(void)getCompleteRoster:(XMPPRosterMemoryStorageCallBack)callback;
-(void)addOrDenyFriend:(Boolean)issubscribe user:(NSString *)user;
-(void)addFriend:(NSString *)user;
-(void)delFriend:(NSString *)user;
-(void)getIt;
-(void)disconnect;
@end
