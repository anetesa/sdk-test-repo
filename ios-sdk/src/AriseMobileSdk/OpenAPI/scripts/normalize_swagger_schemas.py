#!/usr/bin/env python3
"""
Script to normalize schema names in swagger.json
Replaces .NET generic type names and invalid characters with valid OpenAPI names

Usage:
    python3 normalize_swagger_schemas.py <path/to/swagger.json>
"""

import json
import re
import sys
from pathlib import Path
from typing import Dict


def generate_short_name(long_name: str) -> str:
    """
    Generate a short, readable name from a long .NET generic type name
    
    Examples:
        Contracts.Page`1[[PaymentGateway.Contracts.PublicApi.Isv.Transactions.GetPage.GetIsvTransactionsResponse, ...]]
        -> TransactionsPageResponse
        
        Contracts.Page`1[[PaymentGateway.Contracts.PublicApi.Isv.Customers.PaymentMethods.GetCustomerPaymentMethods.GetCustomerPaymentMethodsResponse, ...]]
        -> CustomerPaymentMethodsPageResponse
    """
    # Pattern for Contracts.Page`1[[...]]
    page_pattern = r"Contracts\.Page`1\[\[([^,]+),"
    match = re.search(page_pattern, long_name)
    
    if match:
        inner_type = match.group(1)
        # Extract meaningful parts from the inner type
        parts = inner_type.split('.')
        
        # Try to find the response class name
        # Usually it's the last part, but we want to extract the domain too
        if len(parts) >= 2:
            # Look for patterns like: Isv.Transactions.GetPage.GetIsvTransactionsResponse
            # or: Isv.Customers.PaymentMethods.GetCustomerPaymentMethods.GetCustomerPaymentMethodsResponse
            
            # Find the domain (Transactions, Customers, etc.)
            domain_idx = None
            for i, part in enumerate(parts):
                if part in ['Transactions', 'Customers', 'SettlementBatches', 'Terminals']:
                    domain_idx = i
                    break
            
            # Get the response name (last part)
            response_name = parts[-1]
            
            if domain_idx is not None:
                domain = parts[domain_idx]
                # Extract base name from response (remove Get, Isv, Response suffixes)
                base_name = response_name
                for suffix in ['Response', 'GetIsv', 'Get', 'Isv']:
                    if base_name.startswith(suffix):
                        base_name = base_name[len(suffix):]
                    elif base_name.endswith(suffix):
                        base_name = base_name[:-len(suffix)]
                
                if base_name:
                    return f"{base_name}PageResponse"
                return f"{domain}PageResponse"
            else:
                # Fallback: use the response name
                if response_name.endswith('Response'):
                    base_name = response_name[:-8]
                    return f"{base_name}PageResponse"
                return f"{response_name}Page"
    
    # For other types, try to extract meaningful parts
    # Remove namespace prefixes and keep the last meaningful part
    parts = long_name.split('.')
    if len(parts) > 0:
        last_part = parts[-1].split('`')[0]  # Remove generic backtick
        # Remove version/culture info if present
        last_part = re.sub(r',\s*Version=.*$', '', last_part)
        return last_part
    
    # Fallback: use a hash of the name
    return f"Schema_{abs(hash(long_name)) % 10000}"


