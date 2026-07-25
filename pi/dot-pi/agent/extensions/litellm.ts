import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const apiKey = process.env.HEADROOM_API_KEY;
  if (!apiKey) {
    console.warn("WARNING: HEADROOM_API_KEY environment variable is not set. Please set it in ~/.zshenv.local");
  }

  let models: any[] = [];
  try {
    const response = await fetch("http://codenamekt-nuc:8787/v1/models", {
      headers: {
        "Authorization": `Bearer ${apiKey ?? ""}`
      }
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch models: ${response.status} ${response.statusText}`);
    }
    const payload = (await response.json()) as {
      data: Array<{
        id: string;
        object?: string;
        created?: number;
        owned_by?: string;
      }>;
    };

    models = payload.data.map((model) => {
      const id = model.id;
      // Prettify name: replace tobiTradez/ and dashes with spaces, capitalize
      const name = id
        .replace(/^tobiTradez\//, "")
        .split("-")
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ");

      const isReasoning = id.includes("reasoning") || id.includes("think") || id.includes("opus") || id.includes("deepseek-v4-pro");
      const supportsVision = id.includes("gpt-4o") || id.includes("sonnet") || id.includes("gemini") || id.includes("opus");

      return {
        id: id,
        name: name,
        reasoning: isReasoning,
        input: supportsVision ? ["text", "image"] : ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      };
    });
  } catch (err) {
    console.warn("Failed to load LiteLLM Proxy models dynamically. Falling back to default models list. Error:", err instanceof Error ? err.message : err);
    // Fallback static models to ensure provider registration succeeds
    models = [
      {
        id: "tobiTradez/minimax-m2.7-highspeed",
        name: "Minimax M2.7 Highspeed",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      },
      {
        id: "tobiTradez/minimax-m3",
        name: "Minimax M3",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      },
      {
        id: "tobiTradez/gemini-3.5-flash",
        name: "Gemini 3.5 Flash",
        reasoning: false,
        input: ["text", "image"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      },
      {
        id: "tobiTradez/deepseek-v4-pro",
        name: "Deepseek V4 Pro",
        reasoning: true,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      }
    ];
  }

  pi.registerProvider("headroom", {
    name: "Headroom Proxy",
    baseUrl: "http://codenamekt-nuc:8787/v1",
    apiKey: apiKey ?? "",
    api: "openai-completions",
    models: models,
  });
}

