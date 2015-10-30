//
//  ViewController.m
//  DownloadFileDemo
//
//  Created by 李远超 on 15/10/20.
//  Copyright (c) 2015年 liyc. All rights reserved.
//

#import "ViewController.h"
#import "DownloadQueue.h"
#import "DownloadGroup.h"

#define URLString1 @"http://g-cdn.pre.1tai.com/video_courses/en/jealous/Prechorus_Chorus.mid"
#define URLString2 @"http://g-cdn.pre.1tai.com/video_courses/en/jealous/Prechorus_Chorus.mid"
#define URLString3 @"http://dl.local.xiaoyezi.com/video_courses/zh/john_tompson_2/lesson_3.m4v"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progress1;
@property (weak, nonatomic) IBOutlet UIProgressView *progress2;
@property (weak, nonatomic) IBOutlet UIProgressView *progress3;

@property (nonatomic, strong) DownloadQueue *queue;

@property (nonatomic, strong) DownloadOperation *operation1;
@property (nonatomic, strong) DownloadOperation *operation2;
@property (nonatomic, strong) DownloadOperation *operation3;

@property (nonatomic, strong) DownloadGroup *group;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *path = [caches stringByAppendingPathComponent:@"lesson_1.m4v"];
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:path]){
//        NSLog(@"%lld", [[manager attributesOfItemAtPath:path error:nil] fileSize]);
//    }
    self.progress1.progress = 0;
//    self.progress2.progress = 0;
//    self.progress3.progress = 0;
//
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//
//    self.queue = [[DownloadQueue alloc] init];
//
//    self.operation1 = [[DownloadOperation alloc] init];
//    [self.operation1 setupWithSourcePath:URLString1 destinationPath:[caches stringByAppendingPathComponent:@"lesson_1.m4v"] progress:^(DownloadOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        self.progress1.progress = (double)totalBytesRead / totalBytesExpectedToRead;
//    } success:^(DownloadOperation *operation) {
//        NSLog(@"download 1 success");
//    } failure:^(DownloadOperation *operation, NSError *error) {
//        NSLog(@"download 1 failure");
//    } status:^(DownloadOperation *operation, DownloadOperationStatus status) {
//        NSLog(@"download 1 status %d", status);
//    }];
//
//    self.operation2 = [[DownloadOperation alloc] init];
//    [self.operation2 setupWithSourcePath:URLString2 destinationPath:[caches stringByAppendingPathComponent:@"lesson_2.m4v"] progress:^(DownloadOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        self.progress2.progress = (double)totalBytesRead / totalBytesExpectedToRead;
//    } success:^(DownloadOperation *operation) {
//        NSLog(@"download 2 success");
//    } failure:^(DownloadOperation *operation, NSError *error) {
//        NSLog(@"download 2 failure");
//    } status:^(DownloadOperation *operation, DownloadOperationStatus status) {
//        NSLog(@"download 2 status %d", status);
//    }];
//
//    self.operation3 = [[DownloadOperation alloc] init];
//    [self.operation3 setupWithSourcePath:URLString3 destinationPath:[caches stringByAppendingPathComponent:@"lesson_3.m4v"] progress:^(DownloadOperation *operation, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        self.progress3.progress = (double)totalBytesRead / totalBytesExpectedToRead;
//    } success:^(DownloadOperation *operation) {
//        NSLog(@"download 3 success");
//    } failure:^(DownloadOperation *operation, NSError *error) {
//        NSLog(@"download 3 failure");
//    } status:^(DownloadOperation *operation, DownloadOperationStatus status) {
//        NSLog(@"download 3 status %d", status);
//    }];

    NSArray *sourcePathArray = @[URLString1];
    NSArray *destinationPathArray = @[[caches stringByAppendingPathComponent:@"lesson_1.m4v"]];
    self.group = [[DownloadGroup alloc] init];
    [self.group setupWithSourcePathArray:sourcePathArray destinationPathArray:destinationPathArray progress:^(DownloadGroup *group, NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"%@, %ld, %lld, %lld", group.identifier, bytesRead, totalBytesRead, totalBytesExpectedToRead);
        self.progress1.progress = (double)totalBytesRead / totalBytesExpectedToRead;
    } success:^(DownloadGroup *group) {
        NSLog(@"%@", group.identifier);
    } failure:^(DownloadGroup *group, NSError *error) {
    } status:^(DownloadGroup *group, DownloadGroupStatus status) {
    }];
}
- (IBAction)button1:(UIButton *)sender {
    [self.group start];
//    [self.queue addOperation:self.operation1];
}
- (IBAction)pause1:(UIButton *)sender {
    [self.operation1 cancel];
}
- (IBAction)button2:(UIButton *)sender {
//    [self.queue addOperation:self.operation2];
}
- (IBAction)pause2:(UIButton *)sender {
    [self.operation2 cancel];
}
- (IBAction)button3:(UIButton *)sender {
//    [self.queue addOperation:self.operation3];
}

- (IBAction)pause3:(UIButton *)sender {
    [self.operation3 cancel];
}

@end
