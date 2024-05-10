module Sitemap
  class Generator
    SITEMAP_FILE_NAME = 'sitemap.xml'
    SITEMAP_LINK = File.join Rails.root, 'public', SITEMAP_FILE_NAME
    SITEMAPS_PARTS_PATH_EL = %w(sitemaps).freeze
    SITEMAP_PARTS_PATH =  File.join Rails.root, 'public', SITEMAPS_PARTS_PATH_EL.join('/')
    URLS_LIMIT = 2e4.to_i

    def initialize
      @date_dir = Date.today.strftime '%Y-%m-%d'
      @sitemap_parts = []
      @files_count = 0
      @urls_count = 0
      @current_file = nil
      @front_host = ENV['FRONT_HOST']

      dir!
      generate_parts!
      save_part!
      generate_sitemap_index!

      SystemSetting.single.update_attribute :sitemap, @date_dir

      clear_old!
    end

    def dir!
      dp = File.join SITEMAP_PARTS_PATH, @date_dir
      rmdir! File.join(dp, '*') if Dir.exist?(dp)
      dir_path = File.join Rails.root, 'public'

      (SITEMAPS_PARTS_PATH_EL + [@date_dir]).each do |dir_name|
        dir_path = File.join dir_path, dir_name
        Dir.mkdir dir_path unless Dir.exist?(dir_path)
      end
    end

    def file
      if @current_file.blank? || @urls_count >= URLS_LIMIT
        save_part!
        file_name = "sitemap-#{ @date_dir }-#{ @files_count += 1 }.xml"
        file_path = File.join SITEMAP_PARTS_PATH,
                              @date_dir,
                              file_name

        @current_file = File.open file_path, 'w'

        @current_file.puts '<?xml version="1.0" encoding="UTF-8"?>'
        @current_file.puts '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

        @sitemap_parts << File.join(SITEMAPS_PARTS_PATH_EL, @date_dir, file_name)
        @urls_count = 0
      end

      @current_file
    end

    def save_part!
      if @current_file.present? && @urls_count > 0
        @current_file.puts '</urlset>'
        @current_file&.close
        @urls_count = 0
      end
    end

    def date_format(date)
      case date.class.name
      when 'Date', 'DateTime', 'Time', 'ActiveSupport::TimeWithZone'
        date.strftime '%Y-%m-%d'
      when 'String'
        date
      else
        date
      end
    end

    def build_url(*path, host:)
      URI.join(host, File.join(*path)).to_s
    end

    def item_url(url, lastmod: nil, changefreq: 'daily', priority: nil)
      file.puts "\t<url>"
      file.puts "\t\t<loc>#{ url }</loc>" if url.present?
      file.puts "\t\t<lastmod>#{ date_format lastmod }</lastmod>" if lastmod.present?
      file.puts "\t\t<changefreq>#{ changefreq }</changefreq>" if changefreq.present?
      file.puts "\t\t<priority>#{ priority }</priority>" if priority.present?
      file.puts "\t</url>"

      @urls_count += 1
    end

    def generate_parts!
      return if @front_host.blank?

      %w(/ search-results privacy-policy terms-and-conditions help blog advertise-with-us news).each do |i|
        item_url build_url(i, host: @front_host),
                 lastmod: Date.today,
                 changefreq: 'weekly'
      end

      Category.find_each do |c|
        item_url build_url('categories', c.slug, host: @front_host),
                 lastmod: c.updated_at,
                 changefreq: 'weekly'
      end

      Article.find_each do |a|
        item_url build_url(a.article_type, a.slug, host: @front_host),
                 lastmod: a.updated_at,
                 changefreq: 'weekly'
      end

      Product.available_products.find_each do |p|
        item_url build_url('product', p.slug, host: @front_host),
                 lastmod: p.refreshed_at || p.updated_at
      end
    end

    def generate_sitemap_index!
      f = File.open SITEMAP_LINK, 'w'
      f.puts '<?xml version="1.0" encoding="UTF-8"?>'
      f.puts '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

      last_mod = "\t\t<lastmod>#{ @date_dir }</lastmod>"

      @sitemap_parts.each do |i|
        f.puts "\t<sitemap>"
        f.puts "\t\t<loc>#{ build_url i, host: @front_host }</loc>"
        f.puts last_mod
        f.puts "\t</sitemap>"
      end

      f.puts '</sitemapindex>'
      f.close
    end

    def rmdir!(dir_name)
      self.class.rmdir! dir_name
    end

    def clear_old!
      Dir[File.join SITEMAP_PARTS_PATH, '*'].each do |i|
        rmdir! i if i.exclude?(@date_dir)
      end
    end

    def self.generate!
      self.new
    end

    def self.rmdir!(dir_name)
      system "sudo rm -r #{ dir_name }"
    end
  end
end
