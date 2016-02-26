require_relative 'rails_setup'
require 'thor'
require 'thor/actions'

RSpec.describe "The Thor Script" do
  describe ".use_scss" do
    let(:old_file) { "app/assets/stylesheets/application.css"}
    let(:updated_file) { "app/assets/stylesheets/application.scss" }
    it "renames application.css" do
      expect(File.exist?(old_file))
      expect(!File.exist?(updated_file))
      RailsSetup.use_scss
      expect(!File.exist?(old_file))
      expect(File.exist?(updated_file))

      `mv #{updated_file} #{old_file} `
    end
  end

  describe ".remove_turbolinks" do
    it "removes turbolinks from the app" do
      RailsSetup.remove_turbolinks
      expect(File.read('Gemfile')).to include("# gem 'turbolinks'")
    end
  end
end
