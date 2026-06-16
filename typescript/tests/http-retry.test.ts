import { describe, it, expect, beforeEach, vi } from "vitest";
import { HTTPClient } from "../src/http.js";
import { buildConfig } from "../src/config.js";

/**
 * The central guarantee: a non-idempotent request (POST/PATCH) that may already
 * have executed server-side is NOT replayed. Domain generation runs a ~120s LLM
 * call; before this policy a client timeout triggered retries that re-ran the
 * generation and billed the caller multiple times for one logical request.
 */

function client() {
  return new HTTPClient(buildConfig({ apiKey: "sk", maxRetries: 2 }));
}

function jsonResponse(status: number): Response {
  return new Response(JSON.stringify({}), {
    status,
    headers: new Headers({ "Content-Type": "application/json" }),
  });
}

beforeEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
  // Skip the real backoff sleeps.
  vi.spyOn(globalThis, "setTimeout").mockImplementation(((fn: () => void) => {
    fn();
    return 0 as unknown as ReturnType<typeof setTimeout>;
  }) as typeof setTimeout);
});

describe("HTTP retry policy", () => {
  it("does not retry a POST on network error (no double-bill)", async () => {
    const fetchMock = vi.fn().mockRejectedValue(new TypeError("network down"));
    vi.stubGlobal("fetch", fetchMock);
    await expect(client().post("/personas", { name: "x" })).rejects.toThrow();
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("retries a GET on network error", async () => {
    const fetchMock = vi.fn().mockRejectedValue(new TypeError("network down"));
    vi.stubGlobal("fetch", fetchMock);
    await expect(client().get("/personas")).rejects.toThrow();
    expect(fetchMock).toHaveBeenCalledTimes(3); // initial + 2 retries
  });

  it("does not retry a POST on 500 (may have executed)", async () => {
    const fetchMock = vi.fn().mockResolvedValue(jsonResponse(500));
    vi.stubGlobal("fetch", fetchMock);
    await expect(client().post("/personas", { name: "x" })).rejects.toThrow();
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("retries a POST on 503 (server did not process it)", async () => {
    const fetchMock = vi.fn().mockResolvedValue(jsonResponse(503));
    vi.stubGlobal("fetch", fetchMock);
    await expect(client().post("/personas", { name: "x" })).rejects.toThrow();
    expect(fetchMock).toHaveBeenCalledTimes(3);
  });
});
