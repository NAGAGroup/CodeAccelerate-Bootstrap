--[[
=====================================================================
               Neovim Configuration - Performance Profiler
=====================================================================
This module provides utilities for profiling Neovim performance.
]]

local M = {}

-- Keep track of started modules and their times
M.module_load_times = {}
M.startup_time = nil

-- Initialize profiling
function M.init()
  -- Record initial startup time
  M.startup_time = vim.loop.hrtime()
end

-- Track module load time
function M.track_module_load(module_name)
  local start_time = vim.loop.hrtime()
  
  -- Return a function to call when module loading is complete
  return function()
    local end_time = vim.loop.hrtime()
    local elapsed_ms = (end_time - start_time) / 1000000 -- Convert to milliseconds
    
    -- Store module load time
    M.module_load_times[module_name] = elapsed_ms
  end
end

-- Print module load times
function M.print_module_load_times()
  -- Sort modules by load time
  local sorted_modules = {}
  for module, time in pairs(M.module_load_times) do
    table.insert(sorted_modules, { name = module, time = time })
  end
  
  table.sort(sorted_modules, function(a, b)
    return a.time > b.time
  end)
  
  -- Print results
  print("=== Module Load Times ===")
  for _, module in ipairs(sorted_modules) do
    print(string.format("%-30s: %.2f ms", module.name, module.time))
  end
  
  -- Print total startup time
  if M.startup_time then
    local total_time = (vim.loop.hrtime() - M.startup_time) / 1000000
    print(string.format("\nTotal startup time: %.2f ms", total_time))
  end
end

-- Profile a function execution
function M.profile_function(func, name, iterations)
  iterations = iterations or 1
  name = name or "Function"
  
  local total_time = 0
  
  for i = 1, iterations do
    local start_time = vim.loop.hrtime()
    local result = func()
    local end_time = vim.loop.hrtime()
    
    total_time = total_time + (end_time - start_time)
    
    if i == 1 then
      -- Return result from first run
      _G._profile_result = result
    end
  end
  
  local avg_time = (total_time / iterations) / 1000000 -- Convert to milliseconds
  
  print(string.format("%s: %.2f ms (avg of %d runs)", name, avg_time, iterations))
  
  return _G._profile_result
end

-- Enable Lua module profiling
function M.enable_module_profiling()
  -- Save original require function
  local original_require = _G.require
  
  -- Override require to track loading time
  _G.require = function(modname)
    local start_time = vim.loop.hrtime()
    local result = original_require(modname)
    local end_time = vim.loop.hrtime()
    
    -- Only track lua modules in our config
    if modname:match("^lua%.") or modname:match("^plugins%.") or 
       modname:match("^config%.") or modname:match("^utils%.") or
       modname:match("^themes%.") then
      M.module_load_times[modname] = (end_time - start_time) / 1000000
    end
    
    return result
  end
end

-- Disable Lua module profiling
function M.disable_module_profiling()
  -- Restore original require if it exists
  if _G._original_require then
    _G.require = _G._original_require
    _G._original_require = nil
  end
end

return M