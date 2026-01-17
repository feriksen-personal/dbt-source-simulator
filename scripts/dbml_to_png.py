#!/usr/bin/env python3
"""
DBML to PNG Converter using dbdiagram.io API

Converts DBML files to PNG diagrams using the dbdiagram.io rendering service.

Usage:
    python scripts/dbml_to_png.py docs/generated/jaffle-shop.dbml wiki/images/jaffle-shop-erd.png
"""

import sys
import requests
from pathlib import Path


def dbml_to_png(dbml_file: Path, output_file: Path) -> None:
    """Convert DBML file to PNG using dbdiagram.io API."""

    # Read DBML content
    dbml_content = dbml_file.read_text()

    # dbdiagram.io API endpoint for rendering
    # Note: This is a public API endpoint that accepts DBML and returns PNG
    api_url = "https://dbdiagram.io/api/render"

    payload = {
        "code": dbml_content,
        "format": "png"
    }

    print(f"Converting {dbml_file} to PNG...")

    try:
        response = requests.post(api_url, json=payload, timeout=30)
        response.raise_for_status()

        # Write PNG to output file
        output_file.parent.mkdir(parents=True, exist_ok=True)
        output_file.write_bytes(response.content)

        print(f"✓ Generated {output_file}")

    except requests.exceptions.RequestException as e:
        print(f"Error: Failed to generate PNG from dbdiagram.io API", file=sys.stderr)
        print(f"  {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main entry point."""
    if len(sys.argv) < 3:
        print("Usage: python scripts/dbml_to_png.py <dbml_file> <output_png>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  python scripts/dbml_to_png.py docs/generated/jaffle-shop.dbml wiki/images/jaffle-shop-erd.png", file=sys.stderr)
        sys.exit(1)

    dbml_file = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    if not dbml_file.exists():
        print(f"Error: DBML file not found: {dbml_file}", file=sys.stderr)
        sys.exit(1)

    dbml_to_png(dbml_file, output_file)


if __name__ == "__main__":
    main()
