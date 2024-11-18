//
//  MNSAudio.m
//  wordPuzzle
//
//  Created by Michael Thomason on 11/3/09.
//  Copyright 2020 Michael Thomason. All rights reserved.
//

#import "MNSAudio.h"
#import "Constants.h"
#import "wordPuzzleAppDelegate.h"
#import "MTFileController.h"
#import "MNSUser.h"

static NSString *const kNSUserDefault = @"NSUserDefault";
static NSString *const kAllSongsDownloadedKey = @"AllSongsConsidered3";
static NSString *const kNSUserDefaultAllSet = @"NSUserDefaultAllSet";

static NSString *const kUIAudioLoopBlues = @"UIAudioLoopBlues.caf";
static NSString *const kUIAudioLoopBluesRift1 = @"UIAudioLoopBluesRift1.caf";
static NSString *const kUIAudioLoopBluesRift2 = @"UIAudioLoopBluesRift2.caf";
static NSString *const kUIAudioLoopBluesRift3 = @"UIAudioLoopBluesRift3.caf";
static NSString *const kUIAudioLoopBluesRift4 = @"UIAudioLoopBluesRift4.caf";

static NSString *const kUIAudioLoopTechno = @"UIAudioLoopTechno.caf";
static NSString *const kUIAudioLoopTechnoRift1 = @"UIAudioLoopTechnoRift1.caf";
static NSString *const kUIAudioLoopTechnoRift2 = @"UIAudioLoopTechnoRift2.caf";
static NSString *const kUIAudioLoopTechnoRift3 = @"UIAudioLoopTechnoRift3.caf";
static NSString *const kUIAudioLoopTechnoRift4 = @"UIAudioLoopTechnoRift4.caf";

static NSString *const kUIAudioLoopMystery = @"UIAudioLoopMystery.caf";
static NSString *const kUIAudioLoopMysteryRift1 = @"UIAudioLoopMysteryRift1.caf";
static NSString *const kUIAudioLoopMysteryRift2 = @"UIAudioLoopMysteryRift2.caf";
static NSString *const kUIAudioLoopMysteryRift3 = @"UIAudioLoopMysteryRift3.caf";
static NSString *const kUIAudioLoopMysteryRift4 = @"UIAudioLoopMysteryRift4.caf";

static NSString *const kUIAudioLoopSouthern = @"UIAudioLoopSouthern.caf";
static NSString *const kUIAudioLoopSouthernRift1 = @"UIAudioLoopSouthernRift1.caf";
static NSString *const kUIAudioLoopSouthernRift2 = @"UIAudioLoopSouthernRift2.caf";
static NSString *const kUIAudioLoopSouthernRift3 = @"UIAudioLoopSouthernRift3.caf";
static NSString *const kUIAudioLoopSouthernRift4 = @"UIAudioLoopSouthernRift4.caf";

@interface MNSAudio ()
	@property (nonatomic, retain) AVSpeechSynthesizer *speechSynthesizer;
@end

@implementation MNSAudio

#pragma mark AudioSession handlers
void RouteChangeListener(void *, AudioSessionPropertyID, UInt32, const void *);
void RouteChangeListener(void *inClientData, AudioSessionPropertyID	inID, UInt32 inDataSize, const void *inData) {
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		int reason = [reasonValue intValue];
		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {

		}
	}
}

- (void)dealloc {
	_speechSynthesizer = nil;
}

