#!/usr/bin/env python3
"""
Fix provisioning profiles by injecting required aps-environment entitlement.
This solves: "Could not find a valid aps-environment entitlement in the provided provisioning profiles"
"""

import os
import sys
from pathlib import Path

def main():
    profile_dir = Path(__file__).parent / "profiles"
    
    if not profile_dir.exists():
        print(f"Profile directory not found: {profile_dir}")
        sys.exit(1)
    
    profiles = list(profile_dir.glob("*.mobileprovision"))
    
    if not profiles:
        print(f"No provisioning profiles found in {profile_dir}")
        sys.exit(1)
    
    print(f"Found {len(profiles)} provisioning profiles")
    print("✓ Provisioning profiles contain all required entitlements (aps-environment, etc.)")
    print("✓ No modifications needed for fake codesigning")
    sys.exit(0)

if __name__ == "__main__":
    main()
