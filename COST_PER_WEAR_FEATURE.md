# Cost per Wear Ranking Feature

## Overview
The Cost per Wear Ranking widget is a new addition to the Insights tab that provides users with valuable analytics about their clothing investments. It calculates the cost per wear for each clothing item and displays them in a ranked leaderboard format.

## What is Cost per Wear?
Cost per wear is calculated as: **Purchase Price ÷ Number of Times Worn**

This metric helps users understand:
- Which items provide the best value for money
- Which items might be overpriced relative to their usage
- How to make more informed purchasing decisions in the future

## Features

### 1. **Sorting Options**
- **Descending (Default)**: Shows items with highest cost per wear first
- **Ascending**: Shows items with lowest cost per wear first
- Toggle between sorting options using the arrow button in the top-right corner

### 2. **Category Filtering**
- Filter items by clothing categories (e.g., shirts, pants, dresses)
- Multiple categories can be selected simultaneously
- When no categories are selected, all items are included

### 3. **Leaderboard Display**
- **Top 3 items** are highlighted with special colors:
  - 🥇 **Gold**: 1st place
  - 🥈 **Silver**: 2nd place  
  - 🥉 **Bronze**: 3rd place
- Each item shows:
  - Item name and brand
  - Category and subcategory
  - Cost per wear (prominently displayed)
  - Wear count
  - Original purchase price

### 4. **Smart Filtering**
- Only includes items that have:
  - A valid purchase price
  - Been worn at least once
- Automatically excludes items without price data or zero wear count

## Technical Implementation

### New Use Case
- `GetClothingItemsByCostPerWearUseCase`: Calculates and ranks items by cost per wear

### New Provider
- `costPerWearRankingProvider`: Provides data with filtering and sorting parameters

### New Widget
- `CostPerWearRankingWidget`: Main UI component with filtering and display logic

### Integration
- Added to `InsightsView` below the existing "Most Worn Items" leaderboard
- Uses the existing clothing item and outfit data infrastructure

## User Experience

### Initial State
- Shows loading indicator while data is being calculated
- Displays available category filters
- Default sort order is descending (highest cost per wear first)

### Interactive Elements
- **Category chips**: Tap to select/deselect categories
- **Sort toggle**: Tap to switch between ascending/descending order
- **Real-time updates**: Results update automatically when filters change

### Empty States
- Helpful message when no items match the current filters
- Suggests adjusting filters or adding more clothing items with prices and wear history

## Benefits

1. **Financial Awareness**: Users can see which items are costing them the most per wear
2. **Purchase Decisions**: Helps evaluate future clothing purchases based on value
3. **Wardrobe Optimization**: Identifies underutilized expensive items
4. **Budget Planning**: Better understanding of clothing investment returns

## Future Enhancements

Potential improvements could include:
- Date range filtering (e.g., cost per wear in the last year)
- Price range filtering
- Export functionality for cost analysis
- Comparison with industry averages
- Recommendations for similar items with better value

## Data Requirements

For the feature to work properly, clothing items need:
- ✅ Purchase price recorded
- ✅ Active status (not deleted)

**Wear Count Handling:**
- Items with actual wear history from outfits will show their real wear count
- Items that haven't been worn yet (0 wear count) will be assigned a default wear count of 1 for calculation purposes
- This ensures the feature works even during development when no outfits have been created yet
- Items with estimated wear counts will be marked with "(estimated)" in the UI

## Bug Fixes

**Issue Fixed:** When sorting was set to "Highest to Lowest" with no category filters selected, no items would appear.

**Root Cause:** The use case was filtering out items with 0 wear count, but during development there might be no outfits yet, resulting in all items having 0 wear count.

**Solution:** Modified the use case to assign a default wear count of 1 to items with 0 wear count, allowing cost per wear calculation to proceed while clearly indicating when wear counts are estimated.
