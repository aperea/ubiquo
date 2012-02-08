# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../install/db/migrate/", __FILE__)

def create_categories_test_model_backend
  # Creates a test table for AR things work properly
  conn = ActiveRecord::Base.connection

  %w{CategoryTranslatableTestModel CategoryTestModelBase EmptyTestModelBase CategoryTestModel}.each do |model_name|
    table = model_name.tableize
    translatable = table != 'category_test_models'

    conn.create_table table, :translatable => translatable do |t|
      t.string :my_field
    end unless conn.tables.include?(table)

    Object.const_set(model_name, Class.new(ActiveRecord::Base)) unless Object.const_defined? model_name
  end

  Object.const_set("CategoryTestModelSubOne", Class.new(CategoryTestModelBase)) unless Object.const_defined? "CategoryTestModelSubOne"
  Object.const_set("CategoryTestModelSubTwo", Class.new(CategoryTestModelSubOne)) unless Object.const_defined? "CategoryTestModelSubTwo"

  Object.const_set("EmptyTestModelSubOne", Class.new(EmptyTestModelBase)) unless Object.const_defined? "EmptyTestModelSubOne"
  Object.const_set("EmptyTestModelSubTwo", Class.new(EmptyTestModelSubOne)) unless Object.const_defined? "EmptyTestModelSubTwo"
end

def categorize attr, options = {}
  CategoryTestModel.class_eval do
    categorized_with attr, options
  end
end

def validate_presence_of_category attr, options = {}
  CategoryTestModel.class_eval do
    validates_presence_of attr, :identifier => :category_test_presence
  end
end
def invalidate_presence_of_category attr, options = {}
  CategoryTestModel.validate.delete_if do |v|
    v.identifier == :category_test_presence
  end if CategoryTestModel.validate.respond_to?(:delete_if)
end

def categorize_base attr, options = {}
  CategoryTestModelBase.class_eval do
    categorized_with attr, options
  end
end

def create_category_set(options = {})
  default_options = {
    :name => 'MyString', # string
    :key => rand.to_s, # string
    :is_editable => true
  }
  CategorySet.create(default_options.merge(options))
end

def create_set key
  CategorySet.create(:key => key.to_s, :name => key.to_s)
end

def create_category_model
  CategoryTestModel.create
end

def create_i18n_category_model
  CategoryTranslatableTestModel.create(:locale => 'en')
end

def save_current_categories_connector
  save_current_connector(:ubiquo_categories)
end

def reload_old_categories_connector
  reload_old_connector(:ubiquo_categories)
end

def mock_categories_params params = {}
  mock_params(params, Ubiquo::CategoriesController)
end

def mock_categories_controller
  mock_controller(Ubiquo::CategoriesController)
end

def mock_categories_helper
  mock_helper(:ubiquo_categories)
end

if ActiveRecord::Base.connection.class.to_s == "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter"
  ActiveRecord::Base.connection.client_min_messages = "ERROR"
end
