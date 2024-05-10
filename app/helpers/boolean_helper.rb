module BooleanHelper
  def false?(value)
    %w(false no 0).include? value.to_s.downcase
  end

  def true?(value)
    !self.false?(value)
  end

  def boolean?(value)
    %w(TrueClass FalseClass Integer).include?(value.class.to_s) || value.present? &&
        (%w(true false yes no).include?(value.to_s.downcase) || value.match(/^\s*\d+\s*$/).present?)
  end
end
