class GetterShapeFromTitle
  VALID_SHAPES = [
    'Belicoso', 'Churchill', 'Cigarillos', 'Corona', 'Corona Extra', 'Culebra', 'Double Corona',
    'Double Perfecto', 'Double Robusto', 'Double Toro', 'Figurado', 'Gigante', 'Gordo',
    'Grand Robusto', 'Lancero', 'Lancero/Panatela', 'Lonsdale', 'Panatela', 'Perfecto', 'Petit',
    'Petite Corona', 'Presidente', 'Pyramid', 'Robusto', 'Rothchild', 'Rothschild',
    'Salomon', 'Short Robusto', 'Toro', 'Torpedo'
  ]
  VALID_SELLERS = ['Cigars International', 'Best Cigar Prices', 'Mike\'s Cigars']

  attr_accessor :from

  def initialize(from)
    @from = from
    @selected_shape = find_shape
  end

  def call
    each_shapes
  end

  private

  def each_shapes
    if is_product? && valid? && valid_seller?
      update_product!
    elsif is_hash? && valid? && valid_seller?
      update_attributes!
    end
  end

  def valid?
    VALID_SHAPES.any? { |shape| !title_has_shape?(shape.downcase) }
  end

  def is_product?
    @from.is_a? Product
  end

  def is_hash?
    @from.is_a? Hash
  end

  def title_has_shape?(shape)
    @from.try(:[], :title)&.downcase&.include?(shape)
  end

  def shape_fltr_eq_to?(shape)
    @from.try(:[], :shape_fltr)&.downcase == shape
  end

  def valid_shape?(shape)
    title_has_shape?(shape) && !shape_fltr_eq_to?(shape)
  end

  def valid_seller?
    VALID_SELLERS.include? @from.try(:[], :seller)
  end

  def update_product!
    return if @selected_shape.nil?
    @from.update(shape_fltr: @selected_shape, specifications: prepared_specs)
  end

  def update_attributes!
    @from[:shape_fltr] = @selected_shape
    @from[:specifications] = prepared_specs
  end

  def prepared_specs
    specs = @from.try(:[], :specifications)
    specs[:shape] = @selected_shape
    specs
  end

  def find_shape
    VALID_SHAPES.find {|shape| valid_shape?(shape.downcase) }
  end
end
