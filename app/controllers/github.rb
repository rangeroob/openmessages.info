# frozen_string_literal: true

module Controller
  module Auth
    class Github < Cuba; end
    Github.define do
      on post do
        on csrf.unsafe? do
          csrf.reset!
          res.status = 403
          res.write('Not authorized')
          halt(res.finish)
        end
      end
      on get do
        on csrf.unsafe? do
          csrf.reset!
          res.status = 403
          res.write('Not authorized')
          halt(res.finish)
        end
        on root do
          env['rack.session'][:user_id] = env['omniauth.auth']['info']['nickname']
          res.redirect('/')
        end
      end
    end
  end
end
