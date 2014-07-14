require "net/http"

module Meteo
  module Lib
    def get_url(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.code == '200'
        response.body
      end
    end
  end
end
