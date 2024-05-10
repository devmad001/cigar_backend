module ActiveAdminHelper
  CHIRILIC_REGEXP = { 'data-inputmask-regex': '[^А-Яа-я]+' }

  def chirilic_regexp
    CHIRILIC_REGEXP
  end

  def monetize(value)
    int_value = 0

    case value.class.name
    when 'String'
      return value if value.include?('%')
      int_value = value.gsub(/[\.\,\$]/, '').to_i
    when 'Integer'
      int_value = value.to_i
    when nil.class.name

    end

    "#{ int_value / 100 }.#{ (int_value % 100).to_s.rjust 2, '0' }$"
  end
end
