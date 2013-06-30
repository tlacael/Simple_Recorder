//
//  RecSecondViewController.m
//  Recorder
//
//  Created by Tlacael on 6/29/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import "RecSecondViewController.h"

@interface RecSecondViewController ()

@end

@implementation RecSecondViewController

NSArray *tableData;

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
    NSLog(@"%@", filenames);
    return filenames;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    tableData = [self printFileNames];
    NSLog(@"table datadtadtat%@", tableData);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"My Title";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    tableData = [self printFileNames];
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    return cell;
}

@end
