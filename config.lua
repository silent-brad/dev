local links = require "links"
local projects = require "projects"

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
  { output = "posts.html", template = "posts.html" },
  { output = "404.html", template = "404.html" },
  { output = "rss.xml", template = "rss.xml", collections = { "posts" } },
  {
    output = "sites.html",
    template = "sites.html",
    args = {
      heading = "Favorite Dev Sites (mostly blogs)",
      links = links,
    },
  },
  {
    output = "projects.html",
    template = "projects.html",
    args = {
      heading = "My Dev Projects",
      projects = projects,
    },
  },
}

tag_pages = {
  template = "tag.html",
  permalink = "/tags/:tag",
}
