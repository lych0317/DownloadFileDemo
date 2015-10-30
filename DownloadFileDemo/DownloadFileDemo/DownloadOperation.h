//
//  DownloadOperation.h
//  DownloadFileDemo
//
//  Created by 李远超 on 15/10/21.
//  Copyright (c) 2015年 liyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+MD5.h"

@class DownloadOperation;

typedef enum {
    DownloadUnknow,
    DownloadReady,
    Downloading,
    DownloadSuccess,
    DownloadFailure
} DownloadStatus;

typedef void(^DownloadOperationInfoBlock)(DownloadOperation *operation, long long totalBytesExpectedToRead);
typedef void(^DownloadOperationProgressBlock)(DownloadOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void(^DownloadOperationSuccessBlock)(DownloadOperation *operation);
typedef void(^DownloadOperationFailureBlock)(DownloadOperation *operation, NSError *error);
typedef void(^DownloadOperationStatusBlock)(DownloadOperation *operation, DownloadStatus status);

@protocol DownloadOperationDelegate <NSObject>

- (void)successDownloadOperation:(DownloadOperation *)operation;
- (void)failureDownloadOperation:(DownloadOperation *)operation;

@end

@interface DownloadOperation : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, getter = isdownLoading) BOOL downLoading;
@property (nonatomic, assign) id<DownloadOperationDelegate> delegate;

- (void)setupWithIdentifier:(NSString *)identifier sourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath info:(DownloadOperationInfoBlock)info progress:(DownloadOperationProgressBlock)progress success:(DownloadOperationSuccessBlock)success failure:(DownloadOperationFailureBlock)failure status:(DownloadOperationStatusBlock)status;

- (void)start;
- (void)pause;
- (void)cancel;

@end
