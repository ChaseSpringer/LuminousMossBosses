//
//  SyncedObsVCTableViewController.m
//  DeveloperBuild
//
//  Created by Jacob Rail on 3/18/15.
//  Copyright (c) 2015 CU Boulder. All rights reserved.
//

#import "SyncedObsTVC.h"
#import "ObsDetailViewController.h"
#import "IdentifyingAssets.h"

@interface SyncedObsTVC ()
- (void)getAllSyncedObs;
@end

@implementation SyncedObsTVC{
	NSMutableArray *syncedObservations;
}

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	//	syncedObservations = [NSMutableArray arrayWithArray:[[UserDataDatabase getSharedInstance] findObservationsByStatus:@"synced" like:NO orderBy:@"datetime DESC"]];
	
	[self getAllSyncedObs];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
	[[IdentifyingAssets getSharedInstance] addObserver:self forKeyPath:@"currentSyncCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
	[[IdentifyingAssets getSharedInstance] removeObserver:self forKeyPath:@"currentSyncCount"];
}

- (void)viewDidAppear:(BOOL)animated{
	//[[self tableView] reloadData];
	
	[super viewDidAppear:animated];
}

- (void)getAllSyncedObs{
	syncedObservations = [NSMutableArray arrayWithArray:[[UserDataDatabase getSharedInstance] findObservationsByStatus:@"synced" like:NO orderBy:@"datetime DESC"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [syncedObservations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ObservationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ObservationCellSynced_ID" forIndexPath:indexPath];
    
    // Configure the cell...
	NSDictionary *plantInformation = [syncedObservations objectAtIndex:indexPath.row];
	NSURL *url = [NSURL URLWithString:[plantInformation objectForKey:@"imghexid"]];
	
	// determine if the image can be pulled.
	if ([url isEqual:@"(null)"]) {
		// If there is not image url, do not dispace a cell.
		return cell;
	}
	
	// get and set image
	ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
	
	[lib assetForURL:url resultBlock:^(ALAsset *asset) {
		ALAssetRepresentation *r = [asset defaultRepresentation];
        UIImageOrientation orientation = (UIImageOrientation) (int) r.orientation;
        cell.plantImageView.image = [UIImage imageWithCGImage:r.fullResolutionImage scale:r.scale orientation:orientation];
	} failureBlock:nil];
	
	// set text fields
	NSString *t = [plantInformation objectForKey:@"isSilene"];
	NSString *name;// = [NSString alloc];

	if ([t isEqualToString:@"yes"]) {
		name = @"Silene";
	}
	else {
		name = @"Unknown";
	}
	
	cell.nameLabel.text = name;//[plantInformation objectForKey:@"imghexid"];
	cell.dateLabel.text = [plantInformation objectForKey:@"datetime"];
	cell.percentLabel.text = [NSString stringWithFormat:@"%@%%", [plantInformation objectForKey:@"percentIDed"]];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Delete the row from the Database
		NSDictionary *obToRemove = [[NSDictionary alloc] initWithDictionary:[syncedObservations objectAtIndex:indexPath.row]];
		[[UserDataDatabase getSharedInstance] deleteObservationByID:[obToRemove objectForKey:@"imghexid"]];

		// Delete the row from the data source
		[syncedObservations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"MyObsSegue"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		ObsDetailViewController *destViewController = segue.destinationViewController;
		
		NSDictionary *selectedObservation;
		switch (indexPath.section) {
			case 0:
				selectedObservation = [syncedObservations objectAtIndex:indexPath.row];
				break;
			default:
				// show an alert here
				NSLog(@"ERROR, THIS LINE OF CODE SHOULD NEVER HIT <prepareForSegue ObsViewController.m>");
    break;
		}
		
		destViewController.plantInfo = selectedObservation;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if ([keyPath isEqualToString:@"currentSyncCount"]) {
		
		//long new = NSNumb[change valueForKey:@"new"];
		//long old = [change valueForKey:@"old"];

		[self getAllSyncedObs];
		[[self tableView] reloadData];
	}
	
}


@end
