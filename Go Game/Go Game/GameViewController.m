//
//  GameViewController.m
//  Go Game
//
//  Created by Hung Ga 123 on 5/24/16.
//  Copyright © 2016 HungVu. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@property (nonatomic, strong) Game *game;
@property (nonatomic) BOOL currentlyMarkingStonesAsDead;
@property (nonatomic, strong) NSTimer *gameClock;
@property int count;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setUserInteractionEnabled:YES];
    self.game = [[Game alloc] init];
    [self layoutInterface];
    [self startTimer];
    _count = 0;
}

#pragma mark - UIGestureRecognizers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int rowValue = 0;
    int columnValue = 0;
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self.view];
        rowValue = (int)floor(touchPoint.x / stoneSize);
        columnValue = (int)floor((touchPoint.y - GobanMiddleOffsetSize) / stoneSize);
    }
    
    if (self.currentlyMarkingStonesAsDead && [self.game isInBounds:rowValue andForColumnValue:columnValue]) {
        /*
         * Marking stones as dead
         */
        if([self.game.goban[rowValue][columnValue] isEqualToString:GobanBlackSpotString]) {
            [self.game markStoneClusterAsDeadFor:rowValue andForColumnValue:columnValue andForColor:GobanBlackSpotString];
        }
        else if([self.game.goban[rowValue][columnValue] isEqualToString:GobanWhiteSpotString]) {
            [self.game markStoneClusterAsDeadFor:rowValue andForColumnValue:columnValue andForColor:GobanWhiteSpotString];
        }
    }
    else if ([self.game isLegalMove:rowValue andForColumnValue:columnValue]) {
        if([self.game.turn isEqualToString:GobanBlackSpotString]) {
            [self playMoveAtRow:rowValue column:columnValue forColor:GobanBlackSpotString];
        }
        else {
            [self playMoveAtRow:rowValue column:columnValue forColor:GobanWhiteSpotString];
        }
    }
    
    [Goban printBoardToConsole:self.game.goban];
    _count++;
    if(_count == 18) {
        [self scoreGame];
        [self.view setUserInteractionEnabled:NO];
    }
}

#pragma mark - Board Drawing

- (void)drawNewMoveOnBoardForRow:(int)rowOfNewMove andColumn:(int)columnOfNewMove {
    CALayer *stoneLayer = [CALayer layer];
    if([self.game.goban[rowOfNewMove][columnOfNewMove] isEqualToString:GobanBlackSpotString]) {
        stoneLayer.frame = CGRectMake(rowOfNewMove * stoneSize,
                                      columnOfNewMove * stoneSize + GobanMiddleOffsetSize,
                                      stoneSize,
                                      stoneSize);
        stoneLayer.contents = (id)[UIImage imageNamed:GobanBlackStoneFileName].CGImage;
        [self.view.layer addSublayer:stoneLayer];
    }
    else if([self.game.goban[rowOfNewMove][columnOfNewMove] isEqualToString:GobanWhiteSpotString]) {
        stoneLayer.frame = CGRectMake(rowOfNewMove * stoneSize,
                                      columnOfNewMove * stoneSize + GobanMiddleOffsetSize,
                                      stoneSize,
                                      stoneSize);
        stoneLayer.contents = (id)[UIImage imageNamed:GobanWhiteStoneFileName].CGImage;
    }
    [self.view.layer addSublayer:stoneLayer];
}

- (void)drawAllMovesOnBoard {
    for(int i = 0 ;i < self.game.goban.count; i++) {
        for(int j = 0; j < self.game.goban.count; j++) {
            CALayer *stoneLayer = [CALayer layer];
            if([self.game.goban[j][i] isEqualToString:GobanBlackSpotString]) {
                stoneLayer.frame = CGRectMake(j * stoneSize,
                                              i * stoneSize + GobanMiddleOffsetSize,
                                              stoneSize,
                                              stoneSize);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanBlackStoneFileName].CGImage;
            }
            else if([self.game.goban[j][i] isEqualToString:GobanWhiteSpotString]) {
                stoneLayer.frame = CGRectMake(j * stoneSize,
                                              i * stoneSize + GobanMiddleOffsetSize,
                                              stoneSize,
                                              stoneSize);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanWhiteStoneFileName].CGImage;
            }
            else if([self.game.goban[j][i] isEqualToString:@"w"]) {
                stoneLayer.frame = CGRectMake(j * stoneSize,
                                              i * stoneSize + GobanMiddleOffsetSize,
                                              stoneSize,
                                              stoneSize);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanWhiteStoneFileName].CGImage;
                stoneLayer.opacity = 0.5;
            }
            else if([self.game.goban[j][i] isEqualToString:@"b"]) {
                stoneLayer.frame = CGRectMake(j * stoneSize,
                                              i * stoneSize + GobanMiddleOffsetSize,
                                              stoneSize,
                                              stoneSize);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanBlackStoneFileName].CGImage;
                stoneLayer.opacity = 0.5;
            }
            else if([self.game.goban[j][i] isEqualToString:@"Wp"]) {
                stoneLayer.frame = CGRectMake(j * stoneSize + (stoneSize / 4),
                                              i * stoneSize + (stoneSize / 4) + GobanMiddleOffsetSize, stoneSize / 2,stoneSize / 2);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanWhiteStoneFileName].CGImage;
            }
            else if([self.game.goban[j][i] isEqualToString:@"Bp"]) {
                stoneLayer.frame = CGRectMake(j * stoneSize + stoneSize / 4,
                                              i * stoneSize + (stoneSize / 4) + GobanMiddleOffsetSize,
                                              stoneSize / 2,
                                              stoneSize/2);
                stoneLayer.contents = (id)[UIImage imageNamed:GobanBlackStoneFileName].CGImage;
            }
            [self.view.layer addSublayer:stoneLayer];
        }
    }
}


