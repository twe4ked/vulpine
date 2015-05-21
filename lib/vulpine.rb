require 'json'
require 'roda'
require 'opengraph'
require 'pinboard'

class Vulpine < Roda
  PINBOARD_ALLOWED_PARAMS = %w[
    url
    description
    extended
  ]

  use Rack::Session::Cookie, secret: 'TODO'

  plugin :render, engine: 'haml'
  plugin :flash
  plugin :assets, css: 'application.scss', js: 'application.js'

  route do |r|
    r.assets

    r.root do
      view 'home', locals: {values: {}}
    end

    r.on 'info' do
      r.is do
        r.post do
          data = {url: r.params['url']}

          opengraph = begin
            strict = false
            generic_fallback = true
            OpenGraph.fetch data[:url], strict, generic_fallback
          rescue Errno::ECONNREFUSED
          end
          if opengraph
            data.merge!(
              title: opengraph.title,
              description: opengraph.description
            )
          end

          JSON.generate data
        end
      end
    end

    r.on 'add' do
      r.is do
        r.post do
          begin
            add_to_pinboard r.params
          rescue Pinboard::Error => e
            flash[:notice] = "#{e.message.capitalize}."
            view 'home', locals: {values: r.params.select { |k, v| %w[url title description].include? k }}
          else
            flash[:notice] = 'Successfully added to Pinboard.'
            r.redirect '/'
          end
        end
      end
    end
  end

  def add_to_pinboard(params)
    # rename params for Pinboard API
    params['extended'] = params.delete('description')
    params['description'] = params.delete('title')

    params.select! { |k, v| PINBOARD_ALLOWED_PARAMS.include? k }

    params.merge!(
      toread: true,
      replace: false,
      shared: false
    )

    pinboard = Pinboard::Client.new token: ENV['PINBOARD_TOKEN']
    pinboard.add params
  end
end
