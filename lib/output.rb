module Sinatra
	module OutputHelpers
		def format_date(date, format = nil)
			format = settings.datetime_format unless format
			date.strftime(format)
		end

		# esc_html constants
		ESC_HTML = {
			'&' => "&amp;",
			'<' => "&lt;",
			'>' => "&gt;",
			"'" => "&#x27;",
			'"' => "&quot;"
		}
		ESC_HTML_PATTERN = Regexp.union(*ESC_HTML.keys)

		def esc_html(string)
			string.to_s.gsub(ESC_HTML_PATTERN) { |c| ESC_HTML[c] }
		end
	end

	helpers OutputHelpers
end

