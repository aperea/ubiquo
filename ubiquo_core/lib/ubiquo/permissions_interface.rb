module Ubiquo
  # This module defines the Ubiquo permissions API,
  # which is required to be implemented by some plugin.
  # The functions here are simply mocks that will allow ubiquo to be
  # used by everyone (no auth, no access control)
  module PermissionsInterface

    # Returns true if the current user has the permissions in +auth+
    # +auth+ can be either a single value, an array or nil
    # (See the access_control method for examples of auth values)
    def permit?(auth=nil, context = {})
      true
    end

    # Function to regulate the required permissions for actions in a controller
    #
    # Examples:
    #   for the key in "actions":
    #     access_control {
    #      :DEFAULT => ... # control all actions
    #      :index => .... # control index action
    #      [:new, :create] => .... # control new and create actions
    #     }
    #
    #   for the value:
    #     - one permission
    #       access_control :DEFAULT => 'permission_key'
    #       access_control :DEFAULT => :permission_key
    #
    #     - more permissions
    #       access_control :DEFAULT => ['permission_key_1', 'permission_key_2']
    #       access_control :DEFAULT => [:permission_key_1, :permission_key_2]
    #       access_control :DEFAULT => %w{permission_key_1 permission_key_2}
    #
    #     - only admins
    #       access_control :DEFAULT => nil
    #
    def access_control(actions={})
    end

    # Returns the currently logged in ubiquo user
    def current_ubiquo_user
    end
  end
end

Ubiquo::Extensions::Loader.append_extend(:UbiquoController, Ubiquo::PermissionsInterface)