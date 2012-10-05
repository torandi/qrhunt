class FormBuilder
	# This class is based on the AbstractFormBuilder class
	# included in the sinatra_more gem, with source available at
	# https://github.com/nesquena/sinatra_more/

	attr_accessor :template, :object

	def initialize(template, object)
    @template = template
    @object = build_object(object)
    raise "FormBuilder template must be initialized!" unless template
    raise "FormBuilder object mustn't be a nil value. Use a symbol if there is no object." unless object
  end

  def label(field, *args, &block)
		args[:for] = field_id(field)
    @template.label_tag(field, args, &block)
  end

  def hidden(field, opts = {})
		opts = create_options_hash(field, opts, :value => field_value(field))
    @template.input_tag :hidden, field_name(field), opts
  end

  def text(field, opts = {})
		opts = create_options_hash(field, opts, :value => field_value(field))
    @template.input_tag :text, field_name(field), opts
  end

  def text_area(field, opts = {})
		opts = create_options_hash(field, opts, :value => field_value(field))
    @template.input_tag :textarea, field_name(field), opts
  end

  def password(field, opts = {})
		opts = create_options_hash(field, opts, :value => field_value(field))
    @template.input_tag :password, field_name(field), opts
  end

  def file(field, opts = {})
		opts = create_options_hash(field, opts)
    @template.input_tag :file, field_name(field), opts
  end

	def datetime(field, opts = {})
		value = field_value(field)
		value = Time.now unless value.respond_to?(:strftime)
		value = value.strftime(@template.settings.datetime_format)
		opts = create_options_hash(field, opts, :value => value, :class => :datetime)
    @template.input_tag :text, field_name(field), opts
	end

  def select(field, opts = {})
		opts = create_options_hash(field, opts, :selected => field_value(field))
    @template.select_tag field_name(field), opts
  end

  def check(field, opts = {})
		opts = {
			:uncheck_value => '0',
			:value => '1',
			:label => true
		}.merge(opts)
		opts[:id] = field_id(field, opts[:value]) unless opts[:id]
		opts[:checked] ||= value_matches_field?(field, opts[:value])
		
		if opts[:label]
			label = opts.delete(:label)
			label = opts[:value] if label == true
		end

    hidden_html = hidden(field, :value => opts.delete(:uncheck_value), :id => nil)
    input_html = @template.input_tag(:check, field_name(field), opts)

		return hidden_html + input_html unless label

		input_html << " #{label}"
		hidden_html + @template.label_tag(field_name(field), { :for => opts[:id], :content => input_html, :class => :check })
  end

  def radio(field, opts = {})
		opts = {
			:value => '1',
			:label => true
		}.merge(opts)
		opts[:id] = field_id(field, opts[:value]) unless opts[:id]
		opts[:checked] ||= value_matches_field?(field, opts[:value])
		
		if opts[:label]
			label = opts.delete(:label)
			label = opts[:value] if label == true
		end

    html = @template.input_tag :radio, field_name(field), opts

		return html unless label

		html << " #{label}"
		@template.label_tag field_name(field), { :for => opts[:id], :content => html, :class => :radio }
  end

  def submit(text = "Submit", opts = {})
		opts[:id] ||= field_id('commit')
    @template.submit_tag text, opts
  end

  protected

  # Returns the known field types for a formbuilder
  def self.field_types
    [:hidden, :text, :text_area, :password, :file, :radio_button, :check_box, :select]
  end

	def create_options_hash(field, opts, defaults = {})
		defaults[:id] = field_id(field) unless defaults[:id]
		opts = defaults.merge(opts)
		if @object.respond_to?(:errors) && !@object.errors[field].empty?
			opts[:class] = [opts[:class]].compact unless opts[:class].is_a?(Array)
			opts[:class] << :error
			opts[:error] = @object.errors[field].first
		end

		opts
	end

  # Returns the object's models name
  #   => user_assignment
  def object_name
    @object_name ||= object.is_a?(Symbol) ? object : object.class.to_s.underscore.gsub('/', '-')
  end

  # Returns true if the value matches the value in the field
  def value_matches_field?(field, v)
		fv = field_value(field)
		v = v.to_s
		!fv.nil? && (fv.to_s == v || fv == true && v == '1' || fv == false && v == '0')
  end

  # Returns the value for the object's field
  # field_value(:username) => "Joey"
  def field_value(field)
    @object && @object.respond_to?(field) ? @object.send(field) : ''
  end

  # Returns the name for the given field
  # field_name(:username) => "user[username]"
  def field_name(field)
    "#{object_name}[#{field}]"
  end

  # Returns the id for the given field
  # field_id(:username) => "user_username"
  # field_id(:gender, :male) => "user_gender_male"
  def field_id(field, value = nil)
    if value.nil? || value.empty?
			"#{object_name}_#{field}" 
		else
			"#{object_name}_#{field}_#{value}"
		end
  end

  # object_or_symbol is either a symbol or a record
  # Returns a new record of the type specified in the object
  def build_object(object_or_symbol)
    object_or_symbol.is_a?(Symbol) ? object_class(object_or_symbol).new : object_or_symbol
  end

  # Returns the class type for the given object
  def object_class(obj)
		obj.is_a?(Symbol) ? obj.to_s.classify.constantize : obj.class
  end
end
