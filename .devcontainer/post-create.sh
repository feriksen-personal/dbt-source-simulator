#!/bin/bash
# =============================================================================
# post-create.sh - Devcontainer post-create setup
# =============================================================================
# Installs dbt-core, dbt adapters (duckdb, sqlserver), and development tools.
#
# Packages installed:
#   - dbt-core: Core dbt framework
#   - dbt-duckdb: DuckDB adapter for local development/testing
#   - dbt-sqlserver: Azure SQL adapter for demo/POC environments
#   - duckdb: Python client for testing SQL files
#   - yamllint: YAML validation
#
# This script is idempotent - safe to run multiple times.
# =============================================================================
set -e

echo "=== Post-create setup starting ==="

# Install dbt packages and development tools
echo "Installing dbt-core, adapters, and development tools..."
pip install --no-cache-dir \
    dbt-core \
    dbt-duckdb \
    dbt-sqlserver \
    duckdb \
    yamllint

# Configure Starship
echo "Configuring Starship prompt..."
mkdir -p ~/.config
cp .devcontainer/starship.toml ~/.config/starship.toml

# Verify installations
echo ""
echo "=== Verifying installations ==="
echo -n "gh: "; gh --version | head -1
echo -n "python: "; python --version
echo -n "duckdb: "; python -c "import duckdb; print(duckdb.__version__)"
echo -n "yamllint: "; yamllint --version
echo -n "dbt-core: "; dbt --version | head -1
echo "dbt adapters:"
dbt --version | grep -E "(duckdb|sqlserver)" || echo "  (checking available adapters...)"

echo ""
echo "=== Post-create setup complete ==="
