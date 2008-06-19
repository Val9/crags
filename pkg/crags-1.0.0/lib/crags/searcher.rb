module Crags
  module Searcher
    def location_doc
      fetch_doc("http://geo.craigslist.org/iso/us")
    end

    def location_links
      location_doc.search("#list a")
    end

    def locations
      location_links.collect{|link| link["href"] }
    end

    def categories
      doc = fetch_doc("http://sfbay.craigslist.org/")
      links = doc.search("table[@summary=\"for sale\"] a")
      categories = {}
      links.each do |link|
        categories[link.inner_html] = link["href"]
      end
      categories
    end

    def search(keyword, category = 'sss')
      locations.collect do |loc|
        sleep(1 + rand(3))
        search_location(keyword, loc, category)
      end.flatten
    end

    def items(doc)
      doc.search("item")
    end

    def search_location(keyword, loc, category = 'sss')
      doc = fetch_doc("#{loc}search/#{category}?query=#{keyword}&format=rss")
      items(doc).collect do |item|
        create_link(item)
      end
    end

    def fetch_doc(url)
      Hpricot.parse(fetch_html(url))
    end

    def fetch_html(url)
      Curl::Easy.perform(url).body_str
    end

    def create_link(item)
      link = item["rdf:about"]
      title = item.at("title").inner_text
      "<a href=\"#{link}\">#{title}</a>"
    end
  end
end