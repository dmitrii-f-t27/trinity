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

def upload_bundle(bundle_id: str, token: str, sandbox: bool = False, publish: bool = False, dry_run: bool = False) -> Dict:
    """Upload a single bundle to Zenodo"""
    print(f"\n{'='*60}")
    if dry_run:
        print(f"Testing {bundle_id} (DRY-RUN MODE)")
    else:
        print(f"Uploading {bundle_id} to Zenodo")
    print(f"{'='*60}\n")

    if dry_run:
        # Load metadata for validation only
        try:
            metadata = load_metadata(bundle_id)
            description = load_description(bundle_id)
            desc_file = Path('docs/research') / f'zenodo_{bundle_id}_enhanced_v7.0.md'
            print(f"  Metadata file: {len(metadata)} keys ✅")
            print(f"  Description file: {desc_file.stat().st_size} bytes ✅")
            print(f"  Draft mode: {not publish}")
            return {
                'bundle_id': bundle_id,
                'dry_run': True,
                'validated': True,
            }
        except Exception as e:
            return {
                'bundle_id': bundle_id,
                'dry_run': True,
                'error': str(e),
            }

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

def upload_all_bundles(token: str, sandbox: bool = False, publish: bool = False, dry_run: bool = False) -> None:
    """Upload all bundles to Zenodo"""
    bundles = ['B001', 'B002', 'B003', 'B004', 'B005', 'B006', 'B007']

    results = []

    for bundle in bundles:
        try:
            result = upload_bundle(bundle, token, sandbox, publish, dry_run)
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

def verify_doi(doi: str) -> bool:
    """Verify that a DOI resolves correctly"""
    url = f"https://doi.org/{doi}"
    try:
        response = requests.head(url, allow_redirects=True, timeout=10)
        return response.status_code == 200
    except Exception as e:
        print(f"Warning: Could not verify DOI {doi}: {e}")
        return False

def create_github_release(version: str, doi: str, bundle_id: str, dry_run: bool = False) -> Dict:
    """Create a GitHub release for the published Zenodo bundle
    Skips if dry_run mode is enabled"""
    import subprocess

    # Get GitHub repo from git remote
    try:
        repo_url = subprocess.check_output(
            ['git', 'config', '--get', 'remote.origin.url'],
            stderr=subprocess.DEVNULL
        ).decode().strip()

        # Convert to API format
        if repo_url.startswith('git@'):
            repo = repo_url.split(':')[1].replace('.git', '')
        elif repo_url.startswith('https://'):
            repo = repo_url.split('https://github.com/')[1].replace('.git', '')
        else:
            return {'error': 'Could not determine GitHub repo'}

    except Exception as e:
        return {'error': f'Git error: {e}'}

    # Check if gh CLI is available
    try:
        subprocess.check_output(['gh', '--version'], stderr=subprocess.DEVNULL)
    except Exception:
        return {'error': 'GitHub CLI (gh) not installed'}

    # Skip release on dry-run
    if dry_run:
        return {'success': True, 'dry_run': True, 'notes': 'Skipped GitHub release (dry-run mode)'}
    
    # Create release
    tag = f"zenodo-v7.0-{bundle_id}"
    title = f"Zenodo v7.0 {bundle_id}"
    notes = f"""Zenodo v7.0 {bundle_id} published

DOI: {doi}
Bundle: {bundle_id}
Version: 7.0.0
Date: {time.strftime('%Y-%m-%d')}

V15 Scientific Rigor Features:
- Dual confidence intervals (95%, 99%)
- Effect size quantification (Cohen's d)
- Significance level indicators
- Calibration metrics (ECE, Brier Score)
- Bootstrap validation (10,000 resamples)

φ² + 1/φ² = 3 | TRINITY
"""

    try:
        result = subprocess.run(
            ['gh', 'release', 'create', tag, '--title', title, '--notes', notes],
            capture_output=True,
            text=True
        )

        if result.returncode == 0:
            return {'success': True, 'tag': tag, 'url': f'https://github.com/{repo}/releases/tag/{tag}'}
        else:
            return {'error': result.stderr}

    except Exception as e:
        return {'error': str(e)}

def check_deposition_status(deposition_id: str, token: str, sandbox: bool = False) -> Dict:
    """Check the status of a deposition"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions/{deposition_id}"

    headers = {
        "Authorization": f"Bearer {token}"
    }

    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()

def list_depositions(token: str, sandbox: bool = False, page: int = 1) -> Dict:
    """List all depositions for the user"""
    api = SANDBOX_API if sandbox else ZENODO_API
    url = f"{api}/deposit/depositions"

    headers = {
        "Authorization": f"Bearer {token}"
    }

    params = {'page': page, 'size': 20}

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

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
    parser.add_argument('--dry-run', action='store_true',
                       help='Test mode: skip actual upload to Zenodo')
    parser.add_argument('--github-release', action='store_true',
                       help='Create GitHub release after publish')
    parser.add_argument('--verify-doi', action='store_true',
                       help='Verify DOI resolves after publish')
    parser.add_argument('--status', '-s', type=str, metavar='ID',
                       help='Check status of a deposition')
    parser.add_argument('--list', action='store_true',
                       help='List all depositions')

    args = parser.parse_args()

    # Get token (not required for dry-run mode)
    token = args.token or os.environ.get('ZENODO_TOKEN')
    if not token and not args.dry_run:
        print("Error: ZENODO_TOKEN not set")
        print("Get your token at: https://zenodo.org/account/settings/applications/tokens/new")
        print("Then: export ZENODO_TOKEN=your_token_here")
        sys.exit(1)
    elif not token:
        print("Note: Running in dry-run mode - no token required")

    # List depositions
    if args.list:
        print("\nListing depositions...\n")
        depositions = list_depositions(token, args.sandbox)
        for dep in depositions:
            print(f"  ID: {dep.get('id')}")
            print(f"  Title: {dep.get('title', 'N/A')}")
            print(f"  Status: {dep.get('state', 'N/A')}")
            print(f"  DOI: {dep.get('doi', 'pending')}")
            print()
        sys.exit(0)

    # Check status
    if args.status:
        print(f"\nChecking deposition {args.status}...\n")
        status = check_deposition_status(args.status, token, args.sandbox)
        print(f"  ID: {status.get('id')}")
        print(f"  Title: {status.get('title', 'N/A')}")
        print(f"  Status: {status.get('state', 'N/A')}")
        print(f"  DOI: {status.get('doi', 'pending')}")
        print(f"  Created: {status.get('created', 'N/A')}")
        print(f"  Modified: {status.get('modified', 'N/A')}")
        sys.exit(0)

    # Upload
    if args.all:
        upload_all_bundles(token, args.sandbox, args.publish, args.dry_run)
    elif args.bundle:
        result = upload_bundle(args.bundle, token, args.sandbox, args.publish, args.dry_run)

        # Optional: Create GitHub release
        if args.publish and args.github_release:
            doi = result.get('doi')
            if doi:
                print("\nCreating GitHub release...")
                gh_result = create_github_release('v7.0', doi, args.bundle)
                if 'error' in gh_result:
                    print(f"  Warning: {gh_result['error']}")
                else:
                    print(f"  Created: {gh_result['url']}")

        # Optional: Verify DOI
        if args.publish and args.verify_doi:
            doi = result.get('doi')
            if doi:
                print(f"\nVerifying DOI: {doi}")
                if verify_doi(doi):
                    print("  DOI verified successfully!")
                else:
                    print("  Warning: DOI verification failed (may take time to propagate)")
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == '__main__':
    main()
