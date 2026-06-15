/**
 * Create a domain with the Ensoul SDK.
 *
 * A domain is the first thing you build: it defines the tier hierarchy,
 * personality schema, and archetypes that every persona in it inherits.
 *
 * There are two ways to create one:
 *
 * 1. AI wizard (easy path) — describe the domain in plain English and let
 *    `domains.generate` produce a full config, then create it. Requires the
 *    PRO tier and a server with the Claude API configured.
 * 2. By hand — build a typed `DomainConfigCreateInput` and pass it to
 *    `domains.create`. Works on any tier.
 *
 * Set ENSOUL_API_KEY (and optionally ENSOUL_BASE_URL) before running.
 *
 *   npx tsx examples/create-domain.ts
 */
import { Ensoul, FieldType, type DomainConfigCreateInput } from "@ensoul-ai/sdk";

async function createWithAiWizard(client: Ensoul): Promise<void> {
  // Step 1, easy path: generate a domain config from a description.
  const result = await client.domains.generate({
    description:
      "A fantasy RPG world with playable races (elves, dwarves, humans) and " +
      "classes (warrior, mage, rogue). Characters have courage and wisdom traits.",
    context: { inspiration: "tabletop RPGs" },
  });
  console.log(`Generated config (confidence ${result.confidence.toFixed(2)}):`);
  console.log(`  explanation: ${result.explanation}`);

  // The generated config is ready to create as-is.
  const domain = await client.domains.create(result.config);
  console.log("Created generated domain:", domain);
}

async function createByHand(client: Ensoul): Promise<void> {
  // Step 1, manual path: build a typed config and create it.
  const config: DomainConfigCreateInput = {
    name: "example_world",
    display_name: "Example World",
    description: "A minimal hand-built domain.",
    tiers: [
      { level: 0, name: "world", description: "Root tier" },
      { level: 1, name: "character", description: "Individuals" },
    ],
    personality_schema: {
      fields: [
        {
          path: "traits.courage",
          field_type: FieldType.FLOAT,
          range_min: 0,
          range_max: 100,
          description: "How brave the character is",
        },
      ],
    },
    archetypes: [
      { id: "hero", name: "Hero", tier: 1, personality_modifiers: { "traits.courage": 30 } },
    ],
    entity_noun: "character",
  };

  const domain = await client.domains.create(config);
  console.log("Created hand-built domain:", domain);
}

async function main(): Promise<void> {
  const client = new Ensoul(); // reads ENSOUL_API_KEY / ENSOUL_BASE_URL from env
  await createByHand(client);
  // Uncomment if your account has the PRO tier and the server has the
  // Claude API configured:
  // await createWithAiWizard(client);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
