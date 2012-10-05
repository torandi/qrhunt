module Sinatra
	module FormHelpers
		# form_for, fields_for, form_tag source code comes from the sinatra_more gem,
		# available att https://github.com/nesquena/sinatra_more/

		def form_for(object, url, opts = {}, &block)
			html = capture_html(FormBuilder.new(self, object), &block)
			form_tag(url, opts) { html }
		end

		def fields_for(object, &block)
			haml_concat(capture_html(FormBuilder.new(self, object), &block))
		end

		def form_tag(url, opts = {}, &block)
			opts = {
				:method => 'post',
				:action => url
			}.merge(opts)
			opts[:enctype] = "multipart/form-data" if opts.delete(:multipart)

			content = ''

			# Add form method value as a hidden input if needed
			unless opts[:method].to_s =~ /post|get/
				content << input_tag(:hidden, :name => :_method, :value => opts[:method])
				opts[:method] = 'post'
			end

			content << capture_html(&block) 

			content_tag(:form, content, opts)
		end

		def input_tag(type, *args)
			op = args.last.is_a?(Hash) ? args.pop : {}

			op[:name] ||= args.shift
			op[:id] ||= op[:name].to_s.downcase

			op[:value] ||= args.shift
			
			op[:class] = [op[:class]].compact unless op[:class].is_a?(Array)
			op[:class] << type 

			error = op.delete(:error)
			
			case type
			when :textarea
				# HAML needs to escape newlines
				output = find_and_preserve content_tag(:textarea, op.delete(:value), op)
			else
				output = tag(:input, op.merge({ :type => type }))
			end

			return output unless error

			# Add error message if set
			error_id = op[:id] ? "#{op[:id]}_error" : nil
			output + tag(:p, :class => :error, :id => error_id, :content => error)
		end

		def select_tag(name, opts = {})
			# Determine available options
			collection, fields = opts.delete(:collection), opts.delete(:fields)
			unless collection.nil? || collection.empty?
				options = collection.map { |item| [item.send(fields.first), item.send(fields.last)] }
			else
				options ||= []
			end
			# Prompt / blank options
			options.unshift('') if opts.delete(:include_blank)
			options.unshift([opts.delete(:include_blank), '']) if opts[:prompt]

			# Generate HTML for options
			selected = opts.delete(:selected)
			selected.compact!.map! { |val| val.to_s }
			opts[:content] = options.map { |text, value|
				value ||= text
				is_selected = selected.include?(value.to_s)
				tag(:option, { :content => text, :value => value, :selected => is_selected })
			}.join("\n")

			opts[:name] += '[]' if opts[:multiple]

			tag(:select, opts)
		end

		def submit_tag(text = 'Submit', opts = {})
			opts = {
				:name => :commit,
				:value => text
			}.merge(opts)
			input_tag(:submit, opts)
		end

		# label_tag(input name [, label text [, options]])
		def label_tag(field, *args)
			opts = args.last.is_a?(Hash) ? args.pop : {}
			opts[:content] ||= args.shift || field.to_s.gsub('_', ' ').capitalize
			opts[:for] ||= field
			tag(:label, opts)
		end
	end

	helpers FormHelpers
end

