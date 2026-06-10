import { buildConfig } from "./config.js";
import { HTTPClient } from "./http.js";
import { Personas } from "./resources/personas.js";
import { Chat } from "./resources/chat.js";
import { Domains } from "./resources/domains.js";
import { Simulations } from "./resources/simulations.js";
import { Aggregate } from "./resources/aggregate.js";
import { Audit } from "./resources/audit.js";
import { Memory } from "./resources/memory.js";
import { Sessions } from "./resources/sessions.js";
import { Frameworks } from "./resources/frameworks.js";
import { AuthResource } from "./resources/auth-resource.js";
import { Health } from "./resources/health.js";
import { Info } from "./resources/info.js";

export interface EnsoulOptions {
  apiKey?: string;
  baseUrl?: string;
  bearerToken?: string;
  timeout?: number;
  maxRetries?: number;
  customHeaders?: Record<string, string>;
}

export class Ensoul {
  readonly personas: Personas;
  readonly chat: Chat;
  readonly domains: Domains;
  readonly simulations: Simulations;
  readonly aggregate: Aggregate;
  readonly audit: Audit;
  readonly memory: Memory;
  readonly sessions: Sessions;
  readonly frameworks: Frameworks;
  readonly auth: AuthResource;
  readonly health: Health;
  readonly info: Info;

  private readonly _client: HTTPClient;

  constructor(options: EnsoulOptions = {}) {
    const config = buildConfig(options);
    this._client = new HTTPClient(config);

    this.personas = new Personas(this._client);
    this.chat = new Chat(this._client);
    this.domains = new Domains(this._client);
    this.simulations = new Simulations(this._client);
    this.aggregate = new Aggregate(this._client);
    this.audit = new Audit(this._client);
    this.memory = new Memory(this._client);
    this.sessions = new Sessions(this._client);
    this.frameworks = new Frameworks(this._client);
    this.auth = new AuthResource(this._client);
    this.health = new Health(this._client);
    this.info = new Info(this._client);
  }

  close(): void {
    this._client.close();
  }
}
