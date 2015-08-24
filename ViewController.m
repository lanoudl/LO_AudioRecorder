//
//  ViewController.m
//  LOAudioRecorder
//
//  Created by 肖野 on 15/8/22.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //第一步，进行录音设置
    [self audio];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 100, 100, 100)];
    [self updateImage];
    [self.view addSubview:_imageView];
    
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = CGRectMake(self.imageView.frame.origin.x, 250, 40, 40);
    [_btn setTitle:@"开始" forState:UIControlStateNormal];
    [_btn setBackgroundColor:[UIColor greenColor]];
    
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(self.imageView.frame.origin.x + 50, 250, 40, 40);
    [_playBtn setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:_playBtn];
    
    //当按钮被按下
    [self.btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    //当手指抬起时
    [self.btn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
    
    //    仅当触摸拖动离开控件范围时发生一次。
    [self.btn addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
    [self.view addSubview:_btn];
    
    [self.playBtn addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchDown];
}

- (void)playRecordSound:(id)sender
{
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil];
    self.avPlay = player;
    
    [self.avPlay play];
}

- (void)btnDown:(UIButton *)sender
{
    [sender setTitle:@"暂停" forState:UIControlStateNormal];
    
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
    
    //设置定时检测
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
- (void)btnUp:(UIButton *)sender
{
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    
    double cTime = recorder.currentTime;
    if (cTime > 2) {//如果录制时间<2 不发送
        NSLog(@"发出去");
    }else {
        //删除记录的文件
        [recorder deleteRecording];
        //删除存储的
    }
    [recorder stop];
    [timer invalidate];
}
- (void)btnDragUp:(UIButton *)sender
{
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    
    NSLog(@"取消发送");
}
- (void)audio
{
    //配置Recorder，
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record.aac", strUrl]];
    urlPlay = url;
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}
//配置好Recorder之后，开始，实现录音按钮，录音按钮功能非常简单，只需要判断当前Recorder处于录音状态则调用stop方法结束录音，否则调用record方法开始录音，同时更新UI元素。


- (void)detectionVoice
{
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else{
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}
- (void) updateImage
{
    [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
