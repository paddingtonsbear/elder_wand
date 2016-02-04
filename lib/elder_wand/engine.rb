module ElderWand
  class Engine < ::Rails::Engine
    isolate_namespace ElderWand

    initializer "elder_wand.params.filter" do |app|
      app.config.filter_parameters += [:client_secret, :code, :token]
    end

    initializer "elder_wand.locales" do |app|
      if app.config.i18n.fallbacks.blank?
        app.config.i18n.fallbacks = [:en]
      end
    end

    initializer "elder_wand.helpers" do
      ActiveSupport.on_load(:action_controller) do
        include ElderWand::Rails::Helpers
      end
    end
  end
end
