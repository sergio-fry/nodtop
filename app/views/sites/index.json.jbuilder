json.array!(@sites) do |site|
  json.extract! site, :id, :title, :domain, :rating
  json.url site_url(site, format: :json)
end
