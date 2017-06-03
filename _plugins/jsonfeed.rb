module Jekyll
  class JSONFeedFile < StaticFile
    def initialize(site, base, dir, name, docs)
      super(site, site.source, dir, name)
      @docs = docs
    end

    def feed_data()
      markdown = @site.find_converter_instance(Jekyll::Converters::Markdown)
      smart = @site.find_converter_instance(Jekyll::Converters::SmartyPants)

      items = @docs.reverse.map do |doc|
        docurl = @site.config['url'] + doc.url
        {
          :id => docurl,
          :url => docurl,
          :title => smart.convert(doc.data['title']),
          :content_html => doc.content,
          :summary => markdown.convert(doc.data['excerpt']),
          :date_published => doc.date.to_datetime.rfc3339,
        }
      end

      {
        :version => "https://jsonfeed.org/version/1",
        :title => @site.config['name'],
        :home_page_url => @site.config['url'],
        :feed_url => @site.config['url'] + @dir + @name,
        :author => {
          :name => @site.config['author'],
          :url => @site.config['url'],
        },
        :items => items,
      }
    end

    def write(dest)
      dest_path = destination(dest)
      FileUtils.mkdir_p(File.dirname(dest_path))
      File.open(dest_path, "w") do |f|
        f.write JSON.pretty_generate(feed_data())
        # uglier: f.write feed_data().to_json
      end
    end
  end

  class JSONFeedGenerator < Generator
    safe true
    priority :low

    def generate(site)
      file = JSONFeedFile.new(site, site.source, "/", "feed.json",
                              site.collections["posts"].docs)
      site.static_files << file
    end
  end
end
