# Data Export/Import Formats

This document describes the recommended formats for importing and exporting data from the Cloth app.

## Recommended Formats

### 1. JSON Format (Primary Recommendation)

**Best for:** Complete data backup, data migration, and sharing between devices.

**Advantages:**
- ✅ Preserves all data types (dates, booleans, numbers, arrays)
- ✅ Includes binary image data (base64 encoded)
- ✅ Human-readable and debuggable
- ✅ Cross-platform compatibility
- ✅ Version-controlled and extensible
- ✅ Native Flutter support

**File Extension:** `.json`
**MIME Type:** `application/json`

**Structure:**
```json
{
  "version": "1.0.0",
  "exportedAt": "2024-01-15T10:30:00Z",
  "clothingItems": [
    {
      "id": "uuid-here",
      "name": "Blue Jeans",
      "category": "pants",
      "subcategory": "jeans",
      "brand": "Levi's",
      "color": "blue",
      "materials": "cotton, denim",
      "season": "all-season",
      "purchasePrice": 89.99,
      "ownedSince": "2023-06-15T00:00:00Z",
      "origin": "USA",
      "laundryImpact": "medium",
      "repairable": true,
      "notes": "Favorite pair",
      "imageData": "base64-encoded-image-data",
      "createdAt": "2023-06-15T10:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z",
      "isActive": true,
      "wearCount": 25
    }
  ],
  "outfits": [
    {
      "id": "outfit-uuid",
      "date": "2024-01-15T08:00:00Z",
      "clothingItemIds": ["uuid-here", "another-uuid"],
      "notes": "Casual Friday outfit",
      "imageData": "base64-encoded-outfit-image",
      "createdAt": "2024-01-15T08:30:00Z",
      "updatedAt": "2024-01-15T08:30:00Z",
      "isActive": true
    }
  ]
}
```

### 2. CSV Format (Secondary Option)

**Best for:** Spreadsheet analysis, basic data viewing, and lightweight exports.

**Advantages:**
- ✅ Excel/Google Sheets compatibility
- ✅ Lightweight file size
- ✅ Easy to view and edit
- ✅ Good for data analysis

**Limitations:**
- ❌ No binary image data support
- ❌ All data becomes strings
- ❌ No nested data structures
- ❌ Limited data type preservation

**File Extension:** `.csv`
**MIME Type:** `text/csv`

**Structure:**
```csv
=== CLOTHING ITEMS ===
ID,Name,Category,Subcategory,Brand,Color,Materials,Season,Purchase Price,Owned Since,Origin,Laundry Impact,Repairable,Notes,Wear Count,Created At,Updated At,Is Active
uuid-here,"Blue Jeans",pants,jeans,"Levi's",blue,"cotton, denim",all-season,89.99,2023-06-15T00:00:00Z,USA,medium,true,"Favorite pair",25,2023-06-15T10:00:00Z,2024-01-15T10:30:00Z,true

=== OUTFITS ===
ID,Date,Clothing Item IDs,Notes,Created At,Updated At,Is Active
outfit-uuid,2024-01-15T08:00:00Z,"uuid-here;another-uuid","Casual Friday outfit",2024-01-15T08:30:00Z,2024-01-15T08:30:00Z,true
```

## Alternative Formats (Not Implemented)

### SQLite Database
- **Use case:** Advanced users who want to run SQL queries
- **Advantages:** Full relational data, query capabilities, data integrity
- **Disadvantages:** Complex for average users, requires SQL knowledge

### XML Format
- **Use case:** Enterprise integration, legacy systems
- **Advantages:** Structured, schema validation
- **Disadvantages:** Verbose, larger file sizes, less common for mobile apps

## Implementation Details

### Export Process
1. User selects export format (JSON or CSV)
2. Data is serialized according to the chosen format
3. File is saved to temporary directory
4. Native sharing dialog allows user to save/share the file

### Import Process
1. User selects JSON file from device
2. File is parsed and validated
3. Data is converted back to domain entities
4. Imported data is merged with existing data (with conflict resolution)

### Version Compatibility
- Export files include version information
- Import process validates version compatibility
- Future versions will support backward compatibility

### Image Handling
- **JSON:** Images are base64 encoded and embedded in the file
- **CSV:** Images are not included (limitation of CSV format)
- **File Size:** JSON files with images can be large; consider compression for very large datasets

### Data Validation
- All required fields are validated during import
- Invalid records are skipped with error logging
- Partial imports are supported (some records may fail while others succeed)

## Usage Recommendations

### For Regular Users
- **Use JSON format** for complete backups and data migration
- Export regularly to prevent data loss
- Store exports in cloud storage for additional backup

### For Data Analysis
- **Use CSV format** for spreadsheet analysis
- Export specific date ranges for focused analysis
- Use CSV for sharing data with others who don't use the app

### For Developers
- **Use JSON format** for testing and development
- JSON structure is well-documented and extensible
- Version field allows for future format evolution

## Security Considerations

- Export files contain personal data and images
- Users should be cautious when sharing export files
- Consider encryption for sensitive data in future versions
- Images are stored in base64 format (not encrypted)

## Future Enhancements

1. **Compression:** Add gzip compression for large JSON files
2. **Encryption:** Add optional encryption for sensitive data
3. **Incremental Export:** Export only changed data since last export
4. **Cloud Integration:** Direct export to cloud storage services
5. **Format Validation:** Add JSON schema validation
6. **Batch Operations:** Import/export multiple files at once
