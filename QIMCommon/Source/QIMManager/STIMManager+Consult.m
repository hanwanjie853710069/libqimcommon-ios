
//
//  STIMManager+Consult.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "STIMManager+Consult.h"
#import <objc/runtime.h>

@implementation STIMManager (Consult)

#pragma mark - setter and getter

- (void)setAllhotlines:(NSArray *)allhotlines {
    objc_setAssociatedObject(self, "allhotlines", allhotlines, OBJC_ASSOCIATION_COPY);
}

- (NSArray *)getAllHotLines {
    NSArray *allhotLines = objc_getAssociatedObject(self, "allhotlines");
    if (!allhotLines) {
        allhotLines = [NSArray array];
    }
    return allhotLines;
}

- (void)setMyhotLinelist:(NSArray *)myhotLinelist {
    objc_setAssociatedObject(self, "myhotLinelist", myhotLinelist, OBJC_ASSOCIATION_COPY);
}

- (NSArray *)getMyhotLinelist {
    NSArray *myhotLinelist = objc_getAssociatedObject(self, "myhotLinelist");
    if (!myhotLinelist) {
        myhotLinelist = [NSArray array];
    }
    return myhotLinelist;
}

- (STIMMessageModel *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    STIMMessageModel *message = [STIMMessageModel new];
    [message setMessageId:msgId];
    [message setFrom:[self getLastJid]];
    [message setRealFrom:[self getLastJid]];
    [message setTo:toJid];
    [message setRealTo:realToJid];
    [message setMessageDirection:STIMMessageDirection_Sent];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setExtendInformation:info];
    [message setMessageSendState:STIMMessageSendState_Waiting];
    [message setMessageDate:([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff)*1000];
    
    NSString *sid = nil;
    if (chatType == ChatType_Consult) {
        [message setRealJid:toJid];
        sid = [NSString stringWithFormat:@"%@-%@",toJid,toJid];
    } else {
        [message setRealJid:realToJid];
        sid = [NSString stringWithFormat:@"%@-%@",toJid,realToJid];
    }
    if (msgType != STIMMessageType_TransChatToCustomer_Feedback && msgType != STIMMessageType_TransChatToCustomerService_Feedback && msgType != STIMMessageType_TransChatToCustomerService) {
        [self saveMsg:message ByJid:toJid];
    }
    
    [self saveMsg:message ByJid:toJid];
    NSString *msgRaw = nil;
    NSString *channelInfo = nil;
    
    if (msgType == STIMMessageType_TransChatToCustomer || msgType == STIMMessageType_TransChatToCustomer_Feedback) {
        channelInfo = @"{\"cn\":\"consult\",\"d\":\"send\",\"userType\":\"usr\"}";
    } else {
        channelInfo = @"{\"cn\":\"consult\",\"d\":\"send\",\"userType\":\"common\"}";
    }
    NSDictionary *userAppendInfoDic = [self getAppendInfoForUserId:sid];
    [[XmppImManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:toJid realToJid:realToJid realFromJid:[self getLastJid] channelInfo:channelInfo WithAppendInfoDict:userAppendInfoDic chatId:[NSString stringWithFormat:@"%d",chatType] WithMsgTYpe:msgType OutMsgRaw:&msgRaw];
    
    if (chatType == ChatType_Consult) {
        [self addConsultSessionById:toJid ByRealJid:toJid WithUserId:realToJid ByMsgId:message.messageId WithOpen:NO WithLastUpdateTime:message.messageDate WithChatType:ChatType_Consult];
    } else {
        [self addConsultSessionById:toJid ByRealJid:realToJid WithUserId:realToJid ByMsgId:message.messageId WithOpen:NO WithLastUpdateTime:message.messageDate WithChatType:ChatType_ConsultServer];
    }
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msgId WithMsgRaw:msgRaw];
    }
    return message;
}

- (void)getRemoteHotlineShopList {
//    NSString *destUrl = [NSString stringWithFormat:@"%@/qcadmin/getHotlineShopList.qunar?line=%@&username=%@&host=%@", [[STIMNavConfigManager sharedInstance] newerHttpUrl], @"qtalk", [STIMManager getLastUserName], [[STIMManager sharedInstance] getDomain]];
//    __weak __typeof(self) weakSelf = self;
//    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
//        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
//        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
//        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
//        if (ret && errcode == 0) {
//            NSDictionary *data = [responseDic objectForKey:@"data"];
//            if ([data isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *allhotlines = [data objectForKey:@"allhotlines"];
//                NSArray *myhotlines = [data objectForKey:@"myhotlines"];
//                __typeof(self) strongSelf = weakSelf;
//                if (!strongSelf) {
//                    return;
//                }
//                strongSelf.allhotlines = [allhotlines allKeys];
//                strongSelf.myhotLinelist = myhotlines;
//                NSLog(@"getHotlineShopList.qunar : %@", data);
//            }
//        }
//    } withFailedCallBack:^(NSError *error) {
//
//    }];
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/admin/outer/qtalk/getHotlineList", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *body = @{@"username":[STIMManager getLastUserName], @"host":[[STIMManager sharedInstance] getDomain]};
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:body error:nil];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *allhotlines = [data objectForKey:@"allhotlines"];
                NSArray *myhotlines = [data objectForKey:@"myhotlines"];
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf.allhotlines = allhotlines;
                strongSelf.myhotLinelist = myhotlines;
                NSLog(@"getRemoteHotlineShopList.qunar : %@", data);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
    
}

