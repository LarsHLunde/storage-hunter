#!/usr/bin/lua

-- MIT License
-- 
-- Copyright (c) 2019 Lars Hudson Lunde
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- Global variables
-- 1024*1024 = 1 GB
local cutoff = 1024*1024
local arg_folder_pos = 1

-- Ports from PyroAPI

function yes_or_no()
	local answer
	repeat
		io.write("Please answer with y for yes, or n for no: ")
		io.flush()
		answer=io.read()
	until answer=="y" or answer=="n"

	if answer == "y" then
		return true
	else
		return false
	end
end

function execute_return(command)
	local fp = assert(io.popen(command, "r"))
	local output = fp:read("*all")
	fp:close()
	return(output)
end


function string_split(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

-- Argument handler
if arg[1] == "-h" or arg[1] == "--help" then
	print("Usage: " .. arg[0] .. " [ARGUMENTS] [DIRECTORY]")
	print("Argument list:")
	print("  -e            example, not implemented yet")
	os.exit()
end

if arg[arg_folder_pos] == nil then
	arg[arg_folder_pos] = "./"
-- elseif arg[arg_folder_pos] == "/" or execute_return("pwd") == "/\n" then
-- 	print("!WARNING!")
-- 	print("You are about to scan your root directory disk usage")
-- 	print("This could take a long time")
-- 	print("It can also not be very effective unless done as root")
-- 	print("Are you sure you want to do this?")
-- 	if yes_or_no() == false then
-- 		os.exit()
-- 	end
else
	local r = execute_return("[ -d \"" .. arg[arg_folder_pos] .. "\" ] && echo \"1\"")
	if r:sub(1,1) ~= "1" then
		print("ERROR: Folder does not exist")
		os.exit()
	end
end


-- Program

function process_printer(i)
	local x = {}
	x[0] = "Processing . .."
	x[1] = "Processing .. ."
	x[2] = "Processing ..."
	io.write(x[i])
end


print("Processing ...")

local process_queue = {}

local t_results = {}
local results = {}


local t_filelist = string_split(execute_return("du -d 1 " .. arg[arg_folder_pos] .. " 2>/dev/null"),"\n")


for i = 1, #t_filelist-1 do
	if tonumber(string_split(t_filelist[i])[1]) ~= nil and tonumber(string_split(t_filelist[i])[1]) >= cutoff then
		process_queue[#process_queue+1] = string_split(t_filelist[i])[2]
		t_results[string_split(t_filelist[i])[2]] = string_split(t_filelist[i])[1]
	end
end


print("t_results")
print("================")
for key, val in pairs(t_results) do
	print(key.." : "..val)
end
print("================\n")

print("process_queue")
print("================")
for i = 1, #process_queue do
	print(process_queue[i])
end
print("================\n")

print("results")
print("================")
for i = 1, #results do
	print(results[i])
end
print("================\n")
