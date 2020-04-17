#import "PerfectBattery13.h"

#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

static HBPreferences *pref;
static BOOL enabled;
static long fontSize;
static BOOL boldFont;
static BOOL showPercentSymbol;
static BOOL customDefaultColorEnabled;
static UIColor *customDefaultColor;
static UIColor *chargingColor;
static UIColor *lowPowerModeColor;
static UIColor *lowBattery1Color;
static UIColor *lowBattery2Color;

static NSString *percentSymbol;

// Hide duplicate percentage label from control center
%hook _UIStatusBarStringView

- (void)setText: (NSString*)text
{
    if(![text containsString: @"%"]) %orig;
}

%end

// hide battery icon, show percentage label instead
%hook _UIBatteryView

%property (nonatomic, retain) UILabel *percentLabel;
%property (nonatomic, retain) UIColor *backupFillColor;

- (id)initWithFrame: (CGRect)frame
{
	self = %orig;
	
	[self setPercentLabel: [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 40, 12)]];
	if(boldFont) [[self percentLabel] setFont: [UIFont boldSystemFontOfSize: fontSize]];
	else [[self percentLabel] setFont: [UIFont systemFontOfSize: fontSize]];
	[[self percentLabel] setAdjustsFontSizeToFitWidth: YES];
	[[self percentLabel] setTextAlignment: NSTextAlignmentLeft];
	[[self percentLabel] setText: [NSString stringWithFormat:@"%.0f%@", floor(self.chargePercent * 100), percentSymbol]];
	[self addSubview: [self percentLabel]];

	return self;
}

- (void)setChargePercent: (CGFloat)percent
{
	%orig;    
	[[self percentLabel] setText: [NSString stringWithFormat:@"%.0f%@", floor(percent * 100), percentSymbol]];
}

// Update percentage label color in various events
%new
- (void)updatePercentageColor
{
	if([self chargingState] != 0) [[self percentLabel] setTextColor: chargingColor];
	else if([self saverModeActive]) [[self percentLabel] setTextColor: lowPowerModeColor];
	else if([self chargePercent] <= 0.15) [[self percentLabel] setTextColor: lowBattery2Color];
	else if([self chargePercent] <= 0.25) [[self percentLabel] setTextColor: lowBattery1Color];
	else if(customDefaultColorEnabled) [[self percentLabel] setTextColor: customDefaultColor];
	else [[self percentLabel] setTextColor: [self backupFillColor]];
}

- (void)setChargingState: (long long)arg1
{
	%orig;
	[self updatePercentageColor];
}

- (void)setSaverModeActive: (BOOL)arg1
{
	%orig;
	[self updatePercentageColor];
}

- (void)_updateFillLayer
{
	%orig;
	[self updatePercentageColor];
}

// Do not update any color automatically
- (void)_updateFillColor
{

}

- (void)_updateBodyColors
{

}

- (void)_updateBatteryFillColor
{

}

// Return clear fill color but keep a backup of it
- (void)setFillColor: (UIColor*)arg1
{
	[self setBackupFillColor: arg1];
	%orig([UIColor clearColor]);
}

- (UIColor*)fillColor
{
	return [UIColor clearColor];
}

// Hide body component completely
- (void)setBodyColor: (UIColor*)arg1
{
	%orig([UIColor clearColor]);
}

- (UIColor*)bodyColor
{
	return [UIColor clearColor];
}

// Hide pin component completely
- (void)setPinColor: (UIColor*)arg1
{
	%orig([UIColor clearColor]);
}

- (UIColor*)pinColor
{
	return [UIColor clearColor];
}

- (CAShapeLayer*)pinShapeLayer
{
	return nil;
}

// Hide bolt symbol while charging
- (void)setShowsInlineChargingIndicator: (BOOL)showing
{
	%orig(NO);
}

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectbattery13prefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"fontSize": @14,
			@"boldFont": @NO,
			@"showPercentSymbol": @NO,
			@"customDefaultColorEnabled": @NO,
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			fontSize = [pref integerForKey: @"fontSize"];
			boldFont = [pref boolForKey: @"boldFont"];
			showPercentSymbol = [pref boolForKey: @"showPercentSymbol"];

			if(showPercentSymbol) percentSymbol = @"%";
			else percentSymbol = @"";

			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectbattery13prefs.colors.plist"];
			
			customDefaultColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customDefaultColor"] withFallback: @"#FF9400"];
			chargingColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"chargingColor"] withFallback: @"#26AD61"];
			lowPowerModeColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowPowerModeColor"] withFallback: @"#F2C40F"];
			lowBattery1Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery1Color"] withFallback: @"#E57C21"];
			lowBattery2Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery2Color"] withFallback: @"#E84C3D"];
			
			%init;
		}
	}
}