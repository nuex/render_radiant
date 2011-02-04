Gem::Specification.new do |s|
  s.name = 'render_radiant'
  s.version = '0.0.2'
  s.date = '2011-01-10'
  s.rubyforge_project = 'render_radiant'
  s.summary = 'ActionController overrides for using Radiant for rendering'
  s.description = 'RenderRadiant allows you to send variables and other settings declared in your action to be rendered in Radiant.'
  s.authors = ['Chase James']
  s.email = 'nx@nu-ex.com'
  s.homepage = 'http://github.com/nuex/render_radiant'
  s.add_dependency('actionpack', '= 2.3.8')

  s.files = %w[
    README.md
    lib/render_radiant.rb
  ]

end
