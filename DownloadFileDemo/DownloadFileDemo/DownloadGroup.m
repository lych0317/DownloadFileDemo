//
//  DownloadGroup.m
//  beethoven-new
//
//  Created by 李远超 on 15/10/22.
//
//

#import "DownloadGroup.h"

@interface DownloadGroup ()

@property (nonatomic, strong) NSArray *downloadOperationArray;

@property (nonatomic, assign) long long currentLength;
@property (nonatomic, assign) long long totalLength;

@property (nonatomic, assign) NSInteger totalByteFlag;
@property (nonatomic, assign) NSInteger successFlag;

@property (nonatomic, copy) DownloadGroupStatusBlock statusBlock;

@end

@implementation DownloadGroup

- (void)setupWithIdentifier:(NSString *)identifier sourcePathArray:(NSArray *)sourcePathArray destinationPathArray:(NSArray *)destinationPathArray progress:(DownloadGroupProgressBlock)progress success:(DownloadGroupSuccessBlock)success failure:(DownloadGroupFailureBlock)failure status:(DownloadGroupStatusBlock)status {
    if (sourcePathArray == nil || sourcePathArray.count == 0) {
        return;
    }
    if (destinationPathArray == nil || destinationPathArray.count == 0) {
        return;
    }
    if (sourcePathArray.count != destinationPathArray.count) {
        return;
    }
    _downLoading = NO;
    self.totalByteFlag = 1;
    self.successFlag = 1;
    _identifier = identifier;
    self.statusBlock = status;

    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:sourcePathArray.count];
    for (NSUInteger i = 0, count = sourcePathArray.count; i < count; i++) {
        DownloadOperation *operation = [[DownloadOperation alloc] init];
        NSString *sourcePath = sourcePathArray[i];
        NSString *destinationPath = destinationPathArray[i];
        NSString *identifier = [sourcePath getMd5_32Bit];
        [operation setupWithIdentifier:identifier sourcePath:sourcePath destinationPath:destinationPath info:^(DownloadOperation *operation, long long totalBytesExpectedToRead) {
            self.totalLength += totalBytesExpectedToRead;
            self.totalByteFlag *= 2;
        } progress:^(DownloadOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            self.currentLength += bytesRead;
            if (progress && self.totalByteFlag == pow(2, count)) {
                progress(self, bytesRead, self.currentLength, self.totalLength);
            }
        } success:^(DownloadOperation *operation) {
            self.successFlag *= 2;
            if (self.successFlag == pow(2, count)) {
                _downLoading = NO;

                if (success) {
                    success(self);
                }

                if (self.statusBlock) {
                    self.statusBlock(self, DownloadSuccess);
                }

                if ([self.delegate respondsToSelector:@selector(successDownloadGroup:)]) {
                    [self.delegate successDownloadGroup:self];
                }
            }
        } failure:^(DownloadOperation *operation, NSError *error) {
            _downLoading = NO;

            if (failure) {
                failure(self, error);
                [self cancel];
            }

            if (self.statusBlock) {
                self.statusBlock(self, DownloadFailure);
            }

            if ([self.delegate respondsToSelector:@selector(failureDownloadGroup:)]) {
                [self.delegate failureDownloadGroup:self];
            }
        } status:nil];

        [array addObject:operation];
    }
    self.downloadOperationArray = array;

    if (self.statusBlock) {
        self.statusBlock(self, DownloadReady);
    }
}

- (void)start {
    if (self.downloadOperationArray) {
        MyLogInfo(@"start download %@", self.identifier);
        [self.downloadOperationArray enumerateObjectsUsingBlock:^(DownloadOperation *o, NSUInteger idx, BOOL *stop) {
            [o start];
        }];
        _downLoading = YES;

        if (self.statusBlock) {
            self.statusBlock(self, Downloading);
        }
    }
}

- (void)pause {
    if (self.downloadOperationArray) {
        [self.downloadOperationArray enumerateObjectsUsingBlock:^(DownloadOperation *o, NSUInteger idx, BOOL *stop) {
            [o pause];
        }];
        _downLoading = NO;

        if (self.statusBlock) {
            self.statusBlock(self, DownloadFailure);
        }
    }
}

- (void)cancel {
    if (self.downloadOperationArray) {
        MyLogInfo(@"cancel download %@", self.identifier);
        [self.downloadOperationArray enumerateObjectsUsingBlock:^(DownloadOperation *o, NSUInteger idx, BOOL *stop) {
            [o cancel];
        }];
        _downLoading = NO;

        if (self.statusBlock) {
            self.statusBlock(self, DownloadFailure);
        }

        if ([self.delegate respondsToSelector:@selector(failureDownloadGroup:)]) {
            [self.delegate failureDownloadGroup:self];
        }
    }
}

@end