- (void)playMoveAtRow:(int)row column:(int)column forColor:(NSString *)color {
    [self.game playMoveAtRow:row column:column forColor:color];
    [self drawBoardForNewMove:row andColumn:column];
    if ([color isEqualToString:GobanBlackSpotString]) {
        self.blackCapturedStoneCountLabel.text = [NSString stringWithFormat:@"%ld", self.game.capturedWhiteStones];
    }
    else if ([color isEqualToString:GobanWhiteSpotString]) {
        self.whiteCapturedStoneCountLabel.text = [NSString stringWithFormat:@"%ld", self.game.capturedBlackStones];
    }
}

- (void)drawBoard {
    CALayer *boardLayer = [CALayer layer];
    boardLayer.frame = CGRectMake(0, GobanMiddleOffsetSize, 414, 414);
    boardLayer.contents = (id) [UIImage imageNamed:GobanBoardImageFileName].CGImage;
    [self.view.layer addSublayer:boardLayer];
}

- (void)drawBoardForNewMove:(int)rowOfNewMove andColumn:(int)columnOfNewMove {
    if(!self.game.redrawBoardNeeded) {
        [self drawNewMoveOnBoardForRow:rowOfNewMove andColumn:columnOfNewMove];
    }
    else {
        [self drawBoard];
        [self drawAllMovesOnBoard];
        self.game.redrawBoardNeeded = NO;
    }
}

- (void)layoutInterface {
    // Add the main view image
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor blackColor].CGColor;
    sublayer.frame = CGRectMake(0,GobanMiddleOffsetSize,414,414);
    sublayer.contents = (id) [UIImage imageNamed:GobanBoardImageFileName].CGImage;
    [self.view.layer addSublayer:sublayer];
    
    // Set the label colors
    self.blackCapturedStoneCountLabel.textColor = [UIColor blackColor];
    self.whiteCapturedStoneCountLabel.textColor = [UIColor blackColor];
    
    //rotate labels in 180 degrees
    self.whiteCapturedStoneCountLabel.transform = CGAffineTransformMakeRotation(M_PI);
}

