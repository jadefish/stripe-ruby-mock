module StripeMock
  module RequestHandlers
    module Terminals
      def Terminals.included(klass)
        klass.add_handler 'post /v1/terminal/connection_token', :new_terminal_connection_token

        klass.add_handler 'post /v1/terminal/locations',        :new_terminal_location
        klass.add_handler 'post /v1/terminal/locations/(.*)',   :get_terminal_location
        klass.add_handler 'post /v1/terminal/locations/(.*)',   :update_terminal_location
        klass.add_handler 'delete /v1/terminal/locations/(.*)', :delete_terminal_location
        klass.add_handler 'get /v1/terminal/locations',         :get_terminal_locations

        klass.add_handler 'post /v1/terminal/readers',       :new_terminal_reader
        klass.add_handler 'get /v1/terminal/readers/:id',    :get_terminal_reader
        klass.add_handler 'post /v1/terminal/readers/:id',   :update_terminal_reader
        klass.add_handler 'delete /v1/terminal/readers/:id', :delete_terminal_reader
        klass.add_handler 'get /v1/terminal/readers',        :get_terminal_readers
      end

      def new_terminal_connection_token(route, method_url, params, headers)
        params = validate_params(params, allowed: [:location])

        Data.mock_terminal_connection_token(params)
      end

      def new_terminal_location(route, method_url, params, headers)
        id = new_id('tml')
        params = validate_params(params, allowed: [:metadata], required: %i[address display_name])

        terminal_locations[id] = Data.mock_terminal_location(params.merge(id: id))
        terminal_locations[id].clone
      end

      def get_terminal_location(route, method_url, params, headers)
        route =~ method_url
        id = $1 || params[:terminal_location]

        terminal_location = assert_existence :terminal_location, id, terminal_locations[id]
        terminal_location.clone
      end

      def update_terminal_location(route, method_url, params, headers)
        params = validate_params(params, allowed: %i[address metadata display_name])
        route =~ method_url
        id = $1 || params[:terminal_location]

        terminal_location = assert_existence :terminal_location, id, terminal_locations[id]
        terminal_locations[id] = Util.rmerge(terminal_location, params)
        terminal_locations[id].clone
      end

      def delete_terminal_location(route, method_url, params, headers)
        route =~ method_url
        id = $1 || params[:terminal_location]

        terminal_location = assert_existence :terminal_location, id, terminal_locations[id]
        terminal_locations.delete(id)

        {id: id, object: 'terminal.location', deleted: true}
      end

      def get_terminal_locations(route, method_url, params, headers)
        params = validate_params(params, allowed: %i[ending_before limit starting_after])
        params[:limit] ||= 10

        Data.mock_list_object(terminal_locations.clone.values, params)
      end

      def new_terminal_reader(route, method_url, params, headers)
        id = new_id('tmr')
        params = validate_params(params, allowed: %i[label metadata], required: %i[location registration_code])

        terminal_readers[id] = Data.mock_terminal_reader(params.merge(id: id))
        terminal_readers[id].clone
      end

      def get_terminal_reader(route, method_url, params, headers)
        route =~ method_url
        id = $1 || params[:terminal_reader]

        terminal_reader = assert_existence :terminal_reader, id, terminal_readers[id]
        terminal_reader.clone
      end

      def update_terminal_reader(route, method_url, params, headers)
        params = validate_params(params, allowed: %i[label metadata])
        route =~ method_url
        id = $1 || params[:terminal_reader]

        terminal_reader = assert_existence :terminal_reader, id, terminal_readers[id]
        terminal_readers[id] = Util.rmerge(terminal_reader, params)
        terminal_readers[id].clone
      end

      def delete_terminal_reader(route, method_url, params, headers)
        route =~ method_url
        id = $1 || params[:terminal_reader]

        terminal_reader = assert_existence :terminal_reader, id, terminal_readers[id]
        terminal_readers.delete(id)

        {id: id, object: 'terminal.reader', deleted: true}
      end

      def get_terminal_readers(route, method_url, params, headers)
        params = validate_params(params, allowed: [
          :device_type,
          :location,
          :serial_number,
          :status,
          :ending_before,
          :limit,
          :starting_after
        ])
        params[:limit] ||= 10

        clone = terminal_locations.clone

        if params[:device_type]
          clone.delete_if { |_, v| v[:device_type] != params[:device_type] }
        end

        if params[:location]
          clone.delete_if { |_, v| v[:location] != params[:location] }
        end

        if params[:serial_number]
          clone.delete_if { |_, v| v[:serial_number] != params[:serial_number] }
        end

        if params[:status]
          clone.delete_if { |_, v| v[:status] != params[:status] }
        end

        Data.mock_list_object(clone.values, params)
      end

    end
  end
end
