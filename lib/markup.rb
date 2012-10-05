module Sinatra
	module MarkupHelpers
		def tag(name, opts = {})
			[:checked, :disabled, :selected, :multiple].each do |attr|
				opts[attr] = attr.to_s if opts[attr]
			end

			content = opts.delete(:content)

			opts[:class] = opts[:class].join(' ') if opts[:class].is_a?(Array)
			attributes = opts.map do |k,v|
				v != false ? "#{k.to_s}=\"#{esc_html(v)}\"" : nil
			end
			attributes = ' ' + attributes.join(' ') if attributes.size > 0

			"<#{name}#{attributes}" + (content ? ">#{content}</#{name}>" : " />")
		end

		def content_tag(name, *args, &block)
			opts = args.last.is_a?(Hash) ? args.pop : {}
			content = block_given? ? capture_html(&block) : args.shift || ''
			content = "\n" + content.gsub(/^/, '  ') unless [:textarea, :pre].include?(name)
			content = esc_html(content) if name == :textarea
			html = tag(name, opts.merge(:content => content))
			block_is_haml?(block) ? haml_concat(html) : html
		end

		def link_to(uri, text = nil, opts = {})
			if uri.respond_to?(:to_uri)
				text = uri.to_s unless text
				uri = uri.to_uri
			end

			text = uri.gsub(%r{\A(?:https?:/)?/(.+?)/?\Z}, '\1') unless text

			tag(:a, opts.merge({ :content => text, :href => uri }))
		end

		def capture_html(*args, &block)
			if is_haml? && block_is_haml?(block)
				 capture_haml(*args, &block)
			else
				block.call(*args)
			end
		end
	end

	helpers MarkupHelpers
end

