//
//  UploadViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "UploadViewController.h"
#import "FLAnimatedImage.h"
#import "GRUploadRequest.h"
#import "MFLogger.h"

@interface UploadViewController ()
{
    BOOL fileWAIT;
    NSMutableArray *files;
    NSMutableArray *times;
    NSArray *onlyTXTs;
}
@end

@implementation UploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MFLogger put:@"start push data files"];
    times = [[NSMutableArray alloc] init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
    _gifImage.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    
    fileWAIT = NO;
    [self setupFTP];
    //[self.requestsManager addRequestForListDirectoryAtPath:@"/"];
    //[self.requestsManager startProcessingRequests];
    [self pushFiles];
    }

-(void) pushFiles {
    
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:docsDirectory error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.DS'"];
    onlyTXTs = [dirContents filteredArrayUsingPredicate:fltr];
    NSDate *date  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDate = [dateFormatter stringFromDate:date];
    for (NSString *s in onlyTXTs) {
        [MFLogger put:s];
        
        NSString *timestamp = [NSString stringWithFormat:@"#%@.DS",newDate];
        [times addObject:timestamp];
        NSString *path = [NSString stringWithFormat:@"%@/%@",docsDirectory,s];
        NSString *newFName = [s stringByReplacingOccurrencesOfString:@".DS" withString:timestamp];
        [self.requestsManager addRequestForUploadFileAtLocalPath:path toRemotePath:[NSString stringWithFormat:@"EXCHANGE/%@",newFName]];
    }
    [self.requestsManager startProcessingRequests];
    
    
}

-(void) logFiles {
    
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:docsDirectory error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mfl'"];
    onlyTXTs = [dirContents filteredArrayUsingPredicate:fltr];
    
    for (NSString *s in onlyTXTs) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",docsDirectory,s];
        
        [self.requestsManager addRequestForUploadFileAtLocalPath:path toRemotePath:[NSString stringWithFormat:@"EXCHANGE/%@",s]];
    }
    [self.requestsManager startProcessingRequests];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupFTP
{
    self.requestsManager = [[GRRequestsManager alloc] initWithHostname:@"geniesystemes.net"
                                                                  user:@"mflex"
                                                              password:@"MMokrani1"];
    self.requestsManager.delegate = self;
    
}


- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didScheduleRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didScheduleRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    NSLog(@"requestsManager:didCompleteListingRequest:listing: \n%@", listing);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteCreateDirectoryRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDeleteRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDeleteRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompletePercent:(float)percent forRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompletePercent:forRequest: %f", percent);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    GRUploadRequest *r = (GRUploadRequest*)request;
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [files addObject:r.localFilePath];
    if ([[r.localFilePath pathExtension] isEqualToString:@"DS"]) {
        [MFLogger put:r.localFilePath];
        [MFLogger put:@"file uploaded"];
        NSString *path = [r.localFilePath stringByReplacingOccurrencesOfString:@".DS" withString:[times objectAtIndex:0]];
        
        path = [path stringByReplacingOccurrencesOfString:@".DS" withString:@".PROCESS"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager fileExistsAtPath:path];
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager createFileAtPath:path contents:[@"DONE" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        }
        
        [self.requestsManager addRequestForUploadFileAtLocalPath:path toRemotePath:[NSString stringWithFormat:@"EXCHANGE/%@",[path stringByReplacingOccurrencesOfString:docsDirectory withString:@""]]];
        [self.requestsManager startProcessingRequests];
        
    }
    
    NSLog(@"requestsManager:didCompleteUploadRequest:");

    
    if (_requestsManager.remainingRequests == 0) {
        
        [MFLogger put:@"data files sent to server"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CHARGEMENT ACCOMPLI"
                                                        message:@"le fichier a été bien uploader au serveur."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
    }
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDownloadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    [MFLogger put:error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERREUR"
                                                    message:@"Erreur lors de l'upload des fichiers."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"requestsManager:didFailRequest:withError: \n %@", error);
    [MFLogger put:error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERREUR"
                                                    message:@"Erreur lors de l'upload du fichier."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
