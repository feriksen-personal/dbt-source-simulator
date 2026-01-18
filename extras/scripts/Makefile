# Makefile for dbt-demo-source-ops
#
# This is a TEMPLATE for YOUR dbt project.
# Copy this file to your project root and customize as needed.
#
# Usage:
#   make help           # Show all available commands
#   make baseline       # Load baseline data
#   make delta-1        # Apply Day 1 changes
#   make full-demo      # Run through all 3 days
#
# Override profile or target:
#   make baseline PROFILE=my_project
#   make baseline TARGET=motherduck
#   make baseline PROFILE=my_project TARGET=motherduck
#
# Documentation: https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki

# ==========================================================================
# Configuration Variables (Override with: make baseline PROFILE=my_project)
# ==========================================================================

# dbt profile name (default: demo_source)
PROFILE ?= demo_source

# dbt target name (default: dev for DuckDB local)
# Options: dev (DuckDB), motherduck (MotherDuck cloud), azure (Azure SQL)
TARGET ?= dev

# Soda Core configuration path
SODA_CONFIG ?= extras/soda/configuration.yml

# ==========================================================================
# Phony Targets (Not actual files)
# ==========================================================================

.PHONY: help setup baseline verify status \
        delta-1 delta-2 delta-3 \
        reset clean \
        soda-scan soda-shop soda-crm \
        init full-demo test-workflow

# ==========================================================================
# Default Target: Show Help
# ==========================================================================

help:
	@echo ""
	@echo "┌─────────────────────────────────────────────────────────────┐"
	@echo "│ Demo Source Operations (dbt-demo-source-ops)                │"
	@echo "└─────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          Install dbt package dependencies"
	@echo ""
	@echo "Core Operations:"
	@echo "  make baseline       Load baseline data (Day 0: 100 customers, 500 orders)"
	@echo "  make verify         Verify baseline data was loaded correctly"
	@echo "  make status         Show current row counts for all tables"
	@echo "  make delta-1        Apply Day 1 changes (+25 customers, +60 orders)"
	@echo "  make delta-2        Apply Day 2 changes (+22 customers, +55 orders)"
	@echo "  make delta-3        Apply Day 3 changes (+28 customers, +65 orders)"
	@echo "  make reset          Truncate all tables and reload baseline"
	@echo "  make clean          Remove DuckDB database files (local only)"
	@echo ""
	@echo "Data Quality (Soda Core):"
	@echo "  make soda-scan      Run quality checks on both databases"
	@echo "  make soda-shop      Run quality checks on jaffle_shop only"
	@echo "  make soda-crm       Run quality checks on jaffle_crm only"
	@echo ""
	@echo "Workflows:"
	@echo "  make init           Setup + baseline + verify + status"
	@echo "  make full-demo      Baseline + Day 1 + Day 2 + Day 3 + status"
	@echo "  make test-workflow  Full demo + Soda quality checks"
	@echo ""
	@echo "Configuration:"
	@echo "  PROFILE=$(PROFILE)   (override: make baseline PROFILE=my_project)"
	@echo "  TARGET=$(TARGET)     (override: make baseline TARGET=motherduck)"
	@echo ""
	@echo "Examples:"
	@echo "  make baseline                    # Load baseline with default profile/target"
	@echo "  make baseline TARGET=motherduck  # Load baseline to MotherDuck"
	@echo "  make full-demo PROFILE=my_proj   # Run full demo with custom profile"
	@echo ""

# ==========================================================================
# Setup and Dependencies
# ==========================================================================

# Install dbt package dependencies (dbt-demo-source-ops)
setup:
	@echo "Installing dbt package dependencies..."
	dbt deps --profile $(PROFILE)
	@echo "✓ Dependencies installed"

# ==========================================================================
# Core Operations
# ==========================================================================

# Load baseline data (Day 0)
baseline:
	@echo "Loading baseline data..."
	dbt run-operation demo_load_baseline --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Baseline loaded"

# Verify baseline data was loaded correctly
verify:
	@echo "Verifying baseline data..."
	dbt run-operation demo_verify_baseline --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Baseline verified"

# Show current row counts for all tables
status:
	@echo "Checking demo source status..."
	dbt run-operation demo_status --profile $(PROFILE) --target $(TARGET)

# Apply Day 1 changes
delta-1:
	@echo "Applying Day 1 changes..."
	dbt run-operation demo_apply_delta --args '{day: 1}' --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Day 1 applied"

