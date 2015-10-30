//
//  DownloadQueue.h
//  DownloadFileDemo
//
//  Created by 李远超 on 15/10/21.
//  Copyright (c) 2015年 liyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadGroup.h"


@interface DownloadQueue : NSObject

@property (nonatomic, assign) NSUInteger maxDownloadCount;

+ (DownloadQueue *)mainQueue;

- (void)addDownload:(id)download;

- (DownloadStatus)statusDownload:(NSString *)identifier;
- (void)cancelDownload:(NSString *)identifier;

@end
