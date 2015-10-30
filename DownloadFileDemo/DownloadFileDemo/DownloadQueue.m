//
//  DownloadQueue.m
//  DownloadFileDemo
//
//  Created by 李远超 on 15/10/21.
//  Copyright (c) 2015年 liyc. All rights reserved.
//

#import "DownloadQueue.h"

@interface DownloadQueue () <DownloadOperationDelegate, DownloadGroupDelegate>

@property (nonatomic, assign) NSInteger downloadingCount;
@property (nonatomic, strong) NSMutableArray *downloadArray;

@end

@implementation DownloadQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloadingCount = 0;
        self.maxDownloadCount = 4;
        self.downloadArray = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (DownloadQueue *)mainQueue {
    static id sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[self alloc] init];
    });
    return sharedSingleton;
}

- (void)addDownload:(id)download {
    if ([download isKindOfClass:[DownloadOperation class]]) {
        [self addOperation:download];
    } else if ([download isKindOfClass:[DownloadGroup class]]) {
        [self addGroup:download];
    }
}

- (id)downloadWithIdentifier:(NSString *)identifier {
    for (id download in self.downloadArray) {
        if ([download isKindOfClass:[DownloadOperation class]]) {
            DownloadOperation *o = download;
            if ([o.identifier isEqualToString:identifier]) {
                return o;
            }
        } else if ([download isKindOfClass:[DownloadGroup class]]) {
            DownloadGroup *g = download;
            if ([g.identifier isEqualToString:identifier]) {
                return g;
            }
        }
    }
    return nil;
}

- (DownloadStatus)statusDownload:(NSString *)identifier {
    id download = [self downloadWithIdentifier:identifier];
    if ([download isKindOfClass:[DownloadOperation class]]) {
        DownloadOperation *o = download;
        if (o.isdownLoading) {
            return Downloading;
        } else {
            return DownloadReady;
        }
    } else if ([download isKindOfClass:[DownloadGroup class]]) {
        DownloadGroup *g = download;
        if (g.isdownLoading) {
            return Downloading;
        } else {
            return DownloadReady;
        }
    } else {
        return DownloadUnknow;
    }
}

- (void)cancelDownload:(NSString *)identifier {
    id download = [self downloadWithIdentifier:identifier];
    if ([download isKindOfClass:[DownloadOperation class]]) {
        DownloadOperation *o = download;
        [o cancel];
//        [self removeOperation:o];
    } else if ([download isKindOfClass:[DownloadGroup class]]) {
        DownloadGroup *g = download;
        [g cancel];
//        [self removeGroup:g];
    }
}

- (void)addOperation:(DownloadOperation *)operation {
    operation.delegate = self;
    [self.downloadArray addObject:operation];
    if (self.downloadingCount < self.maxDownloadCount) {
        [operation start];
        self.downloadingCount++;
    }
}

- (void)removeOperation:(DownloadOperation *)operation {
    [self.downloadArray removeObject:operation];
    self.downloadingCount = 0;
    for (NSUInteger i = 0, count = self.downloadArray.count; i < count; i++) {
        DownloadOperation *o = self.downloadArray[i];
        if (o.isdownLoading) {
            self.downloadingCount++;
        }
    }
    if (self.downloadingCount < self.maxDownloadCount) {
        for (NSUInteger i = 0, count = self.downloadArray.count; i < count; i++) {
            DownloadOperation *o = self.downloadArray[i];
            if (o.isdownLoading == NO) {
                [o start];
                self.downloadingCount++;
                break;
            }
        }
    }
}

- (void)addGroup:(DownloadGroup *)group {
    group.delegate = self;
    [self.downloadArray addObject:group];
    if (self.downloadingCount < self.maxDownloadCount) {
        [group start];
        self.downloadingCount++;
    }
}

- (void)removeGroup:(DownloadGroup *)group {
    [self.downloadArray removeObject:group];
    self.downloadingCount = 0;
    for (NSUInteger i = 0, count = self.downloadArray.count; i < count; i++) {
        DownloadGroup *g = self.downloadArray[i];
        if (g.isdownLoading) {
            self.downloadingCount++;
        }
    }
    if (self.downloadingCount < self.maxDownloadCount) {
        for (NSUInteger i = 0, count = self.downloadArray.count; i < count; i++) {
            DownloadGroup *g = self.downloadArray[i];
            if (g.isdownLoading == NO) {
                [g start];
                self.downloadingCount++;
                break;
            }
        }
    }
}

#pragma mark - DownloadOperationDelegate

- (void)successDownloadOperation:(DownloadOperation *)operation {
    [self removeOperation:operation];
}

- (void)failureDownloadOperation:(DownloadOperation *)operation {
    [self removeOperation:operation];
}

#pragma mark - DownloadGroupDelegate

- (void)successDownloadGroup:(DownloadGroup *)group {
    [self removeGroup:group];
}

- (void)failureDownloadGroup:(DownloadGroup *)group {
    [self removeGroup:group];
}

@end
