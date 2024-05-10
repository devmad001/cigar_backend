module LogHelper
  def log_error(*messages, **args)
    puts _log_line.red
    messages.flatten.each { |m| puts m.to_s.red }
    args.each { |k, m| puts "#{ k }: #{ m }".red }
    puts _log_line.red
  end

  def log_info(*messages, **args)
    puts _log_line
    messages.flatten.each { |m| puts m }
    args.each { |k, m| puts "#{ k }: #{ m }" }
    puts _log_line
  end

  def _log_line
    @_log_line ||= '=' * 80
  end
end
