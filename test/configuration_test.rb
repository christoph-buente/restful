require File.dirname(__FILE__) + '/test_helper.rb'

context "Configuration" do
  specify "should be known to have no defined fields if created only with restful_options" do
    config = Restful::Rails::ActiveRecord::Configuration::Config.new
    config.restful_options[:expansion] = :expanded
    config.should.not.has_fields
  end
  
  specify "should return fields without restful_options via whitelisted" do
    config = Restful::Rails::ActiveRecord::Configuration::Config.new([:one, :two])
    config.restful_options[:expansion] = :expanded
    config.whitelisted.should.not.include :restful_options
  end
  
  specify "should have 0 whitelisted fields if none were specified" do
    config = Restful::Rails::ActiveRecord::Configuration::Config.new
    config.restful_options.should.==({})
    config.whitelisted.should.== []
  end
  
  specify "calling whitelisted should not delete options" do
    config = Restful::Rails::ActiveRecord::Configuration::Config.new([:one, :two])
    config.restful_options[:expansion] = :expanded
    config.whitelisted
    config.restful_options[:expansion].should.== :expanded    
  end
  
  specify "should know if it has restful_options" do
    config = Restful::Rails::ActiveRecord::Configuration::Config.new([:one, :two])
    config.restful_options[:expansion] = :expanded
    config.should.has_restful_options
  end
  
  specify "is able to remove restful options from an array" do
    fields = Restful::Rails::ActiveRecord::Configuration::Config.new(:one, :two, :restful_options => { :expansion => :expanded }).fields
    Restful::Rails::ActiveRecord::Configuration::Config.remove_restful_options(fields).should.== [:one, :two]
  end

  specify "is able to remove restful options from an array where nested configurations exist at the end" do
    fields = Restful::Rails::ActiveRecord::Configuration::Config.new(:name, :current_location, :pets => [:name], :restful_options => { :expansion => :expanded }).fields
    Restful::Rails::ActiveRecord::Configuration::Config.remove_restful_options(fields).should.== [:name, :current_location, {:pets => [:name]}]
  end
  
  specify "should be able to copy in another configuration object's fields" do
    other = Restful::Rails::ActiveRecord::Configuration::Config.new(:name, :current_location, :pets => [:name], :restful_options => { :expansion => :expanded })

    config = Restful::Rails::ActiveRecord::Configuration::Config.new
    config.restful_options[:nested] = false     
    config.merge!(other)
    
    config.whitelisted.should.== [:name, :current_location, {:pets => [:name]}]
    config.restful_options.should.==({ :expansion => :expanded, :nested => false })
  end
end