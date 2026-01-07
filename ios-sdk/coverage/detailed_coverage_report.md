# Detailed Code Coverage Report (SDK Only)

Generated: Fri Dec 19 15:12:58 CET 2025

**Note:** This report shows coverage only for SDK source code, excluding:
- Test files and test applications
- Model files (data structures)
- Generated code (OpenAPI, GeneratedSources)
- Backup files

**Included directories:**
- Services/
- Storages/
- Utils/
- Networking/ (excluding GeneratedSources/)
- Mappers/
- Core/
- Main SDK files (AriseMobileSdk.swift, AriseMobileTTP.swift)

## Overall SDK Coverage

**0.0%**

## Coverage by Target

```
ID Name                       # Source Files Coverage            
-- -------------------------- -------------- ------------------- 
0  AriseMobileSdk.framework   105            24.41% (6296/25790) 
1  AriseMobileSdkTests.xctest 42             88.53% (7256/8196)  
2  AriseTestAppForDebug.app   12             9.73% (1752/18014)  
3  CryptoSwift                0              0.00% (0/0)         
```

## File-by-File Coverage

```
Unable to generate file coverage
```

## Coverage Categories

### Well Covered (>80%)
Files with high test coverage.

### Needs Improvement (50-80%)
Files that need additional test coverage.

### Poor Coverage (<50%)
Files with low test coverage that should be prioritized.

## Recommendations

1. Focus on files with <50% coverage first
2. Add edge case tests for critical components
3. Ensure all public API methods are tested
4. Add integration tests for complex workflows

## How to View Coverage in Xcode

1. Open `src/AriseMobileSdk.xcodeproj`
2. Product > Show Test Report (Cmd+9)
3. Select the test run
4. Click the "Coverage" tab
5. Browse files to see line-by-line coverage

## Coverage Data Location

Coverage data source: `/Users/romanpavlenko/Library/Developer/Xcode/DerivedData/AriseMobileSdk-dvldgffajoyppebixwcacxnkpjzq/Logs/Test/Test-AriseMobileSdk-2025.12.19_14-56-03-+0100.xcresult`

**Note:** This script automatically finds the latest coverage data from:
1. Path provided as argument (if specified)
2. `coverage/test-results.xcresult` (from `run_tests_with_coverage.sh`)
3. Latest `.xcresult` in DerivedData (from Xcode Cmd+U)

