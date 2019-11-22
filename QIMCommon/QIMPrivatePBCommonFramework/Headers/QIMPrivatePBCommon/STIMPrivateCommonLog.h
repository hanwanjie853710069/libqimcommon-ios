//
//  STIMPrivateCommonLog.h
//  STIMPrivatePBCommon
//
//  Created by lilu on 2019/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STIMPrivateCommonLog : NSObject

+ (instancetype)shareInstance;

- (void)recordLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