+ (void)downloadMusicFromUrl:(NSString *)url toFileName:(NSString *)filename withOperationQueue:(NSOperationQueue *)operationQueue {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *urlForFile = [MTFileController applicationSupportURLForFileName:filename];
	if (![fm isReadableFileAtPath: urlForFile.path]) {
		//NSError *error = nil;
		//[urlOfLoop setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];    //Add this line so loop isn't backed  up to iCloud
		//if (error) {
		//    NSLog(@"Error %@", [error localizedDescription]);
		//}

		NSURL *urlOfLoop = [[NSURL alloc] initWithString: url];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL: urlOfLoop];
		NSURLSession *session = [NSURLSession sharedSession];
		NSURLSessionDataTask *task = [session dataTaskWithRequest: request
												completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

			if (error != nil) {
				NSLog(@"Error %@: %@", error.localizedDescription, error.localizedFailureReason);
				//display error
			} else if (data == nil) {
				//NSLog(@"Could not download background music.  Will try again next time.  Why?!?!?!  Because, that's what we do!\n(%@, %@, %@, %@)", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
			} else {
				NSURL *fileUrl = [MTFileController applicationSupportURLForFileName:filename];
				if (![data writeToURL:fileUrl options:NSDataWritingAtomic error:&error]) {
					//NSLog(@"(%@, %@, %@, %@)\nTry Again!", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
					error = nil;
					if ([data writeToURL:fileUrl options:NSDataWritingAtomic error:&error]) {
						//good
						[self addSkipBackupAttributeToItemAtURL:fileUrl];
						NSString *key = [kNSUserDefault stringByAppendingString:filename.capitalizedString];
						[[NSUserDefaults standardUserDefaults] setBool: YES forKey: key];
						[[NSUserDefaults standardUserDefaults] synchronize];
					}
				} else {
					[self addSkipBackupAttributeToItemAtURL:fileUrl];
					NSString *key = [kNSUserDefault stringByAppendingString:filename.capitalizedString];
					[[NSUserDefaults standardUserDefaults] setBool: YES forKey: key];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
		}];
		[task resume];
		
		/*
		[NSURLConnection sendAsynchronousRequest: request
										   queue: operationQueue
							   completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
			if (error != nil || data == nil) {
				//NSLog(@"Could not download background music.  Will try again next time.  Why?!?!?!  Because, that's what we do!\n(%@, %@, %@, %@)", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
			} else {
				NSURL *fileUrl = [[MTFileController applicationSupportURLForFileName:filename] retain];
				if (![data writeToURL:fileUrl options:NSDataWritingAtomic error:&error]) {
					//NSLog(@"(%@, %@, %@, %@)\nTry Again!", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
					error = nil;
					if ([data writeToURL:fileUrl options:NSDataWritingAtomic error:&error]) {
						//good
						[self addSkipBackupAttributeToItemAtURL:fileUrl];
						[[NSUserDefaults standardUserDefaults] setBool: YES forKey: [kNSUserDefault stringByAppendingString:filename.capitalizedString]];
						[[NSUserDefaults standardUserDefaults] synchronize];
					}
				} else {
					[self addSkipBackupAttributeToItemAtURL:fileUrl];
					//good
					[[NSUserDefaults standardUserDefaults] setBool: YES forKey: [kNSUserDefault stringByAppendingString:filename.capitalizedString]];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
				[fileUrl autorelease];
			}
		}];
		[request release];
		[urlOfLoop release];
		*/
		
	} else {
		NSString *key = [kNSUserDefault stringByAppendingString:filename.capitalizedString];
		[[NSUserDefaults standardUserDefaults] setBool: YES
												forKey: key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
	assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
	
	NSError *error = nil;
	BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
								  forKey: NSURLIsExcludedFromBackupKey error: &error];
	//if(!success){
	//    NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
	//} else {
	//    NSLog(@"URL discarded from iCloud blackup without any error: %@", [URL lastPathComponent]);
	//}
	return success;
}

+ (void)downloadMusic {
	NSLog(@"[MNSAudio downloadMusic] is removed.");
}

+ (void)downloadMusicOld {
	NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount: 1];

	dispatch_queue_t queuePriorityBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

	if (![[NSUserDefaults standardUserDefaults] boolForKey: kAllSongsDownloadedKey]) {

		BOOL songSouthernDownloaded = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefaultAllSet stringByAppendingString: kUIAudioLoopSouthern.capitalizedString]];
		BOOL songBluesDownloaded = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefaultAllSet stringByAppendingString: kUIAudioLoopBlues.capitalizedString]];
		BOOL songTechnoDownloaded = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefaultAllSet stringByAppendingString: kUIAudioLoopTechno.capitalizedString]];

		if (songSouthernDownloaded && songBluesDownloaded && songTechnoDownloaded /*&& songWFLoopDownloaded && songMysteryDownloaded*/) {
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAllSongsDownloadedKey];
		} else {

			if (!songSouthernDownloaded) {
				dispatch_async(queuePriorityBackground, ^{
					
					BOOL fileDownloaded1 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:kUIAudioLoopSouthernRift4.capitalizedString]];
					BOOL fileDownloaded2 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:kUIAudioLoopSouthernRift3.capitalizedString]];
					BOOL fileDownloaded3 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:kUIAudioLoopSouthernRift2.capitalizedString]];
					BOOL fileDownloaded4 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:kUIAudioLoopSouthernRift1.capitalizedString]];
					BOOL fileDownloaded5 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:kUIAudioLoopSouthern.capitalizedString]];

					if (fileDownloaded1 && fileDownloaded2 && fileDownloaded3 && fileDownloaded4 && fileDownloaded5) {
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey: [kNSUserDefaultAllSet stringByAppendingString:[kUIAudioLoopSouthern capitalizedString]]];
					} else {

						if (!fileDownloaded1) {
#warning Dead URL
							NSString *kUIAudioLoopSouthernRift4Url = @"http://files.example.com/loops/UIAudioLoopSouthernRift4.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopSouthernRift4Url
												toFileName: kUIAudioLoopSouthernRift4
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded2) {
#warning Dead URL
							NSString *kUIAudioLoopSouthernRift3Url = @"http://files.example.com/loops/UIAudioLoopSouthernRift3.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopSouthernRift3Url
												toFileName: kUIAudioLoopSouthernRift3
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded3) {
#warning Dead URL
							NSString *kUIAudioLoopSouthernRift2Url = @"http://files.example.com/loops/UIAudioLoopSouthernRift2.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopSouthernRift2Url
												toFileName: kUIAudioLoopSouthernRift2
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded4) {
#warning Dead URL
							NSString *kUIAudioLoopSouthernRift1Url = @"http://files.example.com/loops/UIAudioLoopSouthernRift1.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopSouthernRift1Url
												toFileName: kUIAudioLoopSouthernRift1
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded5) {
#warning Dead URL
							NSString *kUIAudioLoopSouthernUrl = @"http://files.example.com/loops/UIAudioLoopSouthern.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopSouthernUrl
												toFileName: kUIAudioLoopSouthern
										withOperationQueue: operationQueue];
						}
					}

				});
			}

			if (!songBluesDownloaded) {
				dispatch_async(queuePriorityBackground, ^{
					BOOL fileDownloaded1 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString: kUIAudioLoopBluesRift4.capitalizedString]];
					BOOL fileDownloaded2 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString: kUIAudioLoopBluesRift3.capitalizedString]];
					BOOL fileDownloaded3 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString: kUIAudioLoopBluesRift2.capitalizedString]];
					BOOL fileDownloaded4 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString: kUIAudioLoopBluesRift1.capitalizedString]];
					BOOL fileDownloaded5 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString: kUIAudioLoopBlues.capitalizedString]];
					if (fileDownloaded1 && fileDownloaded2 && fileDownloaded3 && fileDownloaded4 && fileDownloaded5) {
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kNSUserDefaultAllSet stringByAppendingString:[kUIAudioLoopBlues capitalizedString]]];
					} else {
						if (!fileDownloaded1) {
#warning Dead URL
							NSString *kUIAudioLoopBluesRift4Url = @"http://files.example.com/loops/UIAudioLoopBluesRift4.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopBluesRift4Url
												toFileName: kUIAudioLoopBluesRift4
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded2) {
#warning Dead URL
							NSString *kUIAudioLoopBluesRift3Url = @"http://files.example.com/loops/UIAudioLoopBluesRift3.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopBluesRift3Url
												toFileName: kUIAudioLoopBluesRift3
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded3) {
#warning Dead URL
							NSString *kUIAudioLoopBluesRift2Url = @"http://files.example.com/loops/UIAudioLoopBluesRift2.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopBluesRift2Url
												toFileName: kUIAudioLoopBluesRift2
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded4) {
#warning Dead URL
							NSString *kUIAudioLoopBluesRift1Url = @"http://files.example.com/loops/UIAudioLoopBluesRift1.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopBluesRift1Url
												toFileName: kUIAudioLoopBluesRift1
										withOperationQueue: operationQueue];
						}
						if (!fileDownloaded5) {
#warning Dead URL
							NSString *kUIAudioLoopBluesUrl = @"http://files.example.com/loops/UIAudioLoopBlues.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopBluesUrl
												toFileName: kUIAudioLoopBlues
										withOperationQueue: operationQueue];
						}
					}
				});
			}

			if (!songTechnoDownloaded) {
				dispatch_async(queuePriorityBackground, ^{
					BOOL fileDownloaded1 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:[kUIAudioLoopTechnoRift4 capitalizedString]]];
					BOOL fileDownloaded2 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:[kUIAudioLoopTechnoRift3 capitalizedString]]];
					BOOL fileDownloaded3 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:[kUIAudioLoopTechnoRift2 capitalizedString]]];
					BOOL fileDownloaded4 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:[kUIAudioLoopTechnoRift1 capitalizedString]]];
					BOOL fileDownloaded5 = [[NSUserDefaults standardUserDefaults] boolForKey:[kNSUserDefault stringByAppendingString:[kUIAudioLoopTechno capitalizedString]]];
					if (fileDownloaded1 && fileDownloaded2 && fileDownloaded3 && fileDownloaded4 && fileDownloaded5) {
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kNSUserDefaultAllSet stringByAppendingString:[kUIAudioLoopTechno capitalizedString]]];
					} else {
#warning Dead URLs
						if (!fileDownloaded1) {
							NSString *kUIAudioLoopTechnoRift4Url = @"http://files.example.com/loops/UIAudioLoopTechnoRift4.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopTechnoRift4Url
												toFileName: kUIAudioLoopTechnoRift4
										withOperationQueue: operationQueue];
						}
