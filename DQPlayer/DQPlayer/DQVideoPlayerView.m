//
//  DQVideoPlayerView.m
//  DQPlayer
//
//  Created by  lizhongqiang on 2016/12/20.
//  Copyright © 2016年 林兴栋. All rights reserved.
//

#import "DQVideoPlayerView.h"
#import <Masonry.h>

static void *kPlayerItemObservationContext = &kPlayerItemObservationContext;

static NSString *kStatus = @"status";
static NSString *kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *kPlayBackBufferEmpty = @"playbackBufferEmpty";
static NSString *kPlayBackLikelyToKeepUp = @"playbackLikelyToKeepUp";

@interface DQVideoPlayerView()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playItem;
@property (nonatomic, strong) NSURL *urlPath;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISlider *progressSlider;      //播放进度条
@property (nonatomic, strong) UIProgressView *loadingProgress;//缓冲进度条
@end

@implementation DQVideoPlayerView

#pragma mark - view
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlayView];
    }
    return self;
}

- (void)initPlayView {
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    
    self.topView = [[UIView alloc] init];
    [self.topView setBackgroundColor:[UIColor colorWithRed:100/255 green:100/255 blue:100/255 alpha:0.5]];
    [self.contentView addSubview:self.topView];
    
    self.bottomView = [[UIView alloc] init];
    [self.bottomView setBackgroundColor:[UIColor colorWithRed:100/255 green:100/255 blue:100/255 alpha:0.5]];
    [self.contentView addSubview:self.bottomView];
    
    self.fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullBtn setBackgroundImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [self.fullBtn setBackgroundImage:[UIImage imageNamed:@"nonfullscreen"] forState:UIControlStateSelected];
    [self.fullBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.fullBtn];
    
    self.pauseAndPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseAndPlayBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.pauseAndPlayBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    [self.pauseAndPlayBtn addTarget:self action:@selector(pauseAndPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.pauseAndPlayBtn];
    
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
    
    self.progressSlider.maximumTrackTintColor = [UIColor clearColor];
    //    [self.progressSlider addTarget:self action:@selector(startDragSlide:) forControlEvents:UIControlEventValueChanged];
    //    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.progressSlider];
    
    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor clearColor];
    self.loadingProgress.trackTintColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.text = @"00:00/00:00";
    [self.bottomView addSubview:self.timeLabel];
    
    
    //设置约束
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.top.equalTo(self.contentView.mas_top);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView.mas_left);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView.mas_left);
    }];
    [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    //    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.size.mas_equalTo(CGSizeMake(kPSYWidth, 30));
    //        make.top.equalTo(self.contentView.mas_top);
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //    }];
    //    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.size.mas_equalTo(CGSizeMake(kPSYWidth, 30));
    //        make.bottom.equalTo(self.contentView.mas_bottom);
    //        make.centerX.equalTo(self.contentView.mas_centerX);
    //    }];
    //    [self.fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.size.mas_equalTo(CGSizeMake(15, 15));
    //        make.right.equalTo(self.bottomView.mas_right).with.offset(-5);
    //        make.bottom.equalTo(self.bottomView.mas_bottom).with.offset(-5);
    //    }];
    [self.pauseAndPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(17, 21));
        make.left.equalTo(self.bottomView.mas_left).with.offset(5);
        make.bottom.equalTo(self.bottomView.mas_bottom).with.offset(-5);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bottomView.center);
        make.left.equalTo(self.bottomView.mas_left).with.offset(50);
        make.right.equalTo(self.bottomView.mas_right).with.offset(-130);
    }];
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
        make.right.equalTo(self.progressSlider);
        make.height.mas_equalTo(2);
        //        make.center.mas_equalTo(self.progressSlider.center);
        make.centerX.equalTo(self.progressSlider.mas_centerX);
        make.centerY.equalTo(self.progressSlider.mas_centerY);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.center.mas_equalTo(self.bottomView.center);
        make.centerY.equalTo(self.bottomView.mas_centerY);
        make.right.equalTo(self.fullBtn.mas_left).with.offset(-5);
        //        make.right.equalTo(self.bottomView.mas_right).with.offset(-30);
    }];
    
}