//V2版获取客服坐席列表：支持多店铺
- (NSArray *)getSeatSeStatus {
    NSString *urlHost = @"https://qcadmin.qunar.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/getSeatSeStatusWithSid.qunar", urlHost]];
    NSString *postDataStr = [NSString stringWithFormat:@"qName=%@", [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resDic objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *data = [resDic objectForKey:@"data"];
            if (data.count > 0) {
                return data;
            }
        }
    }
    return nil;
}

//V2版区别Shop来设置服务模式upSeatSeStatusWithSid.qunar
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus {
    NSString *urlHost = @"https://qcadmin.qunar.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/upSeatSeStatusWithSid.qunar", urlHost]];
    NSString *postDataStr = [NSString stringWithFormat:@"qName=%@&st=%ld&sid=%ld", [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], shopServiceStatus, shopId];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resDic objectForKey:@"ret"] boolValue];
        return ret;
    }
    return NO;
}

- (NSDictionary *)userSeatStatusDict:(int)userStatus {
    
    NSDictionary *userStatusDict = nil;
    for (NSDictionary *dict in [[STIMManager sharedInstance] availableUserSeatStatus]) {
        int status = [[dict objectForKey:@"Status"] intValue];
        if (userStatus == status) {
            userStatusDict = dict;
        }
    }
    return userStatusDict;
}

- (NSString *)userStatusTitleWithStatus:(int)userStatus {
    NSString *statusTitlt = nil;
    for (NSDictionary *dict in [[STIMManager sharedInstance] availableUserSeatStatus]) {
        int status = [[dict objectForKey:@"Status"] intValue];
        if (userStatus == status) {
            statusTitlt = [dict objectForKey:@"StatusTitle"];
        }
    }
    return statusTitlt;
}

- (NSArray *)availableUserSeatStatus {
    
    NSArray *serviceStatus = @[@{@"StatusTitle":[NSBundle stimDB_localizedStringForKey:@"Standard Mode"], @"StatusDesc":[NSBundle stimDB_localizedStringForKey:@"Give consultation while online (defaulted)"], @"Status":@(0)}, @{@"StatusTitle":[NSBundle stimDB_localizedStringForKey:@"Super Mode"], @"StatusDesc":[NSBundle stimDB_localizedStringForKey:@"Give consultation while offline"], @"Status":@(4)}, @{@"StatusTitle":[NSBundle stimDB_localizedStringForKey:@"Snooze Mode"], @"StatusDesc":[NSBundle stimDB_localizedStringForKey:@"Give consultation while online (defaulted)"], @"Status":@(1)}];
    return serviceStatus;
}

- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(STIMCloseSessionBlock)block{
    
    if (!shopId.length || !visitorId.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(nil);
            }
        });
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/admin/api/seat/closeSession.qunar?userName=%@&seatName=%@&virtualname=%@", [[STIMNavConfigManager sharedInstance] javaurl], visitorId, [[STIMManager sharedInstance] getLastJid], shopId];
    [self sendTPPOSTRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSString *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSString class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(data);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WithOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *infoDic in array) {
                STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
            if (list.count < limit && loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                    
                    NSArray *result = [self getConsultServerlogWithFrom:[self getLastJid] virtualId:virtualId to:userId version:version count:(int)(limit - list.count) direction:STIMMessageDirection_Sent];
                    if (result.count > 0) {
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertHistoryChatJSONMsg:result];
                    }
                });
            }
        } else {
            if (loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                    NSArray *resultList = [self getConsultServerlogWithFrom:[self getLastJid] virtualId:virtualId to:userId version:version count:limit direction:STIMMessageDirection_Sent];
                    
                    if (resultList.count > 0) {
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertHistoryChatJSONMsg:resultList];
                        NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WithOffset:offset];
                        NSMutableArray *list = [NSMutableArray array];
                        for (NSDictionary *infoDic in datas) {
                            STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                            [list addObject:msg];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(list);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(@[]);
                        });
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(@[]);
                });
            }
        }
    });
}

@end
