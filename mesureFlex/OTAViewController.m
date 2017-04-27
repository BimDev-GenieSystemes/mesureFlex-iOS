//
//  OTAViewController.m
//  mesureFlex
//
//  Created by Mohamed Mokrani on 14/12/2016.
//  Copyright © 2016 Mohamed Mokrani. All rights reserved.
//

#import "OTAViewController.h"
#import "FLAnimatedImage.h"
#import <CoreData/CoreData.h>
#import "WebServiceConfig.h"
#import <Google/Analytics.h>
#import "MFLogger.h"
#import <AFNetworking/AFNetworking.h>

@interface OTAViewController ()
{
    Parser *parser;
    NSMutableArray *inventaires;
    NSMutableArray *images;
    NSMutableArray *imagesDownloaded;
    NSMutableArray *pastilles;
    NSMutableArray <Sector*> *secs;
    BOOL firstCall,secondCall;
    NSString *webURL;
    NSString *parsingData;
}
@end

@implementation OTAViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:@"OTAViewController"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [MFLogger put:@"OTAViewController"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading" withExtension:@"gif"];
    _loadGif.animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    
    [self createWSObject];
    [self createParserObject];
    secs = [[NSMutableArray<Sector*> alloc] init];
    [_progressBar setProgress:0.0];
    _progessValue.text = @"0 %";
    NSMutableDictionary *parms = [[NSMutableDictionary alloc] init];
    firstCall = YES;
    secondCall = NO;
    [Sector deleteAllFromLocalDataStore];
    [Inventaire deleteAllFromLocalDataStore];
    [PlanFragment deleteAllFromLocalDataStore];
    [PastilleState deleteAllFromLocalDataStore];
    [MFLogger put:@"Delete local datas"];
    [self.webServiceManager GetInventaires:parms];
    //[NSThread detachNewThreadSelector:@selector(prog) toTarget:self withObject:nil];
}

- (void) prog {
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            [_progressBar setProgress:10.0/100.0];
            _progessValue.text = @"10 %";
            
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_progressBar setProgress:20.0/100.0];
            _progessValue.text = @"20 %";
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_progressBar setProgress:30.0/100.0];
            _progessValue.text = @"30 %";
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_progressBar setProgress:40.0/100.0];
            _progessValue.text = @"40 %";
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_progressBar setProgress:50.0/100.0];
            _progessValue.text = @"50 %";
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
        });
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
        });
    });
    
    [_progressBar setProgress:60.0/100.0];
    _progessValue.text = @"60 %";
    sleep(2);
    [_progressBar setProgress:70.0/100.0];
    _progessValue.text = @"70 %";
    sleep(2);
    [_progressBar setProgress:80.0/100.0];
    _progessValue.text = @"80 %";
    sleep(2);
    [_progressBar setProgress:90.0/100.0];
    _progessValue.text = @"90 %";
    sleep(2);
    [_progressBar setProgress:100.0/100.0];
    _progessValue.text = @"100 %";
    
}

- (void)createParserObject {
    parser = [[Parser alloc] init];
}

- (void)createWSObject {
    self.webServiceManager = [[WSMethodes alloc] init];
    self.webServiceManager.delegate = self;
}

- (void)errorReceived:(NSString *)cachedResponse FromUrlKey:(NSString *)urlKey {
    NSLog(@"%@ errrror", urlKey);
    [MFLogger put:@"error ws"];
}

- (void)dataReceived:(NSString *)data FromWSCallName:(NSString *)WSCallName {
    
    // Your code to run on the main queue/thread
    [MFLogger put:@"ws succes"];
    webURL = WSCallName;
    parsingData = data;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [NSThread detachNewThreadSelector:@selector(startTheBackgroundJob) toTarget:self withObject:nil];
        });
    });
    
    
}

