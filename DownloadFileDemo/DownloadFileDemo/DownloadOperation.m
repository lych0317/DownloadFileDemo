//
//  DownloadOperation.m
//  DownloadFileDemo
//
//  Created by 李远超 on 15/10/21.
//  Copyright (c) 2015年 liyc. All rights reserved.
//

#import "DownloadOperation.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface DownloadOperation () <NSURLConnectionDataDelegate>

@property (nonatomic, assign) long long totalLength;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, copy) NSString *destinationPath;

@property (nonatomic, copy) DownloadOperationInfoBlock infoBlock;
@property (nonatomic, copy) DownloadOperationProgressBlock progressBlock;
@property (nonatomic, copy) DownloadOperationSuccessBlock successBlock;
@property (nonatomic, copy) DownloadOperationFailureBlock failureBlock;
@property (nonatomic, copy) DownloadOperationStatusBlock statusBlock;

@end

@implementation DownloadOperation

- (void)setupWithIdentifier:(NSString *)identifier sourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath info:(DownloadOperationInfoBlock)info progress:(DownloadOperationProgressBlock)progress success:(DownloadOperationSuccessBlock)success failure:(DownloadOperationFailureBlock)failure status:(DownloadOperationStatusBlock)status {
    if (sourcePath == nil || sourcePath.length == 0) {
        return;
    }
    if (destinationPath == nil || destinationPath.length == 0) {
        return;
    }
    _identifier = identifier;
    self.sourcePath = sourcePath;
    self.destinationPath = destinationPath;
    self.infoBlock = info;
    self.progressBlock = progress;
    self.successBlock = success;
    self.failureBlock = failure;
    self.statusBlock = status;

    _downLoading = NO;
    self.totalLength = 0;

    NSURL *url = [NSURL URLWithString:self.sourcePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;

    self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [self.requestOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:self.destinationPath append:NO]];
    __weak DownloadOperation *weakSelf = self;
    [self.requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (weakSelf.totalLength == 0) {
            weakSelf.totalLength = totalBytesExpectedToRead;
            if (weakSelf.infoBlock) {
                weakSelf.infoBlock(weakSelf, totalBytesExpectedToRead);
            }
        }
        if (weakSelf.progressBlock) {
            weakSelf.progressBlock(weakSelf, bytesRead, totalBytesRead, totalBytesExpectedToRead);
        }
    }];
    [self.requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf success];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf failure:error];
    }];

    if (self.statusBlock) {
        self.statusBlock(self, DownloadReady);
    }
}

- (void)start {
    if (self.requestOperation) {
        [self removeFileAtPath:self.destinationPath];

        MyLogInfo(@"start download source path %@", self.sourcePath);
        MyLogInfo(@"start download destination path %@", self.destinationPath);

        [self.requestOperation start];
        _downLoading = YES;

        if (self.statusBlock) {
            self.statusBlock(self, Downloading);
        }
    }
}

- (void)pause {

}

- (void)cancel {
    if (self.requestOperation) {
        [self.requestOperation cancel];
        self.requestOperation = nil;
        _downLoading = NO;

        if (self.statusBlock) {
            self.statusBlock(self, DownloadFailure);
        }

        if ([self.delegate respondsToSelector:@selector(failureDownloadOperation:)]) {
            [self.delegate failureDownloadOperation:self];
        }
    }
    [self removeFileAtPath:self.destinationPath];
}

- (void)success {
    _downLoading = NO;
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.destinationPath error:&error];
    if (error) {
        [self failure:error];
    } else if (attributes == nil) {
        error = [NSError errorWithDomain:@"download error" code:0 userInfo:nil];
        [self failure:error];
    } else {
        long long fileSize = [attributes[@"NSFileSize"] longLongValue];
        if (fileSize != self.totalLength) {
            error = [NSError errorWithDomain:@"download error" code:0 userInfo:nil];
            [self failure:error];
        } else {
            if (self.successBlock) {
                self.successBlock(self);
            }

            if (self.statusBlock) {
                self.statusBlock(self, DownloadSuccess);
            }

            if ([self.delegate respondsToSelector:@selector(successDownloadOperation:)]) {
                [self.delegate successDownloadOperation:self];
            }
        }
    }
}

- (void)failure:(NSError *)error {
    _downLoading = NO;

    [self removeFileAtPath:self.destinationPath];

    if (self.failureBlock) {
        self.failureBlock(self, error);
    }

    if (self.statusBlock) {
        self.statusBlock(self, DownloadFailure);
    }

    if ([self.delegate respondsToSelector:@selector(failureDownloadOperation:)]) {
        [self.delegate failureDownloadOperation:self];
    }
}

- (void)removeFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

@end