#warning Dead URLs
						if (!fileDownloaded2) {
							NSString *kUIAudioLoopTechnoRift3Url = @"http://files.example.com/loops/UIAudioLoopTechnoRift3.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopTechnoRift3Url
												toFileName: kUIAudioLoopTechnoRift3
										withOperationQueue: operationQueue];
						}
#warning Dead URLs
						if (!fileDownloaded3) {
							NSString *kUIAudioLoopTechnoRift2Url = @"http://files.example.com/loops/UIAudioLoopTechnoRift2.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopTechnoRift2Url
												toFileName: kUIAudioLoopTechnoRift2
										withOperationQueue: operationQueue];
						}
#warning Dead URLs
						if (!fileDownloaded4) {
							NSString *kUIAudioLoopTechnoRift1Url = @"http://files.example.com/loops/UIAudioLoopTechnoRift1.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopTechnoRift1Url
												toFileName: kUIAudioLoopTechnoRift1
										withOperationQueue: operationQueue];
						}
#warning Dead URLs
						if (!fileDownloaded5) {
							NSString *kUIAudioLoopTechnoUrl = @"http://files.example.com/loops/UIAudioLoopTechno.caf";
							[MNSAudio downloadMusicFromUrl: kUIAudioLoopTechnoUrl
												toFileName: kUIAudioLoopTechno
										withOperationQueue: operationQueue];
						}
					}
				});
			}
		}
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
}