def normalize_swagger_schemas(swagger_path: str, dry_run: bool = False) -> Dict[str, str]:
    """
    Normalize schema names in swagger.json
    
    Args:
        swagger_path: Path to swagger.json file
        dry_run: If True, only show what would be renamed without making changes
    
    Returns:
        Dictionary mapping old names to new names
    """
    swagger_file = Path(swagger_path)
    
    if not swagger_file.exists():
        raise FileNotFoundError(f"swagger.json not found at {swagger_path}")
    
    # Read the swagger file
    with open(swagger_file, 'r', encoding='utf-8') as f:
        swagger = json.load(f)
    
    # Mapping of old schema names to new short names
    schema_renames: Dict[str, str] = {}
    
    # Find all schema keys that need renaming
    schemas = swagger.get('components', {}).get('schemas', {})
    
    # OpenAPI regex: ^[a-zA-Z0-9\.\-_]+$
    invalid_char_pattern = re.compile(r'[^a-zA-Z0-9\.\-_]')
    
    print("🔍 Finding schemas to rename...")
    for old_name in list(schemas.keys()):
        needs_renaming = False
        reason = ""
        
        # Check if it contains invalid characters (backticks, etc.)
        if invalid_char_pattern.search(old_name):
            needs_renaming = True
            reason = "contains invalid characters"
        # Check if it's a long .NET generic type name
        elif '`1[[' in old_name or len(old_name) > 100:
            needs_renaming = True
            reason = "long .NET generic type"
        
        if needs_renaming:
            # For names with backticks, try to clean them up
            if '`' in old_name:
                # Remove backticks and numbers after them (e.g., KeyValuePair`2 -> KeyValuePair2)
                cleaned_name = re.sub(r'`(\d+)', r'\1', old_name)
                # If still invalid, use generate_short_name
                if invalid_char_pattern.search(cleaned_name):
                    new_name = generate_short_name(old_name)
                else:
                    new_name = cleaned_name
            else:
                new_name = generate_short_name(old_name)
            
            schema_renames[old_name] = new_name
            # Truncate long names for display
            display_name = old_name[:80] + "..." if len(old_name) > 80 else old_name
            print(f"  📋 {display_name} ({reason})")
            print(f"     -> {new_name}")
    
    if not schema_renames:
        print("✅ No schemas need renaming")
        return {}
    
    if dry_run:
        print(f"\n🔍 Dry run: Would rename {len(schema_renames)} schemas")
        return schema_renames
    
    # Create backup
    backup_file = swagger_file.with_suffix(f'.backup.{int(swagger_file.stat().st_mtime)}')
    import shutil
    shutil.copy2(swagger_file, backup_file)
    print(f"\n✅ Backup created: {backup_file.name}")
    
    # Apply renames: update schema keys
    print("\n🔄 Updating schema keys...")
    for old_name, new_name in schema_renames.items():
        if old_name in schemas:
            schemas[new_name] = schemas.pop(old_name)
    
    # Function to recursively update $ref values
    def update_refs(obj):
        """Recursively update all $ref values in the JSON structure"""
        if isinstance(obj, dict):
            for key, value in obj.items():
                if key == '$ref' and isinstance(value, str):
                    # Check if this ref points to a renamed schema
                    for old_name, new_name in schema_renames.items():
                        if value.endswith(old_name):
                            obj[key] = value.replace(old_name, new_name)
                            break
                else:
                    update_refs(value)
        elif isinstance(obj, list):
            for item in obj:
                update_refs(item)
    
    # Update all $ref references
    print("🔄 Updating $ref references...")
    update_refs(swagger)
    
    # Skip removing format: date-time - we want to use Configuration(dateTranscoder: .iso8601WithFractionalSeconds)
    # This allows Swift OpenAPI Generator to automatically decode dates
    print("ℹ️  Keeping date-time format (will use Configuration for date decoding)...")
    # date_fields_updated = 0
    # 
    # def remove_date_time_format(obj):
    #     """Recursively remove format: date-time from schema definitions"""
    #     nonlocal date_fields_updated
    #     if isinstance(obj, dict):
    #         # Check if this is a date-time field
    #         if obj.get('type') == 'string' and obj.get('format') == 'date-time':
    #             del obj['format']
    #             date_fields_updated += 1
    #         # Recursively process all values
    #         for key, value in list(obj.items()):
    #             remove_date_time_format(value)
    #     elif isinstance(obj, list):
    #         for item in obj:
    #             remove_date_time_format(item)
    # 
    # remove_date_time_format(swagger)
    # if date_fields_updated > 0:
    #     print(f"  ✅ Removed format: date-time from {date_fields_updated} fields")
    # else:
    #     print("  ℹ️  No date-time fields found")
    
    # Write the updated swagger file
    with open(swagger_file, 'w', encoding='utf-8') as f:
        json.dump(swagger, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Successfully normalized {len(schema_renames)} schema names")
    # if date_fields_updated > 0:
    #     print(f"✅ Removed date-time format from {date_fields_updated} fields")
    print(f"📄 Updated file: {swagger_file}")
    
    return schema_renames


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 normalize_swagger_schemas.py <path/to/swagger.json> [--dry-run]")
        sys.exit(1)
    
    swagger_path = sys.argv[1]
    dry_run = '--dry-run' in sys.argv
    
    try:
        normalize_swagger_schemas(swagger_path, dry_run=dry_run)
        print("\n✨ Done! You can now regenerate the OpenAPI client.")
        print("💡 Tip: Run this script after downloading a new swagger.json")
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

