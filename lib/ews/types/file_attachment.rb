=begin
  This file is part of Viewpoint; the Ruby library for Microsoft Exchange Web Services.

  Copyright © 2011 Dan Wanek <dan.wanek@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
=end

module Viewpoint::EWS::Types
  class FileAttachment < Attachment

    FILE_ATTACH_KEY_PATHS = {
      :id   => [:attachment_id, :attribs, :id],
      :name => [:name, :text],
      :content_type => [:content_type, :text],
      :size => [:size, :text],
      :last_modified_time => [:last_modified_time, :text],
      :is_inline? => [:is_inline, :text],
      :is_contact_photo? => [:is_contact_photo, :text],
      :content  => [:content, :text],
    }

    FILE_ATTACH_KEY_TYPES = {
      is_inline?:   ->(str){str.downcase == 'true'},
      is_contact_photo?:   ->(str){str.downcase == 'true'},
      last_modified_type: ->(str){DateTime.parse(str)},
      size: ->(str){str.to_i},
    }

    FILE_ATTACH_KEY_ALIAS = {
      :file_name   => :name,
    }

    # @param [Hash] attachment The attachment ews_item
    def initialize(item, attachment)
      @item = item
      super(item.ews, attachment)
    end

    def get_all_properties!
      resp = ews.get_attachment attachment_ids: [self.id]
      @ews_item.merge!(parse_response(resp))
    end

    private


    def key_paths
      @key_paths ||= FILE_ATTACH_KEY_PATHS
    end

    def key_types
      @key_types ||= FILE_ATTACH_KEY_TYPES
    end

    def key_alias
      @key_alias ||= FILE_ATTACH_KEY_ALIAS
    end

    def parse_response(resp)
      if(resp.status == 'Success')
        resp.response_message[:elems][:attachments][:elems][0][:file_attachment][:elems].inject(&:merge)
      else
        raise EwsError, "Could not retrieve #{self.class}. #{resp.code}: #{resp.message}"
      end
    end

  end
end

