# Copyright (C) 2014-2017 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mongo
  module Operation

    # Uses an OP_MSG for certain commands. Only uses payload type 0.
    #
    # @since 2.5.0
    module UsesCommandOpMsg

      private

      CLUSTER_TIME = '$clusterTime'.freeze

      DB = '$db'.freeze

      READ_PREFERENCE = '$readPreference'.freeze

      def cluster_time(server)
        # @todo update when merged with sessions work
        #server.mongos? && server.cluster_time
      end

      def unacknowledged_write?
        write_concern && write_concern.get_last_error.nil?
      end

      def command_op_msg(server, selector, options)
        if (cl_time = cluster_time(server))
          selector[CLUSTER_TIME] = cl_time
        end
        selector[DB] = db_name
        selector[READ_PREFERENCE] = read.to_doc if read
        global_args = { type: 0, document: selector }
        flags = unacknowledged_write? ? [:more_to_come] : [:none]
        Protocol::Msg.new(flags, options, global_args)
      end
    end
  end
end
