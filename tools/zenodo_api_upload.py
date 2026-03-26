#!/usr/bin/env python3
"""
Zenodo v7.0 API Uploader

Automated upload to Zenodo using REST API.
Requires: ZENODO_TOKEN environment variable.

Usage:
    export ZENODO_TOKEN=your_token_here
    python3 tools/zenodo_api_upload.py --bundle B001
    python3 tools/zenodo_api_upload.py --all
"""

import os
import sys
import json
import requests
import time
from pathlib import Path
from typing import Dict, Optional

ZENODO_API = "https://zenodo.org/api"
SANDBOX_API = "https://sandbox.zenodo.org/api"

def get_token() -> str:
    """Get Zenodo API token from environment"""
    token = os.environ.get('ZENODO_TOKEN')
    if not token:
        print("Error: ZENODO_TOKEN environment variable not set")
        print("Get your token at: https://zenodo.org/account/settings/applications/tokens")
        sys.exit(1)
    return token

def load_metadata(bundle_id: str) -> Dict:
    """Load metadata from JSON file"""
    metadata_file = Path('docs/research') / f'.zenodo.{bundle_id}_v7.0.json'
    if not metadata_file.exists():
        print(f"Error: Metadata file not found: {metadata_file}")
        sys.exit(1)

    with open(metadata_file) as f:
        return json.load(f)

def load_description(bundle_id: str) -> str:
    """Load enhanced description from markdown file"""
    desc_file = Path('docs/research') / f'zenodo_{bundle_id}_enhanced_v7.0.md'
    if not desc_file.exists():
        print(f"Error: Description file not found: {desc_file}")
        sys.exit(1)

    with open(desc_file) as f:
        return f.read()

def create_deposition(token: str, sandbox: bool = False) -> Dict:
    """Create a new deposition"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }

    response = requests.post(url, headers=headers, json={})
    response.raise_for_status()
    return response.json()

def upload_metadata(deposition_id: str, token: str, metadata: Dict, sandbox: bool = False) -> None:
    """Update deposition metadata"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions/{deposition_id}"

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {token}"
    }

    # Extract metadata from Zenodo JSON format
    data = {"metadata": metadata}

    response = requests.put(url, headers=headers, json=data)
    response.raise_for_status()

def upload_file(deposition_id: str, token: str, file_path: Path, sandbox: bool = False) -> None:
    """Upload a file to deposition"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions/{deposition_id}/files"

    headers = {
        "Authorization": f"Bearer {token}"
    }

    files = {
        'file': (file_path.name, open(file_path, 'rb'))
    }

    data = {
        'name': file_path.name
    }

    response = requests.post(url, headers=headers, files=files, data=data)
    response.raise_for_status()
    print(f"  Uploaded: {file_path.name}")

def publish_deposition(deposition_id: str, token: str, sandbox: bool = False) -> Dict:
    """Publish the deposition"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions/{deposition_id}/actions/publish"

    headers = {
        "Authorization": f"Bearer {token}"
    }

    response = requests.post(url, headers=headers)
    response.raise_for_status()
    return response.json()

def upload_bundle(bundle_id: str, token: str, sandbox: bool = False, publish: bool = False) -> Dict:
    """Upload a single bundle to Zenodo"""
    print(f"\n{'='*60}")
    print(f"Uploading {bundle_id} to Zenodo")
    print(f"{'='*60}\n")

    # Load metadata and description
    metadata = load_metadata(bundle_id)
    description = load_description(bundle_id)

    # Update description in metadata
    metadata['description'] = description

    # Create deposition
    print("1. Creating deposition...")
    deposition = create_deposition(token, sandbox)
    deposition_id = deposition['id']
    print(f"   Created: {deposition_id}")

    # Upload metadata
    print("2. Uploading metadata...")
    upload_metadata(deposition_id, token, metadata, sandbox)
    print("   Metadata updated")

    # Upload description file
    print("3. Uploading files...")
    desc_file = Path('docs/research') / f'zenodo_{bundle_id}_enhanced_v7.0.md'
    upload_file(deposition_id, token, desc_file, sandbox)

    # Upload supplementary files if they exist
    data_dir = Path('docs/research/data')
    if data_dir.exists():
        csv_files = list(data_dir.glob(f'{bundle_id}*.csv'))
        for csv_file in csv_files:
            upload_file(deposition_id, token, csv_file, sandbox)

    figures_dir = Path('docs/research/figures')
    if figures_dir.exists():
        fig_files = list(figures_dir.glob(f'{bundle_id}*_v15.png'))
        for fig_file in fig_files:
            upload_file(deposition_id, token, fig_file, sandbox)

    # Publish if requested
    if publish:
        print("4. Publishing...")
        result = publish_deposition(deposition_id, token, sandbox)
        doi = result.get('doi', 'pending')
        print(f"   Published: {doi}")
    else:
        print("4. Skipping publish (draft mode)")
        print(f"   Draft URL: https://{('sandbox.' if sandbox else '')}zenodo.org/deposit/{deposition_id}")

    print(f"\n{bundle_id}: Upload complete!")

    return {
        'bundle_id': bundle_id,
        'deposition_id': deposition_id,
        'doi': deposition.get('doi', 'pending')
    }

def upload_all_bundles(token: str, sandbox: bool = False, publish: bool = False) -> None:
    """Upload all bundles to Zenodo"""
    bundles = ['B001', 'B002', 'B003', 'B004', 'B005', 'B006', 'B007']

    results = []

    for bundle in bundles:
        try:
            result = upload_bundle(bundle, token, sandbox, publish)
            results.append(result)
            time.sleep(2)  # Rate limiting
        except Exception as e:
            print(f"Error uploading {bundle}: {e}")
            results.append({'bundle_id': bundle, 'error': str(e)})

    # Summary
    print(f"\n{'='*60}")
    print("UPLOAD SUMMARY")
    print(f"{'='*60}\n")

    for result in results:
        bid = result['bundle_id']
        if 'error' in result:
            print(f"  {bid}: FAILED ❌")
            print(f"    Error: {result['error']}")
        else:
            print(f"  {bid}: SUCCESS ✅")
            print(f"    DOI: {result.get('doi', 'pending')}")

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Upload Trinity bundles to Zenodo')
    parser.add_argument('--bundle', '-b', type=str,
                       help='Bundle ID (B001-B007, PARENT)')
    parser.add_argument('--all', '-a', action='store_true',
                       help='Upload all bundles')
    parser.add_argument('--sandbox', action='store_true',
                       help='Use Zenodo sandbox (for testing)')
    parser.add_argument('--publish', action='store_true',
                       help='Publish deposition (default: draft only)')
    parser.add_argument('--token', '-t', type=str,
                       help='Zenodo API token (or set ZENODO_TOKEN env var)')

    args = parser.parse_args()

    # Get token
    token = args.token or os.environ.get('ZENODO_TOKEN')
    if not token:
        print("Error: ZENODO_TOKEN not set")
        print("Get your token at: https://zenodo.org/account/settings/applications/tokens/new")
        print("Then: export ZENODO_TOKEN=your_token_here")
        sys.exit(1)

    # Upload
    if args.all:
        upload_all_bundles(token, args.sandbox, args.publish)
    elif args.bundle:
        upload_bundle(args.bundle, token, args.sandbox, args.publish)
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == '__main__':
    main()
