-- Testing framework: neotest
--
-- This module provides a unified interface for running tests across different
-- languages and frameworks.

local add = MiniDeps.add

-- Core neotest and dependencies
add({
	source = "nvim-neotest/neotest",
	depends = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-neotest/nvim-nio",
	},
})

-- Adapters
add("orjangj/neotest-ctest")

local catch2_adapter = function()
	local lib = require("neotest.lib")
	local async = require("neotest.async")
	local Path = require("plenary.path")
	local nio = require("nio")
	local sep = lib.files.sep

	local adapter = { name = "catch2" }

	-- Helper function to strip leading/trailing quotes from test names
	local function clean_name(name)
		return name:gsub("^[\"']", ""):gsub("[\"']$", "")
	end

	-- TreeSitter queries for Catch2
	--
	-- IMPORTANT: In C++ tree-sitter, macros like TEST_CASE("name") { ... } parse as:
	--   (expression_statement (call_expression ...))  <-- sibling -->  (compound_statement)
	-- The call_expression is INSIDE an expression_statement, and the compound_statement
	-- (the body block) is a sibling of that expression_statement, NOT of the call_expression.
	--
	-- We capture @test.statement (the expression_statement) and @test.body (the compound_statement)
	-- separately, then combine their ranges in build_position so the parent range encompasses
	-- children. Without this, neotest's range containment check fails and nesting breaks.
	local query = [[
    ;; Top-level or nested test macros with a body block
    (
      (expression_statement
        (call_expression
          function: (identifier) @test.kind
          arguments: (argument_list
            . (string_literal) @test.name
            . (string_literal)? @test.tags
          )
          (#any-of? @test.kind "TEST_CASE" "TEST_CASE_METHOD" "SCENARIO" "SECTION" "GIVEN" "WHEN" "THEN" "AND_GIVEN" "AND_WHEN" "AND_THEN")
        )
      ) @test.statement
      . (compound_statement) @test.body
    )
  ]]

	local get_build_dir = function()
		local ok, cmake_tools = pcall(require, "cmake-tools")
		if ok then
			local build_dir = cmake_tools.get_build_directory()
			if build_dir and build_dir ~= "" then
				return build_dir
			end
			-- Fallback to alternative API
			build_dir = cmake_tools.get_build_directory_path()
			if build_dir and build_dir ~= "" then
				return build_dir
			end
		end
		-- Fallback to default
		return vim.fn.getcwd() .. "/build"
	end

	function adapter.root(dir)
		local patterns = { "CMakeLists.txt" }
		local start_path = dir
		local start_parents = Path:new(start_path):parents()
		local home = os.getenv("HOME")
		local potential_roots = lib.files.is_dir(start_path) and vim.list_extend({ start_path }, start_parents)
			or start_parents

		for index = #potential_roots, 1, -1 do
			local path = potential_roots[index]
			if path ~= home then
				for _, pattern in ipairs(patterns) do
					for _, p in ipairs(nio.fn.glob(Path:new(path, pattern).filename, true, true)) do
						if lib.files.exists(p) then
							return path
						end
					end
				end
			end
		end
	end

	function adapter.is_test_file(file_path)
		if not file_path:match("%.cpp$") and not file_path:match("%.hpp$") then
			return false
		end
		-- Check for Catch2 includes as a marker for prioritization
		local f = io.open(file_path, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content:find("catch2/") or content:find("CATCH_CONFIG_MAIN") then
				return true
			end
		end
		return false
	end

	local function get_executable_for_file(file_path)
		local root = adapter.root(file_path)
		local build_dir = get_build_dir()

		-- Make the file path relative to the root
		local rel_path = Path:new(file_path):make_relative(root)

		-- Strip the extension (.cpp, .hpp)
		local rel_path_without_ext = rel_path:gsub("%.cpp$", ""):gsub("%.hpp$", "")

		-- Construct the expected binary path
		local expected_binary = build_dir / rel_path_without_ext

		-- If the binary exists, return its absolute path
		if expected_binary:exists() then
			return expected_binary.filename
		end

		-- Fallback: Try to get target from cmake-tools
		local ok, cmake_tools = pcall(require, "cmake-tools")
		if ok then
			local target = cmake_tools.get_build_target()
			if target then
				return (Path:new(build_dir) / target).filename
			end
		end

		return nil
	end

	-- Custom build_position that combines @test.statement and @test.body ranges.
	-- This ensures TEST_CASE range spans its entire { ... } block, so neotest's
	-- range containment correctly nests SECTIONs inside their parent TEST_CASE.
	local function build_position(file_path, source, captured_nodes)
		if captured_nodes["test.name"] then
			local name = vim.treesitter.get_node_text(captured_nodes["test.name"], source)
			local kind = captured_nodes["test.kind"]
				and vim.treesitter.get_node_text(captured_nodes["test.kind"], source)

			-- Catch2 BDD: SCENARIO prepends "Scenario: "
			if kind == "SCENARIO" then
				name = "Scenario: " .. name
			end

			-- Combine statement + body ranges for full span
			local stmt = captured_nodes["test.statement"]
			local body = captured_nodes["test.body"]
			local start_row, start_col, end_row, end_col
			if stmt and body then
				local sr, sc = stmt:range()
				local _, _, er, ec = body:range()
				start_row, start_col, end_row, end_col = sr, sc, er, ec
			elseif stmt then
				start_row, start_col, end_row, end_col = stmt:range()
			else
				-- Shouldn't happen, but fallback
				return nil
			end

			return {
				type = "test",
				path = file_path,
				name = name,
				range = { start_row, start_col, end_row, end_col },
			}
		end
		return nil
	end

	function adapter.discover_positions(path)
		local tree = lib.treesitter.parse_positions(path, query, {
			nested_tests = true,
			build_position = build_position,
		})

		return tree
	end

	function adapter.build_spec(args)
		local build_dir = get_build_dir()

		-- Helper function to create a spec for a given position
		local function create_spec(pos)
			local executable = get_executable_for_file(pos.path)
			if not executable then
				return nil
			end

			local xml_file = async.fn.tempname() .. ".xml"
			-- Use dual reporters: console to stdout (for neotest output panel) + xml to file (for result parsing)
			local command = { executable, "--reporter", "console", "--reporter", "xml::out=" .. xml_file }

			-- Add test specification if running a specific test
			if pos.type == "test" then
				-- Walk up the tree to collect the full test path
				-- For a SECTION inside a TEST_CASE, Catch2 needs:
				--   -n "test case name" -c "section name" [-c "nested section" ...]
				local current = args.tree
				local sections = nil
				local test_case_name = nil

				-- Walk from current node up to file/dir to collect ancestors
				while current do
					local data = current:data()
					if data.type == "test" then
						local parent = current:parent()
						if parent and parent:data().type == "test" then
							-- This is a section (has a test parent)
							if sections == nil then
								sections = { clean_name(data.name) }
							else
								table.insert(sections, clean_name(data.name))
							end
						else
							-- This is the top-level test case
							test_case_name = clean_name(data.name)
						end
					end
					current = current:parent()
				end

				if sections == nil then
					sections = {}
				end

				if test_case_name then
					table.insert(command, "-n")
					table.insert(command, test_case_name)
				end
				for _, section_name in ipairs(sections) do
					table.insert(command, "-c")
					table.insert(command, section_name)
				end
			end

			local spec = {
				command = command,
				cwd = build_dir.filename,
				context = {
					xml_file = xml_file,
				},
			}

			-- Support DAP strategy
			if args.strategy == "dap" then
				local program = table.remove(command, 1)
				table.insert(command, "-b")
				spec.strategy = {
					name = "Launch",
					type = "codelldb",
					request = "launch",
					program = program,
					cwd = spec.cwd,
					stopOnEntry = false,
					args = command,
				}
				spec.command = nil
			end

			return spec
		end

		local position = args.tree:data()

		-- For directory/namespace runs, return nil to let neotest's built-in
		-- _run_broken_down_tree handle it. It will call build_spec once per file
		-- with the correct per-file tree, avoiding process key conflicts and
		-- ensuring each file gets its own isolated run.
		if position.type == "dir" or position.type == "namespace" then
			return nil
		end

		-- Handle file and test runs
		return create_spec(position)
	end

	function adapter.results(spec, result, tree)
		local xml_file = spec.context and spec.context.xml_file or spec.xml_file
		if not xml_file or not lib.files.exists(xml_file) then
			return {}
		end

		local content = lib.files.read(xml_file)
		local xml = lib.xml.parse(content)

		-- Helper function to handle both single elements and lists
		local function to_list(item)
			if not item then
				return {}
			end
			if type(item) == "table" and item[1] then
				return item
			else
				return { item }
			end
		end

		-- Helper function to parse error messages and line numbers from XML Expression/Failure elements
		local function parse_errors(testcase)
			local errors = {}

			-- Handle Expression elements (assertions)
			if testcase.Expression then
				local expressions = to_list(testcase.Expression)
				for _, expr in ipairs(expressions) do
					if expr._attr and expr._attr.success == "false" then
						local msg = "Expression failed"
						if expr.Original then
							msg = tostring(expr.Original[1] or expr.Original)
						end
						if expr.Expanded then
							msg = msg .. " => " .. tostring(expr.Expanded[1] or expr.Expanded)
						end
						local error_info = {
							message = msg,
						}
						-- Extract line number if available
						if expr._attr.line then
							error_info.line = tonumber(expr._attr.line) - 1 -- Adjust for 0-based indexing
						end
						table.insert(errors, error_info)
					end
				end
			end

			-- Handle Failure elements
			if testcase.Failure then
				local failures = to_list(testcase.Failure)
				for _, failure in ipairs(failures) do
					local error_info = {
						message = failure._attr and failure._attr.message or "Test failed",
					}
					-- Extract filename and line number if available
					if failure._attr.filename then
						error_info.filename = failure._attr.filename
					end
					if failure._attr.line then
						error_info.line = tonumber(failure._attr.line) - 1 -- Adjust for 0-based indexing
					end
					table.insert(errors, error_info)
				end
			end

			return errors
		end

		-- Recursive helper to parse nested sections
		local function parse_sections(section_data, results_map)
			local section_name = section_data._attr.name
			local section_status = "failed"

			-- Check status with multiple fallbacks
			-- 1. Check OverallResult (singular) for success
			if section_data.OverallResult and section_data.OverallResult._attr.success == "true" then
				section_status = "passed"
			-- 2. Check OverallResults (plural) for failure count
			elseif section_data.OverallResults and tonumber(section_data.OverallResults._attr.failures) == 0 then
				section_status = "passed"
			-- 3. Check status attribute directly
			elseif
				section_data._attr and (section_data._attr.status == "passed" or section_data._attr.status == "run")
			then
				section_status = "passed"
			end

			-- Parse errors from XML elements
			local errors = parse_errors(section_data)

			-- Extract section output if available
			local section_output = ""
			if section_data.Output then
				section_output = section_data.Output[1] or ""
			end

			results_map[section_name] = {
				status = section_status,
				output = section_output,
				errors = errors,
			}

			-- Recursively process nested sections
			local nested_sections = to_list(section_data.Section)
			for _, nested_section in ipairs(nested_sections) do
				parse_sections(nested_section, results_map)
			end
		end

		-- Recursive helper to collect all test/section results into a flat map
		local function collect_results(xml_data, results_map)
			-- Handle Catch2TestRun root element
			if xml_data.Catch2TestRun then
				collect_results(xml_data.Catch2TestRun, results_map)
				return
			end

			-- Process TestSuite elements (if they exist)
			local test_suites = to_list(xml_data.TestSuite)
			for _, test_suite in ipairs(test_suites) do
				local test_cases = to_list(test_suite.TestCase)
				for _, testcase in ipairs(test_cases) do
					local test_name = testcase._attr.name
					local result_status = "failed"

					-- Check status with multiple fallbacks
					-- 1. Check OverallResult (singular) for success
					if testcase.OverallResult and testcase.OverallResult._attr.success == "true" then
						result_status = "passed"
					-- 2. Check OverallResults (plural) for success
					elseif testcase.OverallResults and testcase.OverallResults._attr.success == "true" then
						result_status = "passed"
					-- 3. Check status attribute directly
					elseif testcase._attr and (testcase._attr.status == "passed" or testcase._attr.status == "run") then
						result_status = "passed"
					end

					-- Parse errors from XML elements
					local errors = parse_errors(testcase)

					-- Extract test output if available
					local test_output = ""
					if testcase.Output then
						test_output = testcase.Output[1] or ""
					end

					results_map[test_name] = {
						status = result_status,
						output = test_output,
						errors = errors,
					}

					-- Process nested Section elements recursively
					local sections = to_list(testcase.Section)
					for _, section in ipairs(sections) do
						parse_sections(section, results_map)
					end
				end
			end

			-- Also handle TestCase elements directly (without TestSuite)
			if xml_data.TestCase then
				local test_cases = to_list(xml_data.TestCase)
				for _, testcase in ipairs(test_cases) do
					local test_name = testcase._attr.name
					local result_status = "failed"

					-- Check status with multiple fallbacks
					-- 1. Check OverallResult (singular) for success
					if testcase.OverallResult and testcase.OverallResult._attr.success == "true" then
						result_status = "passed"
					-- 2. Check OverallResults (plural) for success
					elseif testcase.OverallResults and testcase.OverallResults._attr.success == "true" then
						result_status = "passed"
					-- 3. Check status attribute directly
					elseif testcase._attr and (testcase._attr.status == "passed" or testcase._attr.status == "run") then
						result_status = "passed"
					end

					-- Parse errors from XML elements
					local errors = parse_errors(testcase)

					-- Extract test output if available
					local test_output = ""
					if testcase.Output then
						test_output = testcase.Output[1] or ""
					end

					results_map[test_name] = {
						status = result_status,
						output = test_output,
						errors = errors,
					}

					-- Process nested Section elements recursively
					local sections = to_list(testcase.Section)
					for _, section in ipairs(sections) do
						parse_sections(section, results_map)
					end
				end
			end
		end

		-- Collect all results into a flat map indexed by name
		local all_results = {}
		collect_results(xml, all_results)

		-- Map results to neotest node IDs by iterating over the tree
		-- result.output is the path to the file containing captured stdout/stderr
		local output_file = result.output
		local results = {}
		for _, node in tree:iter_nodes() do
			local node_data = node:data()
			if node_data.type == "test" and node_data.name then
				local node_id = node_data.id
				local cleaned_node_name = clean_name(node_data.name)

				-- Look up the cleaned test name in the collected results map
				if all_results[cleaned_node_name] then
					results[node_id] = {
						status = all_results[cleaned_node_name].status,
						output = output_file,
						errors = all_results[cleaned_node_name].errors,
					}
				end
			end
		end

		-- Bottom-up status aggregation for all non-test nodes (file, namespace, dir)
		for _, node in tree:iter_nodes() do
			local node_data = node:data()
			if node_data.type ~= "test" then
				local node_id = node_data.id
				if not results[node_id] then
					local node_status = "passed"
					local has_test_results = false

					-- Check all descendant test nodes
					for _, child in node:iter_nodes() do
						local child_data = child:data()
						if child_data.type == "test" then
							local child_res = results[child_data.id]
							if child_res then
								has_test_results = true
								if child_res.status == "failed" then
									node_status = "failed"
									break
								end
							end
						end
					end

					if has_test_results then
						results[node_id] = {
							status = node_status,
							output = output_file,
						}
					else
						-- Fallback to overall result status if no tests were found in the subtree
						results[node_id] = {
							status = result.status,
							output = output_file,
						}
					end
				end
			end
		end

		return results
	end

	return adapter
end

-- Extensible adapter table
local neotest = require("neotest")
local adapters = {
	catch2_adapter(),
	require("neotest-ctest").setup({}),
}

neotest.setup({
	adapters = adapters,
	status = { virtual_text = true },
	output = { open_on_run = true },
})

-- Testing keymaps
vim.keymap.set("n", "<leader>tr", function()
	neotest.run.run()
end, { desc = "Test: Run nearest" })

vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("% "))
end, { desc = "Test: Run file" })

vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Test: Toggle summary" })

vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true })
end, { desc = "Test: Show output" })

vim.keymap.set("n", "<leader>td", function()
	require("neotest").run.run({ strategy = "dap" })
end, { desc = "Test: Debug nearest" })
