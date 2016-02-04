class ElderWand::InstallGenerator < ::Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc 'Installs ElderWand.'

  def install
    template 'initializer.rb', 'config/initializers/elder_wand.rb'
    copy_file File.expand_path('../../../../config/locales/en.yml', __FILE__), 'config/locales/elder_wand.en.yml'
    readme 'README'
  end
end
