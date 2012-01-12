#
#  tinyurl.rb
#

module FiniteBot
  class TinyURL
    include Cinch::Plugin

    listen_to :message

    def title(url)
      html = open(url).read rescue OpenURI::HTTPError

      unless html.nil?
        title = %r{<title>(.*)</title>}m.match(html)[1]
        title.squeeze(" ").gsub("\r"," ").gsub("\n"," ").squeeze(" ").strip
      end
    end

    def shorten(url)
      url = open("#{APP_CONFIG[:tinyurl][:server_url]}#{URI.escape(url)}").read
      url == "Error" ? nil : url
    rescue OpenURI::HTTPError
      nil
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])

      unless urls.first.nil?
        unless urls.first.size < (APP_CONFIG[:tinyurl][:minimum_characters] || 25)
          unless APP_CONFIG[:tinyurl][:display_titles].nil? or APP_CONFIG[:tinyurl][:display_titles] == false
            short_urls = urls.map { |url|
              cur_title = title(url) ? title(url) : nil rescue nil

              output = shorten(url)
              output = output + " -- " + cur_title unless cur_title.nil?
              output
              }.compact
            end
            m.reply short_urls.join(", ") unless short_urls.empty?
        end
      end
    end
  end
end