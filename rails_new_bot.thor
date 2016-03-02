class RailsBot < Thor
  include Thor::Actions

  desc "prepare_full_stack", "Run tasks for app with html views"
  def prepare_full_stack
    basic_app_prep
    full_stack_tasks
    finalize
  end

  desc "prepare_api", "Run tasks for API"
  def prepare_api
    basic_app_prep
    finalize
  end

  desc "initialize_git_repo", "Creates a git repo in the app"
  def initialize_git_repo
    # Yes, I know this can be done with the --git flag, but I don't ever remember to do it
    init_and_commit unless git_repo_exists?
  end

  private

  def finalize
    commit_work
    kill_spring
  end

  ### Shell Commands ###
  def bundle
    `bundle install`
  end

  def kill_spring
    `spring stop`
  end

  ### Installer Methods ###

  def basic_app_prep
    initialize_git_repo
    remove_turbolinks
    swap_sqlite3_to_pg
    add_essential_gems
    install_rspec
    bundle
    run_basic_installers
  end

  def full_stack_tasks
    remove_jbuilder_gem
    install_bootstrap
    bundle
  end

  ### Gemfile ###

  def add_essential_gems
    unless essential_gems_are_installed?
      add_development_test_gems
      add_test_gems
    end
  end

  def add_development_test_gems
    insert_into_file("Gemfile",
                     "\n  gem 'pry-byebug'\n"\
                     "  gem 'faker' \n"\
                     "  gem 'factory_girl_rails'\n"\
                     "  gem 'database_cleaner'",
                     after: /group :development, :test do/
                    )
  end

  def add_test_gems
    append_file("Gemfile",
    "group :test do\n"\
    "\n  gem 'cucumber-rails', require: false\n"\
    "  gem 'shoulda-matchers', '~> 3.0'\n"\
    "end \n"
    )
  end

  def remove_jbuilder_gem
    comment_lines('Gemfile', /gem 'jbuilder'/)
  end

  def essential_gems_are_installed?
    File.readlines('Gemfile').grep(/database_cleaner/).any?
  end

  ### Git ###

  def init_and_commit
    `git init`
    `git add .`
    `git commit -m "Initial Commit"`
  end

  def git_repo_exists?
    File.exist?('.git')
  end

  def commit_work
    `git add .`
    `git commit -m "Prep rails app for real work"`
  end

  def run_basic_installers
    `DISABLE_SPRING=1 rails g rspec:install`
    `DISABLE_SPRING=1 rails g cucumber:install`
  end

  ### Bootstrap ###

  def add_bootstrap_to_gemfile
    insert_into_file("Gemfile",
                     "gem 'bootstrap-sass', '~> 3.3.6'\n",
                     before: /group :development, :test do/
                    )
    end

  def install_bootstrap
    run_bootstrap_installer unless bootstrap_is_installed?
  end

  def run_bootstrap_installer
    add_bootstrap_to_gemfile
    update_stylesheet
    update_application_js
  end

  def bootstrap_is_installed?
    File.readlines('Gemfile').grep(/bootstrap-sass/).any?
  end

  def update_stylesheet
    stylesheet = "app/assets/stylesheets/application.scss"
    make_sassy(stylesheet)
    add_import_statements(stylesheet)
    remove_require_lines(stylesheet)
  end

  def make_sassy(stylesheet)
    old_stylesheet = "app/assets/stylesheets/application.css"
    `mv #{old_stylesheet} #{stylesheet}` if File.exist?(old_stylesheet)
  end

  def add_import_statements(stylesheet)
    insert_into_file(stylesheet,
                     "\n@import \"bootstrap-sprockets\"; \n@import \"bootstrap\";",
                     after: /\*\//
                    )
  end

  def remove_require_lines(stylesheet)
    gsub_file(stylesheet, /\*= require_tree \.\n/, "")
    gsub_file(stylesheet, /\*= require_self\n/, "")
  end

  def update_application_js
    insert_into_file('app/assets/javascripts/application.js',
                      "\n//= require bootstrap-sprockets\n",
                      after: /require jquery_ujs/)
  end

  ### Turbolinks ###

  def remove_turbolinks
    remove_turbolinks_gem
    remove_turbolinks_from_js
    remove_turbolinks_from_html
  end

  def remove_turbolinks_gem
    comment_lines('Gemfile', /gem 'turbolinks'/)
  end

  def remove_turbolinks_from_js
    gsub_file('app/assets/javascripts/application.js', /\/\/= require turbolinks\n/, "")
  end

  def remove_turbolinks_from_html
    gsub_file('app/views/layouts/application.html.erb', /, 'data-turbolinks-track' => true\n/ , "")
  end

  ### RSpec ###

  def install_rspec
    unless rspec_is_installed?
      remove_test_directory
      add_rspec_gem
    end
  end

  def rspec_is_installed?
    File.readlines('Gemfile').grep(/rspec-rails/).any?
  end

  def remove_test_directory
    `rm -rf test`
  end

  def add_rspec_gem
    insert_into_file('Gemfile',
                      "\ngem 'rspec-rails', '~> 3.0'",
                      after: /group :development, :test do/
                    )
  end

  ### Postgres ###

  def swap_sqlite3_to_pg
    change_sqlite3_gem_to_pg
    remove_sqlite3_database_extensions
    change_database_adapter_to_postgresql
  end

  def change_sqlite3_gem_to_pg
    gsub_file('Gemfile', /sqlite3/, "pg")
  end

  def remove_sqlite3_database_extensions
    gsub_file('config/database.yml', /\.sqlite3\n/, "")
  end

  def change_database_adapter_to_postgresql
    gsub_file('config/database.yml', /sqlite3/, "postgresql")
  end
end
