//
//  RecFirstViewController.m
//  Recorder
//
//  Created by Tlacael on 6/29/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import "RecFirstViewController.h"
#import <AudiOS/AudioPlayer.h>
#import "AudioData.h"





@interface RecFirstViewController ()

@property (strong, nonatomic) AudioPlayer *audioPlayer;
@property (strong, nonatomic) AudioData *audioData;
@property (weak, nonatomic) IBOutlet UITextField *recordingStatusText;

@property (weak, nonatomic) IBOutlet UITableViewCell *recordingListCell;


@end

@implementation RecFirstViewController

#pragma mark - Audio Callback



// Our Audio Callback function
void myAudioCallback(Float32 * buffer, UInt32 numFrames, void * userData) {
    
    // Get our structure
    AudioData *audioData = (__bridge AudioData *)(userData);
    
//    // Read samples from audio file
//    Float32 *audioFileBuf = [audioData.afr readSamplesWithBufferSize:numFrames];
//    
//        
//    // Initialise the audio file index for reading
//    int af_idx = 0;
    
    // Main audio loop
    for (int i = 0; i < numFrames; i++) {
               
        // For each channel, let's add one sample from the audio file and another from the sinusoid
        buffer[audioData.numChannels*i] = 0;//.5 * audioFileBuf[af_idx++] + sample;      // left channel
        if (audioData.afr.numChannels == 2) {
            buffer[audioData.numChannels*i + 1] = 0;//.5 * audioFileBuf[af_idx++] + sample;  // right channel
        }
    }

    // Write audio samples to audio file
    if (audioData.startRecording) {
        [audioData.afw writeSamplesWithBuffer: buffer andBufferSize: numFrames];
    }
}

#pragma mark - Lazy Instantiation

- (AudioPlayer*)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[AudioPlayer alloc] initWithSampleRate:self.audioData.srate
                                                     frameSize:self.audioData.bufferSize
                                                andNumChannels:self.audioData.numChannels];
    }
    return _audioPlayer;
}

- (AudioData*)audioData {
    if (!_audioData) {
        _audioData = [[AudioData alloc] init];
        _audioData.srate = 44100;
        _audioData.numChannels = 2;
        _audioData.bufferSize = 1024;

        _audioData.afr = [[AudioFileReader alloc] init];    // Let's do it here, not lazy instantiated
        // (otherwise we may run into performance issues)
        _audioData.afw = [[AudioFileWriter alloc] init];
        _audioData.startRecording = NO;
    }
    return _audioData;
}

- (IBAction)stopRecordingButtonPressed:(id)sender {

    if (self.audioData.startRecording) {
        [self.audioPlayer stopAudio];
        [self.audioData.afw closeFile];
        self.audioData.startRecording = NO;
        [self.recordingStatusText setText:@""];
        
    }
}
- (IBAction)recordButtonPushed:(id)sender {
    static int n = 0;
    // Start audio
    if (!self.audioData.startRecording) {
        n++;
        self.audioData.startRecording = YES;
        NSString *filename = [NSString stringWithFormat:@"Recording-%d", n];
        filename = [filename stringByAppendingString:@".wav"];
        NSLog(@"%s",filename.UTF8String);
        
        [self.audioData.afw loadFileWithName:filename sampleRate:self.audioData.srate andNumChannels:self.audioData.numChannels];
        
        [self.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(self.audioData)];

        [self.recordingStatusText setText:@"RECORDING"];
    }

}
- (IBAction)printFilesButtonPressed:(id)sender {
    NSArray *filenames = [self printFileNames];
    self.recordingListCell.textLabel.text = [filenames lastObject];
    
}

//NSArray *listItems = [list componentsSeparatedByString:@", "];

- (NSString*)getBasepath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSArray*)printFileNames {
    
       
    NSURL *url = [NSURL URLWithString:[self getBasepath]];
    NSError *error = nil;
    NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
                           NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
    
    // [(NSArray*)allPeople mutableCopy];
    NSMutableArray *array = [[[NSFileManager defaultManager]
                      contentsOfDirectoryAtURL:url
                      includingPropertiesForKeys:properties
                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                      error:&error] mutableCopy];
    
    if (array == nil) {
        // Handle the error
    }
    
    
    NSMutableArray *filenames = [[NSMutableArray alloc]init];
    
    for (id obj in array){
        NSString *fname = [NSString stringWithFormat:@"%@",obj];
        NSArray *curFileComponents = [fname componentsSeparatedByString:@"/"];

        [filenames addObject:[curFileComponents lastObject]];
    }
    
    return filenames;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Create audio file
    self.recordingListCell = [[UITableViewCell alloc] init];
    
   
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
