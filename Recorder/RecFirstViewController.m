//
//  RecFirstViewController.m
//  Recorder
//
//  Created by Tlacael on 6/29/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import "RecFirstViewController.h"
#import "RecAppDelegate.h"
#import "AudioHandling.h"

#define kYOffset -1.f

@interface RecFirstViewController ()


@property (weak, nonatomic) IBOutlet UITextField *recordingStatusText;
@property (weak, nonatomic) AudioHandling *aud;

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
    // Write audio samples to audio file
    if (audioData.startRecording) {
        [audioData.afw writeSamplesWithBuffer: buffer andBufferSize: numFrames];
    }
    // Main audio loop
    for (int i = 0; i < numFrames; i++) {
        // Write into the line buffer to visualize the mic input
        audioData.line[4*i+1] = buffer[i] + kYOffset;
        audioData.line[4*i+1+2] = buffer[i] + kYOffset;
        
        // For each channel, let's add one sample from the audio file and another from the sinusoid
       // buffer[audioData.numChannels*i] = 0;//.5 * audioFileBuf[af_idx++] + sample;      // left channel
        if (audioData.afr.numChannels == 2) {
         //   buffer[audioData.numChannels*i + 1] = 0;//.5 * audioFileBuf[af_idx++] + sample;  // right channel
        }

    }


}

#pragma mark - Lazy Instantiation


- (AudioHandling  *)aud {
    if (!_aud) {
        _aud = [AudioHandling sharedAudio];
    }
    return _aud;
}

#pragma mark - Buttons
- (IBAction)stopRecordingButtonPressed:(id)sender {
    

    if (self.aud.audioData.startRecording) {
        [self.aud.audioPlayer stopAudio];
        [self.aud.audioData.afw closeFile];
        self.aud.audioData.startRecording = NO;
        
        [self.recordingStatusText setText:@""];

        
    }
}


- (IBAction)recordButtonPushed:(id)sender {
    static int n = 0;
    // Start audio
    if (!self.aud.audioData.startRecording) {
        n++;
        
        NSString *filename = [NSString stringWithFormat:@"Recording-%d", n];
        filename = [filename stringByAppendingString:@".wav"];
        NSLog(@"%s",filename.UTF8String);
        
        [self.aud.audioData.afw loadFileWithName:filename sampleRate:self.aud.audioData.srate andNumChannels:self.aud.audioData.numChannels];
        
        self.aud.audioData.startRecording = YES;
        [self.aud.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(self.aud.audioData)];

        [self.recordingStatusText setText:@"RECORDING"];
    }

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
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.aud.audioPlayer stopAudio];
    [self.aud.audioData.afw closeFile];
    self.aud.audioData.startRecording = NO;
    
    [self.recordingStatusText setText:@""];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
