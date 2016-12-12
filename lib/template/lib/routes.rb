Routes = Rack::Builder.new do
  use Pliny::Middleware::RequestStore::Clear, store: Pliny::RequestStore
  use Pliny::Middleware::CORS
  use Pliny::Middleware::RequestID
  use Pliny::Middleware::RequestStore::Seed, store: Pliny::RequestStore
  use Pliny::Middleware::Metrics
  use Pliny::Middleware::CanonicalLogLineEmitter,
      emitter: -> (data) {
        Pliny.log_without_context({ canonical_log_line: true }.merge(data)
      }
  use Pliny::Middleware::RescueErrors, raise: Config.raise_errors?
  use Rack::Timeout,
      service_timeout: Config.timeout if Config.timeout > 0
  use Pliny::Middleware::Versioning,
      default: Config.versioning_default,
      app_name: Config.versioning_app_name if Config.versioning?
  use Rack::Deflater
  use Rack::MethodOverride
  use Rack::SSL if Config.force_ssl?

  use Pliny::Router do
    # mount all endpoints here
    mount Endpoints::Health
    mount Endpoints::Schema
  end

  # root app; but will also handle some defaults like 404
  run Endpoints::Root
end