#pragma mark - Game Scorings
-(void)scoreGame {
    NSLog(@"Scoring game");
    int points = 0;
    NSMutableArray *emptySpaces = [[NSMutableArray alloc] init];
    NSString *addingPointsFor = [[NSMutableString alloc] init];

    //Turn off mark stones as dead
    [self setCurrentlyMarkingStonesAsDead:NO];
    
    for(int i = 0 ; i < self.game.goban.count; i++) {
        for(int j = 0; j< self.game.goban.count; j++) {
            if([self.game.goban[j][i] isEqualToString:GobanEmptySpotString] ||
               [self.game.goban[j][i] isEqualToString:@"w"] ||
               [self.game.goban[j][i] isEqualToString:@"b"]) {
                if([addingPointsFor isEqualToString:GobanBlackSpotString]) {
                    //Mark the locations to draw half-stones for black at this position
                    self.game.goban[j][i] = @"Bp";
                    [self.game setBlackStones:(self.game.blackStones+1)];
                }
                else if([addingPointsFor isEqualToString:GobanWhiteSpotString]) {
                    //Just draw a half-stone for white at this position
                    self.game.goban[j][i] = @"Wp";
                    [self.game setWhiteStones:(self.game.whiteStones+1)];
                }
                else {
                    Stone *emptySpace = [[Stone alloc] initWithWithRow:j column:i];
                    [emptySpaces addObject:emptySpace];
                    points++;
                }
            }
            else if([self.game.goban[j][i] isEqualToString:GobanBlackSpotString])
            {
                //Marking any free spaces as black's points
                if(points > 0)
                {
                    //NSLog(@"Points need accounting for (black)");
                    while([emptySpaces count] > 0)
                    {
                        Stone *emptySpace = emptySpaces[0];
                        self.game.goban[emptySpace.row][emptySpace.column] = @"Bp";
                        [emptySpaces removeObjectAtIndex:0];
                    }
                }
                addingPointsFor = GobanBlackSpotString;
                [self.game setBlackStones:(self.game.blackStones+points+1)];
                points = 0;
            }
            else if([self.game.goban[j][i] isEqualToString:GobanWhiteSpotString])
            {
                //Marking any free spaces as white's points
                if(points > 0)
                {
                    // NSLog(@"Points need accounting for (white)");
                    while([emptySpaces count] > 0)
                    {
                        Stone *emptySpace = emptySpaces[0];
                        self.game.goban[emptySpace.row][emptySpace.column] = @"Wp";
                        [emptySpaces removeObjectAtIndex:0];
                    }
                }
                addingPointsFor = GobanWhiteSpotString;
                [self.game setWhiteStones:(self.game.whiteStones+points+1)];
                points = 0;
            }
        }
        addingPointsFor = @"Nobody";
    }
    
    //Redraw the board ot show the scored points
    [self.game setRedrawBoardNeeded:YES];
    [self drawBoardForNewMove:0 andColumn:0];
    
    //Convert both to floats and add the komi value to white
    double blackScore = (double)self.game.blackStones + (double)self.game.capturedWhiteStones;
    double whiteScore = (double)self.game.whiteStones + (double)self.game.capturedBlackStones + self.game.komi;
    
    NSString *pointTally = [NSString stringWithFormat:@"Black: %d points + %ld captures = %.1f\nWhite: %d points + %ld captures + %.1f komi = %.1f", self.game.blackStones, self.game.capturedWhiteStones, blackScore, self.game.whiteStones, self.game.capturedBlackStones, self.game.komi, whiteScore];
    
    NSString *title = nil;
    NSString *cancelButtonTitle = @"OK";
    if(blackScore > whiteScore) {
        title = @"Black wins!";
    }
    else if(whiteScore > blackScore) {
        title = @"White wins!";
    }
    else {
        title = @"Tie?";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:pointTally
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:@"Play Again ?",nil];
    
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {

    }
    if(buttonIndex == 1) {
        [self viewDidLoad];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Clock

- (void) startTimer {
    self.gameClock = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                    selector:@selector(timerCallback)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)timerCallback {
    NSMutableString *result = [NSMutableString string];
    int iMinutes = 25;
    int iSeconds = 0;
    if([self.game.turn isEqualToString:GobanBlackSpotString]) {
        iMinutes = [[self.blackRemainingTimeLabel.text substringToIndex:2] intValue];
        iSeconds = [[self.blackRemainingTimeLabel.text substringFromIndex:3] intValue];
        if(iMinutes < 0) {
            [self timeUp];
        }
        else if(iSeconds <= 0) {
            iMinutes--;
            iSeconds = 59;
        }
        else {
            iSeconds--;
        }
        
        if(iMinutes < 0) {
            [self.gameClock invalidate];
            self.gameClock = nil;
            [self timeUp];
        }
        else {
            result = [NSMutableString stringWithFormat:@"%.2d:%.2d",iMinutes,iSeconds];
            self.blackRemainingTimeLabel.text = result;
        }
    }
    else if([self.game.turn isEqualToString:GobanWhiteSpotString]) {
        iMinutes = [[self.whiteRemainingTimeLabel.text substringToIndex:2] intValue];
        iSeconds = [[self.whiteRemainingTimeLabel.text substringFromIndex:3] intValue];
        if(iSeconds <= 0) {
            iMinutes--;
            iSeconds = 59;
        }
        else {
            iSeconds--;
        }
        
        if(iMinutes < 0) {
            [self.gameClock invalidate];
            self.gameClock = nil;
            [self timeUp];
        }
        else {
            result = [NSMutableString stringWithFormat:@"%.2d:%.2d",iMinutes,iSeconds];
            self.whiteRemainingTimeLabel.text = result;
        }
    }
}

- (void)timeUp {
    NSString *title = nil;
    NSString *message = nil;
    NSString *cancelButtonTitle = @"OK";
    if([self.game.turn isEqualToString:GobanBlackSpotString]) {
        title = @"White Wins!";
        message = @"Black ran out of time!";
    }
    else {
        title = @"Black Wins!";
        message = @"White ran out of time!";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
