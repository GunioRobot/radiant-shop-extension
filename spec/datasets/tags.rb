class TagsDataset < Dataset::Base

  helpers do
    def mock_valid_tag_for_helper
      @tag = OpenStruct.new({
        :attr   => {},
        :locals => OpenStruct.new({
          :page => OpenStruct.new({
            :params   => {},
            :request  => OpenStruct.new({
              :session => {}
            })
          })
        })
      })
    end
  end

end