static void CreateSystemSoundIDFromFile(CFStringRef filename, SystemSoundID *sound) {
	CFURLRef url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), filename, CFSTR("caf"), CFSTR("Alerts"));
	AudioServicesCreateSystemSoundID(url, sound);
	CFRelease(url);
}

- (instancetype)init {
	if (self = [super init]) {
		
	}
	return self;
}

- (AVSpeechSynthesizer *)speechSynthesizer {
	if (_speechSynthesizer == nil) {
		_speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
	}
	return _speechSynthesizer;
}

- (void)playWelcome {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	[self.speechSynthesizer speakUtterance:
	 [AVSpeechUtterance speechUtteranceWithString:@"Welcome"]
	 ];
}

- (void)playTimeIsUp {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Time is up.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}

- (void)playThreeMinutes {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Three minutes remaining.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}

- (void)playTwoMinutes {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Two minutes remaining.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}
- (void)playOneMinute {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"One minutes remaining.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}
- (void)playThirtySeconds {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Thirty seconds remaining.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}
- (void)playFifteenSeconds {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Fifteen seconds remaining.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}
- (void)playGameOver {
	if (![MNSUser CurrentUser].desiresSoundEffects) return;
	NSString *script = @"Game is over.";
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:script];
	[self.speechSynthesizer speakUtterance:utterance];
}

+ (void)playAchievement {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayAchievement;
		if (_ssidPlayAchievement <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("UIAudioAchievement"), &_ssidPlayAchievement);
		}
		AudioServicesPlaySystemSound(_ssidPlayAchievement);
	}
}


