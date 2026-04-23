#!/usr/bin/env lua
--- Fetch Open Graph metadata for each link in links.lua and rewrite the file.

local links = dofile("links.lua")

local function fetch_html(url)
	local handle = io.popen(string.format("curl -sL -m 10 -A 'Mozilla/5.0' %q 2>/dev/null | head -c 65000", url))
	if not handle then
		return nil
	end
	local html = handle:read("*a")
	handle:close()
	return html
end

local function extract_meta(html, property)
	-- Match property="X" or name="X" with content="Y"
	local pat1 = "<meta[^>]-property=[\"']" .. property .. "[\"'][^>]-content=[\"']([^\"']-)[\"']"
	local pat2 = "<meta[^>]-content=[\"']([^\"']-)[\"'][^>]-property=[\"']" .. property .. "[\"']"
	local pat3 = "<meta[^>]-name=[\"']" .. property .. "[\"'][^>]-content=[\"']([^\"']-)[\"']"
	local pat4 = "<meta[^>]-content=[\"']([^\"']-)[\"'][^>]-name=[\"']" .. property .. "[\"']"
	return html:match(pat1) or html:match(pat2) or html:match(pat3) or html:match(pat4)
end

local function extract_title(html)
	return html:match("<title[^>]*>([^<]+)</title>")
end

local function lua_escape(s)
	if not s then
		return nil
	end
	s = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", " "):gsub("%s+", " ")
	return s:match("^%s*(.-)%s*$")
end

for _, link in ipairs(links) do
	io.write("Fetching: " .. link.url .. "\n")
	local html = fetch_html(link.url)
	if html and #html > 0 then
		local og_title = extract_meta(html, "og:title")
		local og_desc = extract_meta(html, "og:description") or extract_meta(html, "description")
		local og_image = extract_meta(html, "og:image")

		if not og_title then
			og_title = extract_title(html)
		end

		link.og_title = lua_escape(og_title)
		link.og_desc = lua_escape(og_desc)
		link.og_image = lua_escape(og_image)
	else
		io.write("  ⚠ Failed to fetch " .. link.url .. "\n")
	end
end

-- Write back to links.lua
local f = io.open("links.lua", "w")
f:write("return {\n")
for _, link in ipairs(links) do
	local parts = {}
	parts[#parts + 1] = string.format('name = "%s"', link.name)
	parts[#parts + 1] = string.format('url = "%s"', link.url)
	if link.og_title then
		parts[#parts + 1] = string.format('og_title = "%s"', link.og_title)
	end
	if link.og_desc then
		parts[#parts + 1] = string.format('og_desc = "%s"', link.og_desc)
	end
	if link.og_image then
		parts[#parts + 1] = string.format('og_image = "%s"', link.og_image)
	end
	f:write("\t{ " .. table.concat(parts, ", ") .. " },\n")
end
f:write("}\n")
f:close()

io.write(string.format("\n✓ Updated links.lua with OG metadata for %d links.\n", #links))
