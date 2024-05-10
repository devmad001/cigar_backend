require 'meilisearch'

class MeilisearchClient
  PRODUCTS_INDEX_NAME = 'products'

  class << self
    def client
      @host ||= ENV['MEILISEARCH_HOST'] || 'http://127.0.0.1:7700'
      @master_key ||= ENV['MEILISEARCH_MASTER_KEY']
      @client ||= MeiliSearch::Client.new @host, @master_key
    end

    def product_index
      @index ||= client.index PRODUCTS_INDEX_NAME
    end

    def index_products!
      documents = []

      Product.available_products.select(:id, :title).find_each do |product|
        documents << product.attributes.deep_symbolize_keys

        if documents.count >= 100
          product_index.add_documents(documents)
          documents = []
        end
      end
    end

    def search_products(*args)
      product_index.search(*args)
    end

    def products_result_ids(*args)
      search_products(*args)
          &.deep_symbolize_keys
          &.dig(:hits)
          &.map { |i| i[:id] }
    end
  end
end
