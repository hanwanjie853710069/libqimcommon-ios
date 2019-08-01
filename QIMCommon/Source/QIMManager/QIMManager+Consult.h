//
//  QIMManager+Consult.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

@interface QIMManager (Consult)

/**
 虚拟账号的RealJid列表
 */
//@property (nonatomic, strong) NSMutableDictionary *virtualRealJidDic;

/**
 虚拟账号列表
 */
//@property (nonatomic, strong) NSArray *virtualList;

/**
 虚拟账号列表
 */
@property (nonatomic, strong) NSDictionary *virtualDic;

/**
 我的热线账号列表
 */
@property (nonatomic, strong) NSArray *myhotLinelist;

/**
 获取虚拟账号列表
 */
//- (NSArray *)getVirtualList;

- (NSDictionary *)getVirtualDic;

- (NSArray *)getMyhotLinelist;

- (void)getHotlineShopList;

/**
 发送Consult消息

 @param msgId MsgId
 @param msg 消息Body内容
 @param info 消息ExtendInfo
 @param toJid 消息
 @param realToJid 真实RealJid
 @param chatType 会话类型
 @param msgType 消息类型
 @return 消息对象Message
 */
- (QIMMessageModel *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType;

- (void)customerConsultServicesayHelloWithUser:(NSString *)user WithVirtualId:(NSString *)virtualId WithFromUser:(NSString *)fromUser;

- (void)customerServicesayHelloWithUser:(NSString *)user;

- (NSArray *)searchSuggestWithKeyword:(NSString *)keyword;

- (NSArray *)getSuggestOrganizationBySuggestId:(NSString *)suggestId;

/**
 根据店铺Id 设置服务模式

 @param shopId 店铺Id
 @param shopServiceStatus 服务模式
 @return 是否设置成功
 */
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus;

/**
 根据服务模式获取基础信息

 @param userStatus 服务模式
 */
- (NSDictionary *)userSeatStatusDict:(int)userStatus;

- (NSString *)userStatusTitleWithStatus:(int)userStatus;

- (NSArray *)getSeatSeStatus;

/**
 获取状态坐席状态列表
 */
- (NSArray *)availableUserSeatStatus;

/**
 关闭会话

 @param shopId ShopId
 @param visitorId 客人Id
 @return 关闭之后的提示语
 */
- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(QIMCloseSessionBlock)block;

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete;

@end