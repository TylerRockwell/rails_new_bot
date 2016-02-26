class RailsBot < Thor
  include Thor::Actions

  desc "prepare_full_stack", "Runs all tasks to initialize an app with html views"
  def prepare_full_stack
    remove_turbolinks
    remove_jbuilder
    swap_sqlite3_to_pg
    install_rspec
    install_bootstrap
  end

  desc "prepare_api", "Runs all tasks to initialize an API"
  def prepare_api
    remove_turbolinks
    swap_sqlite3_to_pg
    install_rspec
  end

  desc "remove_turbolinks", "Removes Turbolinks from the app"
  def remove_turbolinks
    comment_lines('Gemfile', /gem 'turbolinks'/)
    gsub_file('app/assets/javascripts/application.js', /\/\/= require turbolinks\n/, "")
    gsub_file('app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true\n/ , "")
  end

  desc "swap_sqlite3_to_pg", "Uses Postgres for ActiveRecord"
  def swap_sqlite3_to_pg
    gsub_file('Gemfile', /sqlite3/, "pg")
    gsub_file('config/database.yml', /\.sqlite3\n/, "")
    gsub_file('config/database.yml', /sqlite3/, "postgresql")
    bundle
  end

  desc "install_rspec", "Replaces minitest with rspec"
  def install_rspec
    unless File.readlines('Gemfile').grep(/rspec-rails/).any?
      `rm -rf test`
      insert_into_file('Gemfile',
                        "\ngem 'rspec-rails', '~> 3.0'",
                        after: /group :development, :test do/
                      )
      bundle
      `rails g rspec:install`
    end
  end

  desc "install_bootstrap", "Seriously? These should all be self-explanatory"
  def install_bootstrap
    unless File.readlines('Gemfile').grep(/bootstrap-sass/).any?
      add_bootstrap_to_gemfile
      update_stylesheet
      update_application_js
      bundle
    end
  end

  desc "remove_jbuilder", "Remove jbuilder"
  def remove_jbuilder
    comment_lines('Gemfile', /gem 'jbuilder'/)
    bundle
  end

  private

  def bundle
    `bundle install`
  end

  def add_bootstrap_to_gemfile
    insert_into_file('Gemfile',
                      "gem 'bootstrap-sass', '~> 3.3.6'\n",
                      before: /group :development, :test do/
                    )
  end

  def update_stylesheet
    old_stylesheet = "app/assets/stylesheets/application.css"
    stylesheet = "app/assets/stylesheets/application.scss"
    `mv #{old_stylesheet} "#{stylesheet}"` if File.exist?(old_stylesheet)
    insert_into_file(stylesheet,
                     "\n@import \"bootstrap-sprockets\"; \n@import \"bootstrap\";",
                     after: /\*\//)
    gsub_file(stylesheet, /\*= require_tree \.\n/, "")
    gsub_file(stylesheet, /\*= require_self\n/, "")
  end

  def update_application_js
    insert_into_file('app/assets/javascripts/application.js',
                      "\n//= require bootstrap-sprockets\n",
                      after: /require jquery_ujs/)
  end
end