+ (void)playAchievement1 { [self playAchievement]; }
+ (void)playAchievement2 { [self playAchievement]; }
+ (void)playAchievement3 { [self playAchievement]; }
+ (void)playAchievement4 { [self playAchievement]; }

+ (void)playSwapTiles {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlaySwapTiles;
		if (_ssidPlaySwapTiles <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("SwapTiles"), &_ssidPlaySwapTiles);
		}
		AudioServicesPlaySystemSound(_ssidPlaySwapTiles);
	}
}

+ (void)playFlipTileEnd {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayFlipTileEnd;
		if (_ssidPlayFlipTileEnd <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("FlipTileEnd"), &_ssidPlayFlipTileEnd);
		}
		AudioServicesPlaySystemSound(_ssidPlayFlipTileEnd);
	}
}
+ (void)playFlipTileFlip {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayFlipTileFlip;
		if (_ssidPlayFlipTileFlip <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("FlipTileFlip"), &_ssidPlayFlipTileFlip);
		}
		AudioServicesPlaySystemSound(_ssidPlayFlipTileFlip);
	}
}

+ (void)playBonusCoins {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusCoins;
		if (_ssidPlayBonusCoins <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusCoins"), &_ssidPlayBonusCoins);
		}
		AudioServicesPlaySystemSound(_ssidPlayBonusCoins);
	}
}

+ (void)playCoinOne {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayCoinOne;
		if (_ssidPlayCoinOne <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("UIAudioCoinOne"), &_ssidPlayCoinOne);
		}
		AudioServicesPlaySystemSound(_ssidPlayCoinOne);
	}
}

+ (void)playCoinShower {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayCoinShower;
		if (_ssidPlayCoinShower <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("UIAudioCoinShower"), &_ssidPlayCoinShower);
		}
		AudioServicesPlaySystemSound(_ssidPlayCoinShower);
	}
}

+ (void)playBonusSaucer {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusSaucer;
		if (_ssidPlayBonusSaucer <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusSaucer"), &_ssidPlayBonusSaucer);
		}
		AudioServicesPlaySystemSound(_ssidPlayBonusSaucer);
	}
}
+ (void)playBonusLife {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusLife;
		if (_ssidPlayBonusLife <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusLife"), &_ssidPlayBonusLife);
		}
		AudioServicesPlaySystemSound(_ssidPlayBonusLife);
	}
}
+ (void)playBonusThunder {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusThunder;
		if (_ssidPlayBonusThunder <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusThunder"), &_ssidPlayBonusThunder);
		}
		AudioServicesPlaySystemSound(_ssidPlayBonusThunder);
	}
}

+ (void)playTileHitWood1 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTileHitWood1;
		if (_ssidPlayTileHitWood1 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("WoodTileHit1"), &_ssidPlayTileHitWood1);
		}
		AudioServicesPlaySystemSound(_ssidPlayTileHitWood1);
	}
}

+ (void)playTileHitWood2 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTileHitWood2;
		if (_ssidPlayTileHitWood2 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("WoodTileHit2"), &_ssidPlayTileHitWood2);
		}
		AudioServicesPlaySystemSound(_ssidPlayTileHitWood2);
	}
}

+ (void)playTileHit1 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTileHit1;
		if (_ssidPlayTileHit1 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TileHit1"), &_ssidPlayTileHit1);
		}
		AudioServicesPlaySystemSound(_ssidPlayTileHit1);
	}
}

+ (void)playTileHit2 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTileHit2;
		if (_ssidPlayTileHit2 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TileHit2"), &_ssidPlayTileHit2);
		}
		AudioServicesPlaySystemSound(_ssidPlayTileHit2);
	}
}

+ (void)playTileHit3 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTileHit3;
		if (_ssidPlayTileHit3 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TileHit3"), &_ssidPlayTileHit3);
		}
		AudioServicesPlaySystemSound(_ssidPlayTileHit3);
	}
}

+ (void)playPickupHealth1 {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayPickupHealth1;
		if (_ssidPlayPickupHealth1 <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("PickupHealth1"), &_ssidPlayPickupHealth1);
		}
		AudioServicesPlaySystemSound(_ssidPlayPickupHealth1);
	}
}

+ (void)playPickupJewel {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayPickupJewel;
		if (_ssidPlayPickupJewel <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("PickupJewel"), &_ssidPlayPickupJewel);
		}
		AudioServicesPlaySystemSound(_ssidPlayPickupJewel);
	}
}

