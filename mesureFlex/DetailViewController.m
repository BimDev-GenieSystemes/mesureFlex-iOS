//
//  DetailViewController.m
//  test
//
//  Created by Mohamed Mokrani on 29/03/2017.
//  Copyright © 2017 Mohamed Mokrani. All rights reserved.
//

#import "DetailViewController.h"
#import "Sector.h"
#import "SectorTableViewCell.h"
#import "FlexViewController.h"
#import "DumpViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "DetailsTableViewCell.h"
#import <CoreData/CoreData.h>

@interface DetailViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
{
    NSMutableArray<Sector*> *sectors;
    NSMutableArray<Sector*> *sectorsTOSEND;
    Sector *selectedSector;
    UIStoryboard *sb;
}
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        self.navigationController.topViewController.title = self.detailItem.CampFullName;
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view, typically from a nib.
    __weak __typeof__(self) wself = self;
    
    sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    wself.vc = (FlexViewController *)[sb instantiateViewControllerWithIdentifier:@"flexVC"];
    [self configureView];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor groupTableViewBackgroundColor];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"nodata.png"];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    
    NSString *text = @"Sélectionnez une campagne depuis la liste à gauche.";
    
    if (self.detailItem) {
        
        text = @"Aucun secteur trouver dans le projet sélectionné.";
        
    }
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Aucune Campagne sélectionnée";
    
    if (self.detailItem) {
        
        text = self.detailItem.CampFullName;
        
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 170;
    }
    
    else {
       return 88;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (sectors.count > 0)
        return sectors.count+1;
    else
        return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        DetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"details" forIndexPath:indexPath];
        cell.projetLabel.text = _detailItem.CampFullName;
        cell.clientLabel.text = _detailItem.CampCustomer;
        cell.siteLabel.text = _detailItem.CampSite;
        cell.positionLabel.text = _detailItem.CampPosNbr;
        cell.capacityLabel.text = _detailItem.CampTotalCount;
        
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataState" inManagedObjectContext:[self managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inventaire_id = %@",_detailItem.CampID];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *items = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        cell.pointageLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)items.count];
        
        return cell;
    }
    
    else {
        SectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.sectorName.text = [sectors objectAtIndex:indexPath.row-1].name;
        cell.historyButton.restorationIdentifier = [sectors objectAtIndex:indexPath.row-1].sector_id;
        [cell.historyButton addTarget:self action:@selector(historyAction:) forControlEvents:UIControlEventTouchDown];
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        
        return cell;
    }
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    //if ([delegate performSelector:@selector(managedObjectContext)]) {
    context = [delegate managedObjectContext];
    //}
    return context;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(Inventaire *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        NSLog(@"%@",newDetailItem.CampFullName);
        sectors = [[NSMutableArray<Sector*> alloc] init];
        sectors = [Sector selectSectorFromLocalDataStore:_detailItem.CampID];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        sectors=[sectors sortedArrayUsingDescriptors:@[sort]].copy;

        [self.tableView reloadData];
        // Update the view.
        [self configureView];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @autoreleasepool {
        
        if (indexPath.row > 0) {
            selectedSector = [sectors objectAtIndex:indexPath.row-1];
            //sectorsTOSEND = [[inventaires objectAtIndex:indexPath.section] getSectors];
            //[self performSegueWithIdentifier:@"flexView" sender:self];
            //if(!_vc)
            __weak __typeof__(self) wself = self;
            __weak __typeof__(FlexViewController*) vc = vc;
            vc = (FlexViewController *)[sb instantiateViewControllerWithIdentifier:@"flexVC"];
            vc.sector = selectedSector;
            vc.sectors = [[NSMutableArray<Sector*> alloc] init];
            vc.sectors = sectors;
            
            [wself presentViewController:vc animated:YES completion:nil];
        }
        
    }
    
    
}

-(void)historyAction:(UIButton*)sender
{
    //[MFLogger put:@"Historique click"];
    
    for (Sector *sector in [Sector selectSectorFromLocalDataStore:_detailItem.CampID]) {
        
        if ([sector.sector_id isEqualToString:sender.restorationIdentifier]) {
            selectedSector = sector;
            break;
        }
        
    }
    [self performSegueWithIdentifier:@"history" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"flexView"]) {
        
        FlexViewController *destination = (FlexViewController*) segue.destinationViewController;
        destination.sector = selectedSector;
        destination.sectors = [[NSMutableArray<Sector*> alloc] init];
        destination.sectors = sectors;
        
    }
    
    else if ([segue.identifier isEqualToString:@"history"]) {
        DumpViewController *destination = (DumpViewController*) [[segue destinationViewController] topViewController];
        destination.sector = selectedSector;
    }
    
}


@end