- (void)startTheBackgroundJob {
    

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSString *data = parsingData;
            if ([webURL rangeOfString:@"/WSRV_GetCampaigns.php"].location!=NSNotFound) {
                inventaires = [parser.inventaireParser getInventairesListFromJsonString:data];
                [_progressBar setProgress:10.0/100.0];
                _progessValue.text = @"10 %";
                for (int i = 0; i < inventaires.count; i++) {
                    
                    [[inventaires objectAtIndex:i] insertIntoLocalDataStore];
                    NSArray *sectors = [[NSArray alloc] init];
                    sectors = [[[inventaires objectAtIndex:i] CampSectorNames] componentsSeparatedByString:@"#"].copy;
                    
                    for (int j = 0; j < sectors.count; j++) {
                        
                        if (![sectors[j] isEqualToString:@""]) {
                            
                            Sector *sector = [[Sector alloc] init];
                            sector.sector_id = sectors[j];
                            sector.name = sectors[j];
                            sector.inventaire_id = [[inventaires objectAtIndex:i] CampID];
                            sector.wpFile = [NSString stringWithFormat:@"http://mflex.geniesystemes.net/Uploads/CAM/%@/%@/%@.WP",sector.inventaire_id,sector.name,sector.name];
                            [sector insertIntoLocalDataStore];
                            [secs addObject:sector];
                            NSMutableDictionary *rus = [[NSMutableDictionary alloc] init];
                            NSString *url = [API_URL stringByAppendingString:@"/WSRV_GetCampSecImages.php?"];
                            url = [NSString stringWithFormat:@"%@CampID=%@&SectFullName=%@",url,[[inventaires objectAtIndex:i] CampID],sector.name];
                            NSString *encoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            encoded = [encoded stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:encoded parameters:rus error:nil];
                            
                            [MFLogger put:url];
                            
                            
                            
                            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                
                                images = [parser.imageParser getImagesListFromJsonString:operation.responseString];
                                imagesDownloaded = [[NSMutableArray alloc] init];
                                for (int k = 0; k < images.count; k++) {
                                    
                                    double width = 640;
                                    double height = 480;
                                    if(images.count >= 35) {
                                        width = width/1.5;
                                        height = height/1.5;
                                    }
                                    
                                    PlanFragment *img = [[PlanFragment alloc] init];
                                    
                                    img = [images objectAtIndex:k];
                                    img.sector_id = sector.sector_id;
                                    img.inv_id = [[inventaires objectAtIndex:i] CampID];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                        NSString *url = img.URL_PATH;
                                        url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
                                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                                        UIImage *m = [UIImage imageWithData:imageData];
                                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width,height), NO, 0.0);
                                        [m drawInRect:CGRectMake(0, 0,width,height)];
                                        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                                        UIGraphicsEndImageContext();
                                        [imagesDownloaded addObject:newImage];
                                        img.planFragmentData = imageData;
                                        img.planFragmentImage = [[UIImage alloc] initWithData:img.planFragmentData];
                                        
                                        [img insertIntoLocalDataStore];
                                    });
                                    
                                    //sleep(0.2);
                                    //[_progressBar setProgress:0.1+0.8*(((i+1.0)/inventaires.count)/100.0)];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                        [_progressBar setProgress:0.1+0.8*(((i+1.0)/inventaires.count)/100.0) animated:YES];
                                        int o = [NSNumber numberWithFloat:10+80*(((i+1.0)/inventaires.count))].intValue;
                                        _progessValue.text = [[NSString stringWithFormat:@"%d",o] stringByAppendingString:@" %"];
                                    });
                                    //[self performSelectorOnMainThread:@selector(setLoaderProgress:) withObject:[NSNumber numberWithFloat:0.1+0.8*(((i+1.0)/inventaires.count)/100.0)] waitUntilDone:NO];

                                    
                                    //_progessValue.text = [NSString stringWithFormat:@"%f%%",_progressBar.progress*100.0];
                                    
                                    
                                    
                                }
                                
                                
                                
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                
                                
                                
                            }];
                            
                            
                            [operation start];
                        }
                    }
                    
                    
                }
                
                
                    //[_progressBar setProgress:95.0/100.0  animated:YES];
                    //_progessValue.text = @"95 %";
                    firstCall = YES;
                    secondCall = YES;
                    [self.webServiceManager GetPastilles];
                    
            }
            
            else if ([webURL rangeOfString:[API_URL stringByAppendingString:@"/WSRV_GetUsagesDef.php"]].location!=NSNotFound) {
                
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    [_progressBar setProgress:98/100  animated:YES];
                    _progessValue.text = @"98 %";
                    
                });
                
                pastilles = [[NSMutableArray alloc] init];
                pastilles = [parser.pastilleParser getPastillesListFromJsonString:data];
                
                for (int i = 0; i< pastilles.count; i++) {
                    
                    PastilleState *pastille = [pastilles objectAtIndex:i];
                    [pastille insertIntoLocalDataStore];
                    
                }
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    [_progressBar setProgress:100/100 animated:YES];
                    _progessValue.text = @"100 %";
                    
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CloseModal" object:self];
                [self dismissViewControllerAnimated:YES completion:nil];
            }

        });
    });
    
    
}

- (void)setLoaderProgress:(NSNumber *)number
{
    [_progressBar setProgress:number.floatValue animated:YES];
    _progessValue.text =number.stringValue;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