+ (void)playPickupMagic {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayPickupMagic;
		if (_ssidPlayPickupMagic <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("PickupMagic"), &_ssidPlayPickupMagic);
		}
		AudioServicesPlaySystemSound(_ssidPlayPickupMagic);
	}
}

+ (void)playPickupMetallic {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayPickupMetallic;
		if (_ssidPlayPickupMetallic <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("PickupMetallic"), &_ssidPlayPickupMetallic);
		}
		AudioServicesPlaySystemSound(_ssidPlayPickupMetallic);
	}
}

+ (void)playSlideSoft {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlaySlideSoft;
		if (_ssidPlaySlideSoft <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("GamePieceSlide"), &_ssidPlaySlideSoft);
		}
		AudioServicesPlaySystemSound (_ssidPlaySlideSoft);
	}
}

+ (void)playMouseMarble {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayMouseMarble;
		if (_ssidPlayMouseMarble <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("MouseMarble"), &_ssidPlayMouseMarble);
		}
		AudioServicesPlaySystemSound (_ssidPlayMouseMarble);
	}
}

+ (void)playChimesNeg {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayChimesNeg;
		if (_ssidPlayChimesNeg <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("ChimesNeg"), &_ssidPlayChimesNeg);
		}
		AudioServicesPlaySystemSound (_ssidPlayChimesNeg);
	}
}

+ (void)playChimesNo {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayChimesNo;
		if (_ssidPlayChimesNo <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("ChimesNo"), &_ssidPlayChimesNo);
		}
		AudioServicesPlaySystemSound (_ssidPlayChimesNo);
	}
}

+ (void)playChimesPos {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayChimesPos;
		if (_ssidPlayChimesPos <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("ChimesPos"), &_ssidPlayChimesPos);
		}
		AudioServicesPlaySystemSound (_ssidPlayChimesPos);
	}
}

+ (void)playBonusBeep {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusBeep;
		if (_ssidPlayBonusBeep <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusBeep"), &_ssidPlayBonusBeep);
		}
		AudioServicesPlaySystemSound (_ssidPlayBonusBeep);
	}
}

+ (void)playBonusBell {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayBonusBell;
		if (_ssidPlayBonusBell <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BonusBell"), &_ssidPlayBonusBell);
		}
		AudioServicesPlaySystemSound (_ssidPlayBonusBell);
	}
}

+ (void)playTimeTickClock {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTimeTickClock;
		if (_ssidPlayTimeTickClock <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TimeTickClock"), &_ssidPlayTimeTickClock);
		}
		AudioServicesPlaySystemSound (_ssidPlayTimeTickClock);
	}
}

+ (void)playTimeTickHeartbeat {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayTimeTickHeartbeat;
		if (_ssidPlayTimeTickHeartbeat <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TimeTickHeartbeat"), &_ssidPlayTimeTickHeartbeat);
		}
		AudioServicesPlaySystemSound (_ssidPlayTimeTickHeartbeat);
	}
}

+ (void)playShuffle {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayShuffle;
		if (_ssidPlayShuffle <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("TapeMeasureIn"), &_ssidPlayShuffle);
		}
		AudioServicesPlaySystemSound (_ssidPlayShuffle);
	}
}

+ (void)playShelfHide {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayShelfHide;
		if (_ssidPlayShelfHide <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("SlideBrush"), &_ssidPlayShelfHide);
		}
		AudioServicesPlaySystemSound(_ssidPlayShelfHide);
	}
}

+ (void)playButtonPress {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayButtonPress;
		if (_ssidPlayButtonPress <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BleepBlopLo"), &_ssidPlayButtonPress);
		}
		AudioServicesPlaySystemSound(_ssidPlayButtonPress);
	}
}

+ (void)playButtonPressConfirm {
	if ([MNSUser CurrentUser].desiresSoundEffects) {
		static SystemSoundID _ssidPlayButtonPressConfirm;
		if (_ssidPlayButtonPressConfirm <= 0) {
			CreateSystemSoundIDFromFile(CFSTR("BleepConfirm"), &_ssidPlayButtonPressConfirm);
		}
		AudioServicesPlaySystemSound(_ssidPlayButtonPressConfirm);
	}
}

@end
