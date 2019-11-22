
//
//  STIMKit+STIMConsult.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "STIMKit+STIMConsult.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMConsult)

- (NSArray *)getAllHotLines {
    return [[STIMManager sharedInstance] getAllHotLines];
}

- (NSArray *)getMyhotLinelist {
    return [[STIMManager sharedInstance] getMyhotLinelist];
}

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
- (STIMMessageModel *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    return [[STIMManager sharedInstance] sendConsultMessageId:msgId WithMessage:msg WithInfo:info toJid:toJid realToJid:realToJid WithChatType:chatType WithMsgType:msgType];
}

/**
 获取远程的热线账号列表
 */
- (void)getRemoteHotlineShopList {
    [[STIMManager sharedInstance] getRemoteHotlineShopList];
}

//V2版获取客服坐席列表：支持多店铺
- (NSArray *)getSeatSeStatus {
    return [[STIMManager sharedInstance] getSeatSeStatus];
}

//V2版区别Shop来设置服务模式upSeatSeStatusWithSid.qunar

/**
 根据店铺Id 设置服务模式
 
 @param shopId 店铺Id
 @param shopServiceStatus 服务模式
 @return 是否设置成功
 */
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus {
    return [[STIMManager sharedInstance] updateSeatSeStatusWithShopId:shopId WithStatus:shopServiceStatus];
}

/**
 根据服务模式获取基础信息
 
 @param userStatus 服务模式
 */
- (NSDictionary *)userSeatStatusDict:(int)userStatus {
    return [[STIMManager sharedInstance] userSeatStatusDict:userStatus];
}

- (NSString *)userStatusTitleWithStatus:(int)userStatus {
    return [[STIMManager sharedInstance] userStatusTitleWithStatus:userStatus];
}

/**
 获取状态坐席状态列表
 */
- (NSArray *)availableUserSeatStatus {
    return [[STIMManager sharedInstance] availableUserSeatStatus];
}

/**
 关闭会话
 
 @param shopId ShopId
 @param visitorId 客人Id
 @return 关闭之后的提示语
 */
- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(STIMCloseSessionBlock)block {
    [[STIMManager sharedInstance] closeSessionWithShopId:shopId WithVisitorId:visitorId withBlock:block];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getConsultServerMsgLisByUserId:userId WithVirtualId:virtualId WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

@end
