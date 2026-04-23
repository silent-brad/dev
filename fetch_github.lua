#!/usr/bin/env lua
--- Fetch GitHub contribution data and write to static/github-contributions.json

local function load_dotenv(path)
	local env = {}
	local f = io.open(path, "r")
	if f then
		for line in f:lines() do
			local k, v = line:match("^([%w_]+)=(.*)$")
			if k then
				env[k] = v
			end
		end
		f:close()
	end
	return env
end

local dotenv = load_dotenv(".env")
local token = dotenv["GITHUB_TOKEN"] or os.getenv("GITHUB_TOKEN")

if not token or token == "" or token == "your_github_token_here" then
	io.write("⚠ No GITHUB_TOKEN set. Skipping contribution fetch.\n")
	os.exit(0)
end

local username = "silent-brad"

local query = string.format(
	'{"query":"{ user(login: \\"%s\\") { contributionsCollection { contributionCalendar { totalContributions weeks { contributionDays { contributionCount date weekday } } } } repositories(ownerAffiliations: OWNER, isFork: false, privacy: PUBLIC, first: 100, orderBy: {field: UPDATED_AT, direction: DESC}) { nodes { languages(first: 10, orderBy: {field: SIZE, direction: DESC}) { edges { size node { name color } } } } } } }"}',
	username
)

local cmd = string.format(
	"curl -s -H 'Authorization: bearer %s' -H 'Content-Type: application/json' -X POST -d '%s' https://api.github.com/graphql 2>/dev/null",
	token,
	query
)

io.write("Fetching GitHub contributions for " .. username .. "...\n")

local handle = io.popen(cmd)
if not handle then
	io.write("⚠ Failed to run curl.\n")
	os.exit(1)
end

local response = handle:read("*a")
handle:close()

if not response or #response == 0 then
	io.write("⚠ Empty response from GitHub API.\n")
	os.exit(1)
end

-- Write raw JSON response to static dir
local f = io.open("static/github-contributions.json", "w")
f:write(response)
f:close()

io.write("✓ Wrote static/github-contributions.json\n")
