//
//  LogViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 31/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "LogViewController.h"
#import "MFLogger.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text =[MFLogger get];
    [self setupFTP];
    
    CGPoint bottomOffset = CGPointMake(0, self.textView.contentSize.height - self.textView.bounds.size.height);
    [self.textView setContentOffset:bottomOffset animated:YES];
    // Do any additional setup after loading the view.
}

-(void) logFiles {
    
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:docsDirectory error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mfl'"];
    NSArray *onlyTXTs = [dirContents filteredArrayUsingPredicate:fltr];
    
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
    [self.uploadButton setEnabled:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CHARGEMENT ACCOMPLI"
                                                    message:@"le fichier a été bien uploader au serveur."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDownloadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    NSLog(@"requestsManager:didFailWritingFileAtPath:forRequest:error: \n %@", error);
    [MFLogger put:error.description];
    [self.uploadButton setEnabled:YES];
    [MFLogger put:error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERREUR"
                                                    message:@"Erreur lors de l'upload du fichier."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"requestsManager:didFailRequest:withError: \n %@", error);
    [self.uploadButton setEnabled:YES];
    [MFLogger put:error.description];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERREUR"
                                                    message:@"Erreur lors de l'upload du fichier."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (IBAction)pushAction:(id)sender {
    
    [self.uploadButton setEnabled:NO];
    [self logFiles];
}

- (IBAction)closeAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
