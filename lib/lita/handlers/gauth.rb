require 'google_auth_box'
module Lita
  module Handlers
    class Gauth < Handler
      on :connected, :log_conn
      on :disconnected, :log_kick

      config :client_id_hash, required: true

      config :scopes, required: true

      config :data_file_path, required: true

      config :base_domain, required: true
      config :oauth_redir_path, required: true

      route(/^authed\?$/, :check_auth, command: true)
      route(/^auth me$/, :request_auth, command: true)

      route(/^foo$/, :bar)
      http.get '/auth-redir', :auth_redir
      http.get '/auth-root/:id', :auth_root
      http.get '/auth-save/:user_id/', :auth_save
      http.get '/foo', :foo
      http.get '/bar', :bar

      def log_conn(payload)
        p "it worked"
        p payload
      end

      def log_kick(payload)
        p 'sad panda'
        p payload
      end

      def foo(req, resp)
        resp.body << "hey there"
      end

      def bar(req, resp)
        resp.body << "it worked"
      end

      def get_user_creds(user_id)
        auth_client.get_creds user_id
      end

      def check_auth(msg)
        credentials = get_user_creds msg.user.id

        if credentials.nil?
          url = auth_client.get_auth_url
          msg.reply "You are not authed"
          msg.reply "Please click the following link to register with the goog: #{url}"
        else
          msg.reply "You are ready to go!"
        end
      end

      def save_creds(user_id, code)
        auth_client.save_creds user_id, code
      end

      def auth_redir(req, resp)
        attrs = {
          storage_key: 'lita_gauth_user_id',
          code: req.params["code"],
          base_url: "#{config.base_domain}/auth-save"
        }
        resp.body << render_template("auth_redir.html", attrs)
      end

      def auth_root(req, resp)
        attrs = {
          "auth_redir_url": auth_client.get_auth_url,
          "user_id": req.env["router.params"][:id],
          "storage_key": "lita_gauth_user_id"
        }

        resp.body << render_template('auth_root.html', attrs)
      end

      def auth_save(req, resp)
        user_id = req.env['router.params'][:user_id]
        save_creds user_id, req.params["code"]
        resp.write MultiJson.dump(msg: "ok")
      end

      def request_auth(msg)
        id = msg.user.id
        url = "#{config.base_domain}/auth-root/#{id}"
        msg.reply "Click the followin link to do the thing! #{url}"
      end

      def build_redir_url
        "#{config.base_domain}#{config.oauth_redir_path}"
      end

      def auth_client
         @_auth_client ||=GoogleAuthBox::Client.new(
          client_id_hash: config.client_id_hash,
          scopes: config.scopes,
          data_file_path: config.data_file_path,
          base_uri: build_redir_url
        )
      end

      Lita.register_handler(self)
    end
  end
end
