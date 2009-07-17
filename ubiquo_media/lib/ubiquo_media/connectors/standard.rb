module UbiquoMedia
  module Connectors
    class Standard < Base
      
      
      module Asset
        
        def self.included(klass)
          klass.send(:extend, ClassMethods)
          Standard.register_uhooks klass, ClassMethods
        end
        
        module ClassMethods
          # Applies any required extra scope to the filtered_search method
          def uhook_filtered_search filters = {}
            yield
          end
        end
        
      end
      
#      module AssetRelation
#        
#        def self.included(klass)
##          klass.send(:extend, ClassMethods)
##          klass.send(:include, InstanceMethods)
#        end
#        
##        module ClassMethods
##          # Applies any required extra scope to the filtered_search method
##          def uhook_filtered_search
##            yield
##          end
##        end
##        
#      end
      
      module UbiquoAssetsController
        def self.included(klass)
          klass.send(:include, InstanceMethods)
          klass.send(:helper, Helper)
          Standard.register_uhooks klass, InstanceMethods
        end
        
        module Helper
          # Returns a string with extra filters for assets
          def uhook_asset_filters url_for_options
            ''
          end

          # Returns an array with any display information for extra assets filters
          def uhook_asset_filters_info
            []
          end
        end
        
        module InstanceMethods
          
          # Returns a hash with extra filters to apply
          def uhook_index_filters
            {}
          end
          
          # Initializes a new instance of asset.
          def uhook_new_asset
            ::AssetPublic.new
          end
          
          # Creates a new instance of asset.
          def uhook_create_asset visibility
            visibility.new(params[:asset])
          end
         
#          #updates an asset instance. returns a boolean that means if update was done.
#          def uhook_update_asset(asset)
#            asset.update_attributes(params[:asset])
#          end
#
          #destroys an asset instance. returns a boolean that means if the destroy was done.
          def uhook_destroy_asset(asset)
            asset.destroy
          end
        end
      end
      
      module Migration
        
        def self.included(klass)
          klass.send(:extend, ClassMethods)
          Standard.register_uhooks klass, ClassMethods
        end
        
        module ClassMethods
          def uhook_create_assets_table
            create_table :assets do |t|
              yield t
            end
          end
        end
      end
      
    end
  end
end