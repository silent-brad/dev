local links = require("links")

site = {
	name = "Brad White",
	subtitle = "Fullstack Software Artisan",
	-- base_url = "https://knightoffaith.systems",
	base_url = "",
}

templates_dir = "templates"
static_dir = "static"

collections = {
	posts = {
		dir = "content/posts",
		template = "post.html",
		permalink = "/:slug",
		item_var = "post",
		sort_by = "date",
		sort_order = "desc",
	},
}

pages = {
	{ output = "index.html", template = "index.html" },
	{ output = "404.html", template = "404.html" },
	{ output = "rss.xml", template = "rss.xml", collections = { "posts" } },
	{ output = "tags.html", template = "tags.html" },
	{
		output = "sites.html",
		template = "sites.html",
		args = {
			heading = "Favorite Dev Sites (mostly blogs)",
			links = links,
		},
	},
}

tag_pages = {
	template = "tag.html",
	permalink = "/tags/:tag",
}
