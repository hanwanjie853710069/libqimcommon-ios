//
//  DataController.m
//  qunarChatIphone
//
//  Created by wangshihai on 15/2/6.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "STIMDataController.h"
#import "NSString+STIMUtility.h"
#import "STIMUtility.h"
#import "STIMFileManager.h"
#import "STIMManager.h"
#define kResourceCachePath                          @"Resource"
#define kImageCahce                                 @"STIMImageCache"
#define kHashSalt                                   @"iqunar"
#define kResourceEmptyValue                             "\0"

static STIMDataController *__globalDataController = nil;
@implementation STIMDataController

+ (STIMDataController *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalDataController = [[STIMDataController alloc] init];
    });
    return __globalDataController;
}

// 保存
- (void)save {

}

// 销毁
- (void)destroy {

}

- (NSData *)getResourceData:(NSString *)key{
    return [[STIMFileManager sharedInstance] getFileDataFromUrl:key forCacheType:STIMFileCacheTypeColoction];
    
    
    if (![key stimDB_isStringSafe])
    {
        return nil;
    }
    UIImage *resource = nil;
    NSString *fileName = [NSString stimDB_hashString:key withSalt:kHashSalt];
    NSData *data = [self getResourceWithFileName:fileName];
    return data;
}

- (UIImage *)getResourceImage:(NSString *)key {
    if (![key stimDB_isStringSafe])
    {
        return nil;
    }
    
    UIImage *resource = nil;
    NSString *fileName = [NSString stimDB_hashString:key withSalt:kHashSalt];
    NSData *data = [self getResourceWithFileName:fileName];
    if ([data isEqualToData:[NSData dataWithBytes:kResourceEmptyValue length:2]])
    {
        // 无效数据
    }
    else
    {
        UIImage *image = [UIImage imageWithData:data];
        if (nil == image)
        {
            // 非图片数据
        }
        else
        {
            resource = image;
        }
    }
    return resource;
}

- (long long) sizeofImagePath {
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    NSString *newcachePath = [STIMFileManager documentsofPath:STIMFileCacheTypeColoction];
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];

    return [STIMUtility sizeofPath:cachePath] + [STIMUtility sizeofPath:newcachePath] + [STIMUtility sizeofPath:logDirectory];
}

- (long long)sizeOfDBPath {
    NSString *dbPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/STIMNewDataBase/%@%@/", [[STIMManager sharedInstance] getLastJid], UserPath]];
    [[STIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[dbPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    dbPath = [dbPath stringByAppendingPathComponent:@"data.dat"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:dbPath error:nil] fileSize];
        
    }
    return 0;
}
    
- (long long)sizeOfDBWALPath {
    NSString *dbWalPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/STIMNewDataBase/%@%@/", [[STIMManager sharedInstance] getLastJid], UserPath]];
    [[STIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[dbWalPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    dbWalPath = [dbWalPath stringByAppendingPathComponent:@"data.dat-wal"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbWalPath]) {
        
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:dbWalPath error:nil] fileSize];
        
    }
    return 0;
}

- (NSString *)transfromTotalSize:(long long)totalSize {
    NSString *str = nil;
    if (totalSize < 1048576) {
        // 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1024.0;
        str = [NSString stringWithFormat:@"%.2fKB", result];
    } else if (totalSize < 1073741824) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1048576.0;
        str = [NSString stringWithFormat:@"%.2fMB", result];
    } else if (totalSize < 1099511627776) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1073741824.0;
        str = [NSString stringWithFormat:@"%.2fGB", result];
    }
    return str;
}

- (void) deleteAllFilesAtPath:(NSString *) cachePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:filename] error:NULL];
    }
}

- (void) removeAllImage {
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    NSString *newcachePath = [STIMFileManager documentsofPath:STIMFileCacheTypeColoction];
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    [self deleteAllFilesAtPath:cachePath];
    [self deleteAllFilesAtPath:newcachePath];
    [self deleteAllFilesAtPath:imageCachePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kQCRemoveImageCachePathSuccess object:nil];
    });
}

- (void)clearLogFiles {
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];
    [[NSFileManager defaultManager] removeItemAtPath:logDirectory error:nil];
}

- (NSData *)getResourceWithFileName:(NSString *)fileName {
    NSData *data = nil;
    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    // cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
    {
        data = [[NSFileManager defaultManager] contentsAtPath:resourcePath];
    }
    return data;
}

-(NSString *)getSourcePath:(NSString *)fileName {
    fileName  = [NSString stimDB_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    // cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
   
    return resourcePath;
}

-(void)deleteResourceWithFileName:(NSString *)fileName {
    fileName = [NSString stimDB_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
}

- (void)saveResourceWithFileName:(NSString *)fileName data:(NSData *)data {
    
     fileName = [NSString stimDB_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    [data writeToFile:resourcePath atomically:YES];
    
}

// 添加资源
- (void)addResource:(id)resource withKey:(NSString *)key {
    if (![key stimDB_isStringSafe])
    {
        return;
    }
    if (resource == [NSNull null])
    {
        resource = [NSData dataWithBytes:kResourceEmptyValue length:2];
    }
    dispatch_block_t block = ^{
        NSString *fileName = [NSString stimDB_hashString:key withSalt:kHashSalt];
        [self saveResourceWithFileName:fileName data:resource];
    };
    [STIMUtility performInBackground:block];
}

@end
