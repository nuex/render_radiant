= RenderRadiant

== SYNOPSIS

RenderRadiant adds a :radiant option to ActionController::Base's render method, giving actions in your extension controller the ability to use Radiant for rendering pages. The page's context is set based on instance variables you define in the action. "flash", "params" and locals you pass in using the :locals option are also available from the page's context.globals to be used by your Radius tags.

The page to render is deduced from the requested URL or the passed in :action option.

== INSTALL

    gem install render_radiant

Require 'render_radiant' in your Radiant extension's extension_config.

== USAGE

In your extension's controller, use the render :radiant command:

    EventsController < ActionController::Base

      def index
        @events = Event.all
        render :radiant
      end

      def show
        @event = Event.find(params[:id])
        render :radiant, :locals => { :cool_event => @event.cool? }
      end

    end

Page attributes can be overridden and/or set by passing in the page hash:

   render :radiant, :page => { :title => @event.name }

Page attributes can be overridden and/or set by passing in through the :radiant options hash:

   render :radiant => { :title => @event.name, :breadcrumb => @event.name }

By default all instance variables declared in the action are assigned to the Radiant page's context to be called from your Radius tags.

The url matching the controller and action name is used for rendering.

To use a different url for rendering, pass in the :action option:

    render :radiant, :action => 'myaction'

You will want to create a page tree in Radiant with slugs that match the actions in your controller that will be rendered. If a corresponding Radiant page is not found, the 404 page is rendered.

=== Controller to Radiant Page Mapping

render_radiant assumes the Radiant page used for rendering will match the URL of the request. So, for example, in an EventsController, the "index" action will use Page.find_by_url('/events') to fetch the index page for that request.

=== Loading Context

render_radiant loads instance variables defined in the action, locals passed in via the :locals option hash, and values from the "flash" and "params" methods into the page's context.globals to be called from your Radius tags.

So if you define the variable @events in your EventsController's "index" action, the data will be available to radius in tag.locals.events during rendering.

=== Overriding Default Page Values

Currently render_radiant will override the page's title by passing in the :title option.

== RAILS 3 POSSIBILITIES

Currently only Rails 2.3.8 (which is used by the current version of Radiant) is used. However, once Radiant adopts Rails 3, a custom Radiant renderer can be built, therefore making monkey-patching ActionController::Base unnecessary: http://www.engineyard.com/blog/2010/render-options-in-rails-3/
