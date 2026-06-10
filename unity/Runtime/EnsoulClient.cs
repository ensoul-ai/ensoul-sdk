using System;
using Ensoul.Resources;

namespace Ensoul
{
    public class EnsoulClient : IDisposable
    {
        public const string Version = "0.1.0";

        public PersonasResource Personas { get; }
        public ChatResource Chat { get; }
        public DomainsResource Domains { get; }
        public SimulationsResource Simulations { get; }
        public AggregateResource Aggregate { get; }
        public MemoryResource Memory { get; }
        public SessionsResource Sessions { get; }
        public FrameworksResource Frameworks { get; }
        public AuthResource Auth { get; }
        public HealthResource Health { get; }
        public InfoResource Info { get; }
        public AuditResource Audit { get; }

        private readonly EnsoulHttpClient _http;

        public EnsoulClient(EnsoulConfig config)
        {
            _http = new EnsoulHttpClient(config);
            Personas    = new PersonasResource(_http);
            Chat        = new ChatResource(_http);
            Domains     = new DomainsResource(_http);
            Simulations = new SimulationsResource(_http);
            Aggregate   = new AggregateResource(_http);
            Memory      = new MemoryResource(_http);
            Sessions    = new SessionsResource(_http);
            Frameworks  = new FrameworksResource(_http);
            Auth        = new AuthResource(_http);
            Health      = new HealthResource(_http);
            Info        = new InfoResource(_http);
            Audit       = new AuditResource(_http);
        }

        public EnsoulClient(string apiKey)
            : this(new EnsoulConfig(apiKey: apiKey)) { }

        /// Create a client using a custom HttpMessageHandler (for testing).
        public static EnsoulClient WithHttpClient(EnsoulConfig config, System.Net.Http.HttpMessageHandler handler)
        {
            var http = new EnsoulHttpClient(config, handler);
            return new EnsoulClient(http);
        }

        private EnsoulClient(EnsoulHttpClient http)
        {
            _http       = http;
            Personas    = new PersonasResource(_http);
            Chat        = new ChatResource(_http);
            Domains     = new DomainsResource(_http);
            Simulations = new SimulationsResource(_http);
            Aggregate   = new AggregateResource(_http);
            Memory      = new MemoryResource(_http);
            Sessions    = new SessionsResource(_http);
            Frameworks  = new FrameworksResource(_http);
            Auth        = new AuthResource(_http);
            Health      = new HealthResource(_http);
            Info        = new InfoResource(_http);
            Audit       = new AuditResource(_http);
        }

        public void Dispose() => _http.Dispose();
    }
}
