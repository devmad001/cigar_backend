class CountryService < AttributeService
  COUNTRIES = {
    'Brazil' => [
      'Brazil',
      'BRAZIL',
      'brazil'
    ],
    'Belgium' => ['belgium'],
    'Bahamas' => [
      'bahamas',
      'Bahamas'
    ],
    'Costa Rica' => [
      'Costa Rica',
      'COSTA RICA'
    ],
    'Denmark' => ['denmark'],
    'Dominican' => [
      'dominican',
      'Dominican',
      'Dominican Republic',
      'DOMINICAN REPUBLIC',
      'DOMINICAN REPUBLIC, HONDURAS',
      'Dominican Republic, Nicaragua',
      'Dominican Republic; Nicaragua'
    ],
    'Ecuador' => [
      'Ecuador',
      'Ecuador, Europe',
      'Ecuador; Europe'
    ],
    'Europe' => [
      'Europe',
      'EUROPE',
      'Europe, Honduras',
      'European Union',
      'Europe; Honduras'
    ],
    'Honduras' => [
      'honduras',
      'Honduras',
      'HONDURAS',
      'Honduras, Nicaragua',
      'Honduras, Nicaragua',
      'Honduras; Nicaragua'
    ],
    'Indonesia' => ['indonesia'],
    'Ireland' => ['ireland'],
    'Italy' => ['italy'],
    'Mexico' => ['mexico', 'mexico; nicaragua'],
    'Netherlands' => [
      'Netherlands',
      'NETHERLANDS, SWITZERLAND',
      'Holland'
    ],
    'Nicaragua' => [
      'nicaragua',
      'Nicaragua',
      'NICARAGUA',
      'Nicaraguan',
      'Nicaragua, United States',
      'Nicaragua; United States',
      'dnicaragua'
    ],
    'Philippines' => ['philippines'],
    'Puerto Rico' => ['puerto rico'],
    'Switzerland' => [
      'switzerland',
      'Switzerland',
      'SWITZERLAND'
    ],
    'Sumatra' => ['sumatra'],
    'Spain' => ['spain'],
    'Sri Lanka' => ['sri lanka'],
    'USA' => [
      'United States',
      'USA',
      'united states'
    ],
    'Varies' => [
      'Varies',
      'VARIES',
      'Various'
    ],
    'Germany' => [
      'Germany',
      'Germany, Honduras'
    ]
  }

  def self.merge!
    COUNTRIES.each do |country, names|
      names.each do |name|
        Product.where('country_fltr ILIKE ?', name).update_all country_fltr: country if country != name
      end
    end

    %w(origin country).each do |key|
      Product.where("specifications ? '#{ key }'").each do |product|
        product.specifications[key] = country product.specifications[key]
        product.save if product.changed?
      end
    end

    Product.pluck(:country_fltr).uniq.compact.each do |country_fltr|
      Product
          .where(country_fltr: country_fltr)
          .update_all(country_fltr: country(country_fltr))
    end
  end

  def self.country(_country)
    self.select_name _country, COUNTRIES
  end
end
