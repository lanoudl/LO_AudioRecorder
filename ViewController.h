//
//  ViewController.h
//  LOAudioRecorder
//
//  Created by 肖野 on 15/8/22.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
//这个库是C的接口，偏向于底层，主要用于在线流媒体的播放。
#import <AVFoundation/AVFoundation.h>
//提供了音频和回放的底层API，同时也负责管理音频硬件

@interface ViewController : UIViewController<AVAudioRecorderDelegate>
{
    //用来录音
    AVAudioRecorder *recorder;
    //设置定时检测，用来监听当前音量大小，控制话筒图片。
    NSTimer *timer;
    
    NSURL *urlPlay;
}

/**
 *  用来控制我们的录音功能
 */
@property (nonatomic, retain) UIButton *btn;
/**
 *  用来播放已经录好的音频文件
 */
@property (nonatomic, retain) UIButton *playBtn;
/**
 *  控制音量的图片
 */
@property (nonatomic, retain) UIImageView *imageView;
/**
 *  音频播放器
 */
@property (nonatomic, retain) AVAudioPlayer *avPlay;

@end

