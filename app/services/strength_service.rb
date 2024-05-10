class StrengthService < AttributeService
  STRENGTH = {
    'Full' => [
      'Full',
      'FULL'
    ],
    'Medium' => [
      'Medium',
      'MEDIUM',
      'Medium Wrapper',
      'Medium Tobacco'
    ],
    'Medium Full' => [
      'Medium Full',
      'Medium - Full',
      'Medium-Full',
      'Medium, Medium-Full',
      'MEDIUM TO FULL'
    ],
    'Mild' => [
      'Mellow',
      'Mild',
      'MILD',
      'Cigarillo',
      'Light'
    ],
    'Mild-Medium' => [
      'Mellow - Medium',
      'Mellow-medium',
      'Mild-Medium',
      'MILD TO MEDIUM'
    ],
    'Varies' => [
      'Undisclosed',
      'Unknown',
      'Varies',
      'VARIES',
      'Various'
    ]
  }

  def self.merge!
    STRENGTH.each do |strength, names|
      names.each do |name|
        Product.where('strength_fltr ILIKE ?', name).update_all strength_fltr: strength if strength != name
      end
    end

    %w(strength).each do |key|
      Product.where("specifications ? '#{ key }'").each do |product|
        product.specifications[key] = strength product.specifications[key]
        product.save if product.changed?
      end
    end
  end

  def self.strength(_strength)
    self.select_name _strength, STRENGTH
  end
end
