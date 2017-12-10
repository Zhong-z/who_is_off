require 'httparty'
require 'nokogiri'

class WhosOff
  SLACK_POST_URL = ENV['SLACK_WEBHOOK_URL'].freeze
  BAMBOO_API_URL = "https://#{ENV['BAMBOOHR_API_KEY']}:x@api.bamboohr.com/api/gateway.php/shippit/v1/time_off/whos_out/".freeze

  def self.update
    names = whosoff
    text = if names.any?
             "*Who's off today:* #{names.join(', ')}"
           else
             'Nobody is off today! :tada:'
           end
    post_to_slack(text: text)
  end

  def self.whosoff(day: Date.today)
    response = HTTParty.get("#{BAMBOO_API_URL}?end=#{day}")
    xml_doc = Nokogiri::XML(response.body)
    xml_doc.xpath('//item/employee').map(&:inner_text)
  end

  def self.post_to_slack(text: nil)
    headers = { 'Content-Type' => 'application/json' }
    body = { text: text }
    HTTParty.post(SLACK_POST_URL, body: body.to_json, headers: headers)
  end
end
