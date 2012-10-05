module Sinatra
	module QRHelper
		def qr_code(url)
			url = URI.encode "#{$baseurl}#{url}"
			"<img src='http://api.qrserver.com/v1/create-qr-code/?data=#{url}&size=250x250'/>"
		end

		def qr_tag(tag)
			url = "/qr/#{tag.code}"
			"<div class='tag'> #{qr_code(url)} <p class='tag_name'>#{tag.name}</p> </div> "
		end
	end

	helpers QRHelper
end
