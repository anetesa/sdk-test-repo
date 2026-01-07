# Code Coverage Reports

## Quick Start

### 1. Generate Coverage Data

Run tests with code coverage enabled:

```bash
./coverage/scripts/run_tests_with_coverage.sh
```

This script will:
- Run all tests
- Save results to `coverage/test-results.xcresult`
- Enable code coverage collection

### 2. View Coverage Report

After generating data, run:

```bash
./coverage/scripts/check_coverage.sh
```

## Usage Options

### Basic Run
```bash
./coverage/scripts/check_coverage.sh
```
- Uses minimum coverage of 75% (default)
- Automatically searches for test results in:
  1. `coverage/test-results.xcresult`
  2. Latest `.xcresult` in DerivedData (if tests were run via Xcode)

### With Minimum Coverage Threshold
```bash
./coverage/scripts/check_coverage.sh 80
```
- Sets minimum coverage to 80%

### With Specific Results File
```bash
./coverage/scripts/check_coverage.sh 75 ./coverage/test-results.xcresult
```
- Specifies a particular test results file

### Using Results from Xcode

If you ran tests via Xcode (Cmd+U), you can use those results:

```bash
# Find the path to .xcresult in DerivedData
./coverage/scripts/check_coverage.sh 75 ~/Library/Developer/Xcode/DerivedData/AriseMobileSdk-*/Logs/Test/*.xcresult
```

## What the Report Shows

The script shows coverage only for **testable components**:

✅ **Includes:**
- Services (service classes)
- Storages (storage classes)
- Utils (utility classes)
- Networking/Middlewares (middleware for network requests)
- Mappers (mapper classes)
- Core (core components)
- Main SDK files (main SDK files)

❌ **Excludes:**
- Models (data models - simple structures)
- GeneratedSources (generated code)
- OpenAPI (generated code)
- Protocols (protocol definitions only)
- Test files and Mocks

## Report Format

The report shows:
1. **Coverage by Category** - average coverage for each file category
2. **Detailed File List** - coverage for each individual file
3. **Low Coverage Files** - files with coverage < 70%
4. **Overall Statistics** - total coverage and file count

## Example Output

```
═══════════════════════════════════════════════════════════════
  Code Coverage Report - Testable Components Only
═══════════════════════════════════════════════════════════════

📦 Services (6 files): 72.80%
  TransactionsService.swift                                     80.17%
  TTPService.swift                                              82.09%
  ...

💾 Storages (2 files): 52.66%
  AriseTokenStorage.swift                                       28.19%
  AriseSession.swift                                            77.13%

...

═══════════════════════════════════════════════════════════════
  Summary
═══════════════════════════════════════════════════════════════
Total testable files: 56
Overall coverage: 84.43%

⚠️  Files with coverage < 70% (11 files):
  CalculateAmountMapper.swift                                   37.14%
  ...

✅ Overall Coverage: 84.43% (meets minimum of 75%)
```

## Troubleshooting

### "Test results (.xcresult) not found"

Run first:
```bash
./coverage/scripts/run_tests_with_coverage.sh
```

### "Unable to read SDK coverage data"

Make sure:
1. Tests were run with coverage enabled
2. The `.xcresult` file exists and is accessible
3. The correct path to the results file is specified
