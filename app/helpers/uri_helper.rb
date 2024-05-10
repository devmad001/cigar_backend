module UriHelper
  # === URI parts ===
  #  proto   ||  $1
  #  host    ||  $2
  #  path    ||  $3
  #  query   ||  $4
  # =================
  URI_REGEXP = /^(?:(https?)?(?::\/\/)?((?:[-a-z0-9_]+\.)+[-a-z0-9_]+)?)?((?:\/+[-a-z0-9_\.,\[\]]+)+?)?\/*(?:\?([^\?]+))?$/i

  def canonize_uri(uri)
    return if uri.blank?
    URI.escape(Translit.convert(
      uri.to_s
          .downcase
          .strip
          .gsub(/\s*[×x]+\s*/, 'x')
          .gsub(/[\s\\\/|–]+/, '-')
          .gsub(/[%'"\[\]{}()*+^$#\@!<>:;?,`~]+/, '')
          .gsub(/&+/, 'and')
          .gsub(/-{2,}/, '-'),
      :english
    ))
  end

  def uri_parts(uri)
    if uri.try(:strip) =~ URI_REGEXP
      {
        proto: $1,
        host: $2,
        path: $3,
        query: $4
      }.compact_blank
    else
      {}
    end
  end
end
