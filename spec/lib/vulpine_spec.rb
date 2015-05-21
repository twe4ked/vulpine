require File.join File.dirname(__FILE__), '../../lib/vulpine'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.describe Vulpine do
  describe '#merge_opengraph_data!' do
    let(:app) { Vulpine.new({}) }

    it 'merges in open graph data' do
      data = {}
      opengraph = Struct.new(:title, :description).new('title', 'description')
      app.merge_opengraph_data! opengraph, data
      expect(data).to eq({title: 'title', description: 'description'})
    end
  end
end