- (void)createVideoPlayer {
//    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video_1.mp4" ofType:nil];
    self.playItem = [AVPlayerItem playerItemWithURL:self.urlPath];
    self.player = [AVPlayer playerWithPlayerItem:_playItem];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.contentView.layer.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    [self.playItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:kPlayerItemObservationContext];
    [self.playItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:kPlayerItemObservationContext];
    [self.playItem addObserver:self forKeyPath:kPlayBackBufferEmpty options:NSKeyValueObservingOptionNew context:kPlayerItemObservationContext];
    [self.playItem addObserver:self forKeyPath:kPlayBackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:kPlayerItemObservationContext];
    [self.player replaceCurrentItemWithPlayerItem:self.playItem];
    //添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playItem];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)setPlayUrl:(NSString *)playUrl {
    
    self.urlPath = [NSURL URLWithString:playUrl];
}

#pragma mark - control
- (void)play {
    [self createVideoPlayer];
    [self.player play];
}



- (void)fullBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:clickFullButton:)]) {
        [self.delegate videoPlayer:self clickFullButton:sender];
    }
}

- (void)pauseAndPlayBtnClick:(UIButton *)sender {
    //rate ==1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
    if (self.player.rate == 1.0) {
        [self.player pause];
    }else if (self.player.rate == 0.0) {
        [self.player play];
    }
    sender.selected = !sender.selected;
}

#pragma mark - 播放完毕
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"视频播放完毕");
    
    //    [self.player seekToTime:<#(CMTime)#>];
}

#pragma mark - KVO监听视频播放
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == kPlayerItemObservationContext) {
        if ([keyPath isEqualToString:kStatus]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusUnknown:
                {
                    [self.loadingProgress setProgress:0.0 animated:NO];
                }
                    break;
                case AVPlayerStatusReadyToPlay:
                {
                    if (CMTimeGetSeconds(self.playItem.duration)) {
                        float totalTime = CMTimeGetSeconds(self.playItem.duration);
                        if (!isnan(totalTime)) {
                            self.progressSlider.maximumValue = totalTime;
                            NSLog(@"totalTime = %f",totalTime);
                        }
                    }
                    [self initTimer];
                }
                    break;
                case AVPlayerStatusFailed:
                {
                    
                }
                    break;
                default:
                    break;
            }
        } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
            //            //计算缓冲
            //            NSTimeInterval timeInterval = [self availableDuration];
            //            CMTime duration = self.playItem.duration;
            //            CGFloat totalDuration = CMTimeGetSeconds(duration);
            //            self.loadingProgress.progressTintColor = [UIColor redColor];
            //            [self.loadingProgress setProgress:timeInterval / totalDuration animated:NO];
        } else if ([keyPath isEqualToString:kPlayBackBufferEmpty]) {
            //当缓冲是空
            
        } else if ([keyPath isEqualToString:kPlayBackLikelyToKeepUp]) {
            //当缓冲完毕
            
        }
    }
}



- (void)initTimer {
    //    double interval = .1f;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        
    }
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf syncScrubber];
    }];
}

- (void)syncScrubber {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        double nowTime = CMTimeGetSeconds([self.player currentTime]);
        double remainTime = duration - nowTime;
        //        self.nowTimeLabel.text = [self convertTime:nowTime];
        //        self.totalTimeLabel.text = [self convertTime:remainTime];
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:nowTime],[self convertTime:remainTime]];
        self.progressSlider.value = nowTime / duration;
        
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        [self.progressSlider setValue:(maxValue - minValue) * nowTime / duration + minValue];
        //        if (self.isDragingSlider == YES) {
        //
        //        } else if (self.isDragingSlider == NO) {
        //
        //        }
    }
}

#pragma mark - 工具
- (NSString *)convertTime:(CGFloat)second {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    if (second / 3600 >= 1) {
        [dateformatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateformatter setDateFormat:@"mm:ss"];
    }
    NSString *newTime = [dateformatter stringFromDate:date];
    return newTime;
}


- (CMTime)playerItemDuration {
    AVPlayerItem *playerItem = _playItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return (kCMTimeInvalid);
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.playItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

@end