# Apply Day 2 changes
delta-2:
	@echo "Applying Day 2 changes..."
	dbt run-operation demo_apply_delta --args '{day: 2}' --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Day 2 applied"

# Apply Day 3 changes
delta-3:
	@echo "Applying Day 3 changes..."
	dbt run-operation demo_apply_delta --args '{day: 3}' --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Day 3 applied"

# Truncate all tables and reload baseline
reset:
	@echo "Resetting to baseline..."
	dbt run-operation demo_reset --profile $(PROFILE) --target $(TARGET)
	@echo "✓ Reset complete"

# ==========================================================================
# Cleanup
# ==========================================================================

# Remove DuckDB database files (local development only)
# WARNING: This deletes the database file. Use with caution.
clean:
	@echo "Removing DuckDB database files..."
	@if [ -f "data/demo_source.duckdb" ]; then \
		rm -f data/demo_source.duckdb data/demo_source.duckdb.wal; \
		echo "✓ Removed data/demo_source.duckdb"; \
	else \
		echo "ℹ No database file found at data/demo_source.duckdb"; \
	fi

# ==========================================================================
# Data Quality (Soda Core)
# ==========================================================================

# Run Soda Core quality checks on both databases
soda-scan: soda-shop soda-crm

# Run quality checks on jaffle_shop database
soda-shop:
	@echo "Running Soda quality checks on jaffle_shop..."
	soda scan -d demo_source \
		-c $(SODA_CONFIG) \
		extras/soda/contracts/jaffle_shop.yml
	@echo "✓ jaffle_shop checks complete"

# Run quality checks on jaffle_crm database
soda-crm:
	@echo "Running Soda quality checks on jaffle_crm..."
	soda scan -d demo_source \
		-c $(SODA_CONFIG) \
		extras/soda/contracts/jaffle_crm.yml
	@echo "✓ jaffle_crm checks complete"

# ==========================================================================
# Workflows (Combine Multiple Operations)
# ==========================================================================

# Initialize: setup + baseline + verify + status
init: setup baseline verify status
	@echo ""
	@echo "✓ Initialization complete!"
	@echo "  Next steps:"
	@echo "    - Run 'make delta-1' to apply Day 1 changes"
	@echo "    - Run 'make full-demo' to simulate all 3 days"
	@echo "    - Run 'make soda-scan' to check data quality"

# Full demo workflow: baseline + day 1 + day 2 + day 3 + status
full-demo: baseline delta-1 delta-2 delta-3 status
	@echo ""
	@echo "✓ Full demo complete!"
	@echo "  All 3 days of changes have been applied."
	@echo "  Run 'make reset' to return to baseline."

# Test workflow: full demo + data quality checks
test-workflow: full-demo soda-scan
	@echo ""
	@echo "✓ Test workflow complete!"
	@echo "  Data has been loaded and validated."

# ==========================================================================
# Custom Targets (Add your own project-specific targets here)
# ==========================================================================

# Example: Run YOUR dbt models against the demo sources
# Uncomment and customize for your project:
#
# run-my-models:
# 	@echo "Running my dbt models..."
# 	dbt build --profile my_project
# 	@echo "✓ Models built"
#
# test-incremental: baseline run-my-models delta-1 run-my-models
# 	@echo "✓ Incremental testing complete"

# ==========================================================================
# Notes
# ==========================================================================
#
# Customization Tips:
# 1. Copy this file to your project root: cp extras/scripts/Makefile .
# 2. Change PROFILE default to your project's profile name
# 3. Add custom targets for your dbt models (see examples above)
# 4. Adjust SODA_CONFIG path if you move configuration files
#
# Target Options:
# - dev:        Local DuckDB (default)
# - motherduck: MotherDuck cloud (requires MOTHERDUCK_TOKEN env var)
# - azure:      Azure SQL (requires Azure credentials)
#
# Environment Variables:
# - Set in your shell: export MOTHERDUCK_TOKEN=your-token
# - Or pass to make: make baseline MOTHERDUCK_TOKEN=your-token
#
# Sequential vs Parallel:
# - make target1 target2  # Sequential (target2 runs after target1)
# - make -j target1 target2  # Parallel (both run simultaneously)
#
# Debugging:
# - make -n baseline  # Dry run (show commands without executing)
# - make --trace      # Show detailed execution trace
#
# ==========================================================================
