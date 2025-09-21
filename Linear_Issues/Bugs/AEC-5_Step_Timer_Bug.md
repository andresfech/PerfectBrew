# AEC-5: Bug: Step timer disappears in 1 second during brewing

**🔗 Linear URL:** https://linear.app/aechavarria/issue/AEC-5/bug-step-timer-disappears-in-1-second-during-brewing

## 📋 Issue Details

- **ID:** AEC-5
- **Status:** Unknown (needs status update)
- **Priority:** High (2)
- **Team:** Aechavarria
- **Project:** None (should be added to PerfectBrew)
- **Assignee:** None
- **Labels:** Bug
- **Created:** 2025-09-16T00:41:04.063Z
- **Updated:** 2025-09-16T00:41:04.063Z

## 🐛 Bug Description

The brewing step timer shows the correct duration (e.g., 25 seconds) but disappears in just 1 second, causing steps to be skipped and the brewing process to malfunction.

## 🔍 Steps to Reproduce

1. Open PerfectBrew app
2. Select any recipe (e.g., AeroPress James Hoffman)
3. Start brewing process
4. Observe the small step timer
5. Notice it shows 25s but disappears in 1s

## 🎯 Expected Behavior

* Step timer should count down the full duration (25s)
* Each step should be visible for its intended duration
* No steps should be skipped

## 🚨 Current Behavior

* Step timer disappears in 1 second
* Steps are skipped
* "Enjoy your coffee!" appears prematurely

## 📱 Environment

* iOS app
* All recipes affected
* Occurs consistently

## 🔧 Technical Details

* Issue in `BrewingGuideViewModel.swift` timer logic
* `updateStep()` method incorrectly calculating step durations
* Cumulative vs individual step time confusion

## ✅ Resolution Status

**🎉 RESOLVED** - This issue has been fixed in the recent development session:

### Fixes Applied:
1. **Timer Logic Fix**: Updated `updateStep()` method in `BrewingGuideViewModel.swift`
2. **Step Duration Calculation**: Fixed cumulative vs individual step time logic
3. **JSON Recipe Updates**: Corrected recipe timing structures
4. **Extensive Testing**: Added debug logging and validation

### Files Modified:
- `PerfectBrew/BrewingGuideViewModel.swift`
- `PerfectBrew/BrewingGuideScreen.swift`
- Recipe JSON files (timing corrections)

**Status:** Ready for QA and user verification.
