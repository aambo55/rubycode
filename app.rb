require 'json'
require 'sinatra'
require 'line/bot'
require 'dotenv/load'
require 'mqtt'
require 'uri'

class App < Sinatra::Base

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV['']
      config.channel_token = ENV['']
    }
  end

  uri = URI.parse ENV['CLOUDMQTT_URL']

  conn_opts = {
    remote_host: uri.host,
    remote_port: uri.port,
    username: uri.user,
    password: uri.password
  }

  topic = uri.path[1, uri.path.length]

  get '/' do
    'Hello world!!'
  end

  post '/callback' do
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text

        case event.message['text']
          when 'LEDON'
            message = '�Դ�����'
          when 'LEDOFF'
            message = '�Դ�����'
          else
            message = '��������� �ѹ�����٨ѡ'
          end

          MQTT::Client.connect(conn_opts) do |c|
            c.publish(topic, event.message['text'])
          end

          message = {
            type: 'text',
            text: message
          }

          client.reply_message(event['replyToken'], message)
        end
      end

    'OK'
    end
  end

end