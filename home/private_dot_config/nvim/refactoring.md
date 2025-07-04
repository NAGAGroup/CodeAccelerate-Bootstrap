# Neovim Configuration Refactoring Plan

## Current Structure Assessment
- Main entry point: `init.lua`
- Configuration modules in `lua/config/`
- Plugin configurations reorganized into:
  - `lua/plugins/core/`: Core system and essential plugins useful for any Neovim setup
  - `lua/plugins/lang/`: Language-specific plugins, LSP configs, and linters
  - `lua/plugins/ext/`: Extended functionality plugins not essential for everyone
- Lazy loads plugins in the correct order: core → lang → ext

## Completed Improvements

### 1. Organization and Structure
- ✅ Consolidated related functionality in clear directories
- ✅ Reorganized plugins into three main categories: core, lang, and ext
- ✅ Standardized configuration patterns
- ✅ Migrated to NVChad's base46 for theming
- ✅ Adopted Snacks.nvim for extended UI functionality
- ✅ Created clear separation between core system and language-specific functionality

### 2. Plugin Management
- ✅ Implemented lazy-loading configurations
- ✅ Categorized plugins by purpose and universality
- ✅ Standardized plugin configuration format
- ✅ Removed unused plugins and configurations
- ✅ Added custom adapters for CodeCompanion in ext category
- ✅ Updated lazy.lua to import plugins in proper order

### 3. Keybinding Management
- ✅ Centralized common keybindings in `config/keymaps.lua`
- ✅ Grouped mode-specific keybindings
- ✅ Implemented consistent LSP keybindings in `config/lsp_keymaps.lua`
- ✅ Adopted structured keymap format with descriptions

### 4. Documentation & Config Quality
- ✅ Added header documentation for key files
- ✅ Improved code organization with sections
- ✅ Implemented better variable naming for clarity
- ✅ Added comments for complex configurations

## Improvement Areas

### 1. Complete Core/Lang/Ext Reorganization
- ⏳ Review all plugins for proper categorization between core, lang, and ext
- ⏳ Create init.lua files for lang and ext directories if needed
- ⏳ Ensure proper dependencies are maintained across categories
- ⏳ Standardize plugin spec format within each category

### 2. Configuration Consistency
- ⏳ Standardize plugin option formats across all plugin files
- ⏳ Adopt consistent mapping style for all keybindings
- ⏳ Establish consistent naming conventions for all config modules
- ⏳ Implement configuration validation for critical settings

### 3. Language Support Enhancement
- ⏳ Create a template system for adding new language support
- ⏳ Define standard components for each language (LSP, formatter, linter, etc.)
- ⏳ Implement consistent language-specific keybindings
- ⏳ Document workflow for adding support for new languages

### 4. Extension Management
- ⏳ Create a mechanism for easily enabling/disabling extensions
- ⏳ Standardize extension plugin interfaces
- ⏳ Document dependencies and requirements for each extension
- ⏳ Implement configuration defaults and customization for extensions

### 5. Documentation Enhancements
- ⏳ Generate comprehensive keymap documentation
- ⏳ Create plugin configuration reference by category
- ⏳ Document common workflows and use cases
- ⏳ Implement automatic config documentation generation

## Next Steps

### 1. Complete Core/Lang/Ext Structure
- Review remaining plugins for proper categorization
- Establish convention for plugin specs within each category
- Create README or index file for each category to document purpose
- Implement consistent importing pattern across all categories

### 2. Code Quality
- Implement stylua checks in a pre-commit hook
- Add configuration validation to prevent common errors
- Standardize option formatting across all plugin files
- Create a consistent structure for all plugin definitions

### 3. Language Support Framework
- Create template files for adding new language support
- Define standard components each language module should implement
- Document process for adding new language support
- Implement a system for conditionally loading language support

### 4. Extension System
- Create a system for easily toggling extensions
- Document extension dependencies and requirements
- Establish standard API for extensions to integrate with core
- Implement configuration UI for extensions

### 5. User Experience
- Implement custom welcome screen with common commands
- Create an interactive configuration wizard
- Develop better error reporting for plugin issues
- Add contextual help for available commands