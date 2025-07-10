--[[ 
=====================================================================
             Neovim Configuration - Compatibility Utilities
=====================================================================
This module provides compatibility with the old utils.lua functions.
It contains the functions from the original utils.lua to ensure
backward compatibility during the refactoring process.
]]

-- Load the old utils module
local old_utils = require('utils.utils')

-- Return the old utils module directly for compatibility
return old_utils