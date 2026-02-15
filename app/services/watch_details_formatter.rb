# frozen_string_literal: true

class WatchDetailsFormatter
  def self.format(watch_response)
    return [] if watch_response.blank?
    return [] if watch_response.is_a?(Hash) && watch_response[:error]

    sources = extract_sources(watch_response)
    return [] unless sources.is_a?(Array)

    sources.filter_map { |item| format_option(item) }
  end

  def self.extract_sources(response)
    return response if response.is_a?(Array)

    if response.is_a?(Hash)
      raw = response[:sources] || response["sources"]
      return raw if raw.is_a?(Array)

      return JSON.parse(raw, symbolize_names: true) if raw.is_a?(String)
    end

    []
  end

  def self.format_option(item)
    {
      source_id: item[:source_id] || item["source_id"],
      name: item[:name] || item["name"],
      type: item[:type] || item["type"],
      region: item[:region] || item["region"],
      format: item[:format] || item["format"],
      price: (item[:price] || item["price"])&.to_f,
      web_url: item[:web_url] || item["web_url"]
    }.compact
  end
end
