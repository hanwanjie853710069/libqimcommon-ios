//
//  STIMHttpApi.h
//  qunarChatMac
//
//  Created by ping.xue on 14-3-13.
//  Copyright (c) 2014年 May. All rights reserved.
//

//extern NSString *kIMInnerFileServer;

#import <Foundation/Foundation.h>
#import "STIMCommonEnum.h"

CFStringRef STIMFileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData);
CFStringRef STIMFileMD5HashCreateWithData(const void *data,long long dataLenght);

@interface STIMHttpApi : NSObject

+ (NSString *)checkFileKeyForFile:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension;

+ (NSString *)checkFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension;

+ (NSDictionary *)checkUserToken:(NSString *)verifCode;

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode;

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName;

+ (NSString *) updateLoadMomentFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

+ (NSString *) updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

+ (void)uploadVideo:(NSData *)fileData withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback;

+ (void)uploadVideoPath:(NSString *)filePath withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback;

+ (NSDictionary *)getUserList;

+ (NSString *)updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

//add by dan.zheng 15-4-24
+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath;
+ (NSString *)updateMyPhoto:(NSData *)headerData;

+(NSString *)getFileDataMD5WithFileData:(NSData *)fileData;

+(NSString*)getFileMD5WithPath:(NSString*)path;

@end

@interface STIMHttpApi(CommonMethod)

+ (NSString *)UUID;
+ (NSDictionary *)deserializeAsDictionary:(NSData *)data;

@end
