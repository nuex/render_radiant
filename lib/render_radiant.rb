module RenderRadiant

  RADIANT_DEFAULT_METHOD_ASSIGNS = [:flash, :params]

  # Override the default render method to render for Radiant
  def self.included(kls)
    kls.send(:alias_method_chain, :render, :render_radiant)
  end

  # Use Radiant to render the page matching the passed in URL.
  #
  # Usage:
  #
  #   EventsController < ActionController::Base
  #
  #     def index
  #       @events = Event.all
  #       render :radiant
  #     end
  #
  #     def show
  #       @event = Event.find(params[:id])
  #       render :radiant, :locals => { :cool_event => @event.cool? }
  #     end
  #
  #   end
  #
  # Page attributes can be overridden and/or set by passing in through the
  # :radiant options hash:
  #
  #   render :radiant => { :title => @event.name, :breadcrumb => @event.name }
  #
  # By default all instance variables declared in the action are assigned
  # to the Radiant page's context to be called from your Radius tags.
  #
  # The url matching the controller and action name is used for rendering.
  #
  # To use a different url for rendering, pass in the :action option:
  #
  #   render :radiant, :action => 'myaction'
  #
  # Of course you will need to create a page tree in Radiant that matches
  # the url of the page you are wanting to render.
  #
  def render_with_render_radiant(options = nil, extra_options = {}, &block)
    if options &&
       ( (options.is_a?(Symbol) && options == :radiant) ||
         (options.is_a?(Hash) && options.keys.first == :radiant) )

      # Bringing this in from original render
      raise DoubleRenderError, "Can only render or redirect once per action" if performed?
      validate_render_arguments(options, extra_options, block_given?)

      options = options[:radiant]

      # Retrieve the action and controller to form a URL
      split_action = extra_options[:action].split('/') if extra_options[:action]
      if split_action
        action, controller = split_action
      else
        action, controller = params[:action], params[:controller]
      end

      # Assume the URL will be formatted like /controller_name/action_name or
      # /controller_name if calling the index action
      url = "/#{controller}"
      url << "/#{action}" if action != 'index'

      page = Page.find_by_url(url)

      # Collect page overrides
      # Set cache to false by default
      page_overrides = {
        :cache => false
      }

      page_overrides.merge!(options) if options

      # Override the page instance with any passed in customizations
      page_overrides.each do |k,v|
        blk = proc { v }
        kls = (class << page; self; end)
        kls.send(:define_method, k, blk)
      end

      render_for_radiant(page, extra_options[:locals])
    else
      render_without_render_radiant(options, extra_options, &block)
    end
  end

  def render_for_radiant(page, local_assigns)

    # Collect values to assign
    values = {}

    # Collect values returned from methods
    RADIANT_DEFAULT_METHOD_ASSIGNS.each do |m|
      values[m] = self.send(m)
    end

    # Collect values assigned via the locals option
    local_assigns ||= {}
    local_assigns.each do |name, value|
      values[name] = value
    end

    # Collect ivars from the action
    ivars = self.instance_variable_names
    ivars -= self.protected_instance_variables
    ivars.each do |name|
      values[name.gsub(/@/,'')] = self.instance_variable_get(name)
    end

    # Assign each value to the page context
    page.send(:lazy_initialize_parser_and_context)
    context = page.instance_variable_get(:@context)
    values.each do |k,v|
      context.globals.send "#{k}=", v
    end

    # WillPaginate loves this
    page.instance_variable_set(
      :@url,
      ActionController::UrlRewriter.new(request, params.clone)
    )

    # Let ActionController know we're rendering the page
    @performed_render = true

    page.process(request, response)
  end

end

ActionController::Base.send(:include, RenderRadiant)
