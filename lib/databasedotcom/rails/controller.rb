module Databasedotcom
  module Rails
    module Controller
      module ClassMethods
        def dbdc_client
          unless @dbdc_client
            config_path = File.join(::Rails.root, 'config', 'databasedotcom.yml')
            config = YAML.load(ERB.new(File.read(config_path)).result)
            config = config.has_key?(::Rails.env) ? config[::Rails.env] : config
            username = config["username"]
            password = config["password"]
            @dbdc_client = Databasedotcom::Client.new(config)
            @dbdc_client.authenticate(:username => username, :password => password)
          end

          @dbdc_client
        end
        
        def dbdc_client=(client)
          @dbdc_client = client
        end

        def sobject_types
          unless @sobject_types
            @sobject_types = dbdc_client.list_sobjects
          end

          @sobject_types
        end

        def const_missing(sym)
          if sobject_types.include?(sym.to_s)
            dbdc_client.materialize(sym.to_s)
          else
            super
          end
        end
      end
      
      module InstanceMethods
        def dbdc_client
          self.class.dbdc_client
        end

        def sobject_types
          self.class.sobject_types
        end
      end
      
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end
    end
  end
end
