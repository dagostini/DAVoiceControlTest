//
//  ViewController.m
//  DAVoiceControlTest
//
//  Created by Dejan on 04/08/14.
//  Copyright (c) 2014 Dejan. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/PocketsphinxController.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>


@interface ViewController () {
    OpenEarsEventsObserver *_eventsObserver;
    PocketsphinxController *_pocketSphinxController;
    Slt *_slt;
    FliteController *_fliteController;
}

@end


@implementation ViewController


#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createEventsObserver];
    [self createPocketSphinxController];
    [self createSlt];
    [self createFLiteController];
    [self createCommandsArrayAndStartListening];
}

- (void)createEventsObserver {
    if (!_eventsObserver) {
        _eventsObserver = [OpenEarsEventsObserver new];
        _eventsObserver.delegate = self;
    }
}

- (void)createPocketSphinxController {
    if (!_pocketSphinxController) {
        _pocketSphinxController = [PocketsphinxController new];
        _pocketSphinxController.outputAudio = YES;
    }
}

- (void)createSlt {
    if (!_slt) {
        _slt = [Slt new];
    }
}

- (void)createFLiteController {
    if (!_fliteController) {
        _fliteController = [FliteController new];
    }
}

- (void)createCommandsArrayAndStartListening {
    NSArray *commandsArray = [NSArray arrayWithObjects:@"RED", @"BLUE", @"GREEN", @"YELLOW", nil];
    
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    
	NSError *error = [languageModelGenerator generateLanguageModelFromArray:commandsArray
                                                             withFilesNamed:@"FirstOpenEarsDynamicLanguageModel"
                                                     forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    NSDictionary *dynamicLanguageGenerationResultsDictionary = nil;
	if([error code] == noErr) {
		dynamicLanguageGenerationResultsDictionary = [error userInfo];
		
		NSString *lmPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMPath"];
		NSString *dictionaryPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryPath"];
        
        [_pocketSphinxController startListeningWithLanguageModelAtPath:lmPath
                                                      dictionaryAtPath:dictionaryPath
                                                   acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]
                                                   languageModelIsJSGF:NO];
	}
}


#pragma mark - OpenEarsEventsObserverDelegate

- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                        recognitionScore:(NSString *)recognitionScore
                             utteranceID:(NSString *)utteranceID {
    if ([hypothesis isEqualToString:@"RED"]) {
        [self redButtonAction:nil];
    } else if ([hypothesis isEqualToString:@"BLUE"]) {
        [self blueButtonAction:nil];
    } else if ([hypothesis isEqualToString:@"GREEN"]) {
        [self greenButtonAction:nil];
    } else if ([hypothesis isEqualToString:@"YELLOW"]) {
        [self yellowButtonAction:nil];
    } else {
        [_fliteController say:[NSString stringWithFormat:@"Unknown command %@", hypothesis]
                    withVoice:_slt];
    }
}


#pragma mark - Button Actions

- (IBAction)redButtonAction:(id)sender {
    self.view.backgroundColor = [UIColor redColor];
}

- (IBAction)blueButtonAction:(id)sender {
    self.view.backgroundColor = [UIColor blueColor];
}

- (IBAction)greenButtonAction:(id)sender {
    self.view.backgroundColor = [UIColor greenColor];
}

- (IBAction)yellowButtonAction:(id)sender {
    self.view.backgroundColor = [UIColor yellowColor];
}


#pragma mark - Dealloc

- (void)dealloc {
    _eventsObserver.delegate = nil;
}


@end
