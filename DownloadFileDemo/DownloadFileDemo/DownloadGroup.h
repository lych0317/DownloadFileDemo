//
//  DownloadGroup.h
//  beethoven-new
//
//  Created by 李远超 on 15/10/22.
//
//

#import <Foundation/Foundation.h>
#import "DownloadOperation.h"

@class DownloadGroup;

typedef void(^DownloadGroupProgressBlock)(DownloadGroup *group, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void(^DownloadGroupSuccessBlock)(DownloadGroup *group);
typedef void(^DownloadGroupFailureBlock)(DownloadGroup *group, NSError *error);
typedef void(^DownloadGroupStatusBlock)(DownloadGroup *group, DownloadStatus status);

@protocol DownloadGroupDelegate <NSObject>

- (void)successDownloadGroup:(DownloadGroup *)group;
- (void)failureDownloadGroup:(DownloadGroup *)group;

@end

@interface DownloadGroup : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, assign, getter = isdownLoading) BOOL downLoading;
@property (nonatomic, assign) id<DownloadGroupDelegate> delegate;

- (void)setupWithIdentifier:(NSString *)identifier sourcePathArray:(NSArray *)sourcePathArray destinationPathArray:(NSArray *)destinationPathArray progress:(DownloadGroupProgressBlock)progress success:(DownloadGroupSuccessBlock)success failure:(DownloadGroupFailureBlock)failure status:(DownloadGroupStatusBlock)status;

- (void)start;
- (void)pause;
- (void)cancel;

@end
