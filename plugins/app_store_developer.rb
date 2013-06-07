# Usage: {% app_store_developer 626825948 %}

require 'cgi'
require 'open-uri'
require 'json'

module Jekyll

  class AppstoreDevTag < Liquid::Tag

    def initialize(tag_name, text, token)
      super
      @text = text
      @local_folder = File.expand_path "../.app_store_developer", File.dirname(__FILE__)
      FileUtils.mkdir_p @local_folder
    end

    def app_store_url_with_id(developer_id)
      "http://itunes.apple.com/cn/lookup?id=#{developer_id}&entity=software"
    end

    def render(context)
      if parts = @text.match(/([\d]*)/)
        app_store_id = parts[1].strip
        json = get_app_local_data(app_store_id) || get_app_store_data(app_store_id)
        html_output_for(json)
      else
        ""
      end
    end

    def html_output_for(json)
			json = json['results']
			json.shift

			result = ""
			result = result + <<-JS
<script type="text/javascript">
function app_li_mouse_in_out(img_id, image)
{
  document.getElementById(img_id).setAttribute("src", image)
}
</script>
                          JS

			json.each do |app|
				name = app['trackName']
				icon = app['artworkUrl512']
				link = app['trackViewUrl']
				bundleId = app['bundleId'].strip.gsub('.', '-').downcase
				qr_image = "http://chart.apis.google.com/chart?chs=120x120&cht=qr&chld=|0&chco=165B94&chl=#{link}"

				result = result + <<-HTML
<li onmouseover='app_li_mouse_in_out("img_#{bundleId}", "#{qr_image}")' onmouseout='app_li_mouse_in_out("img_#{bundleId}", "#{icon}")'>
<p style='text-align: center' align='center'>
<a class='#{bundleId}' href='#{link}' style='text-decoration: none !important' target='_blank'>
  <img id='img_#{bundleId}' src='#{icon}' class='#{bundleId}' style='width:120px; height:120px; vertical-align:middle; margin-left: auto; margin-right: auto; border: 0em; border-radius:22px' />
</a>
</p>
<p style='text-align: center'>
#{name}
</p>
</li>
                          HTML

			end

			result
    end

    def get_app_store_data(app_store_id)
      app_store_url = app_store_url_with_id(app_store_id)
      json = open(app_store_url).read

      local_file = get_local_file(app_store_id)
      File.open(local_file, "w") do |io|
        io.write json
      end

      JSON.parse(json)
    end

    # Local Copy

    def get_app_local_data(app_store_id)
      local_file = get_local_file(app_store_id)

      json = File.read local_file if File.exist? local_file
      return nil if json.nil?

      JSON.parse(json)
    end

    def get_local_file(app_store_id)
      File.join @local_folder, "#{app_store_id}.json"
    end

  end

end

Liquid::Template.register_tag('app_store_developer', Jekyll::AppstoreDevTag)
