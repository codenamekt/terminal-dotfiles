import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

export default async function (pi: ExtensionAPI) {
  // 1. Try to read HEADROOM_API_KEY from environment
  let apiKey = process.env.HEADROOM_API_KEY;

  // 2. Fallback: Read from ~/.config/headroom/env (cross-shell, outside the dotfiles/stow tree)
  //    File format: KEY=VALUE per line (e.g. HEADROOM_API_KEY=... or LITELLM_MASTER_KEY=...)
  if (!apiKey) {
    try {
      const envFile = path.join(os.homedir(), ".config", "headroom", "env");
      if (fs.existsSync(envFile)) {
        const content = fs.readFileSync(envFile, "utf8");
        const match = content.match(/^HEADROOM_API_KEY=(.+)$/m)
          || content.match(/^LITELLM_MASTER_KEY=(.+)$/m)
          || content.match(/^HEADROOM_INTERNAL_TOKEN=(.+)$/m);
        if (match) {
          apiKey = match[1].trim().replace(/^["']|["']$/g, "");
        }
      }
    } catch (err) {
      // ignore read error (perms, missing file, etc.)
    }
  }

  // 3. No key available — bail out cleanly and use the static fallback model list.
  //    We intentionally do NOT hardcode a fallback key here. If you need offline
  //    access to the headroom proxy, set HEADROOM_API_KEY in ~/.config/headroom/env.
  if (!apiKey) {
    console.warn(
      "headroom provider: no API key found in HEADROOM_API_KEY env var or ~/.config/headroom/env. " +
      "Using static fallback model list (proxy features disabled)."
    );
  }

  let models: any[] = [];
  try {
    const response = await fetch("http://codenamekt-nuc:8787/v1/models", {
      headers: {
        "Authorization": `Bearer ${apiKey}`
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
      // Models that support image input. Add new entries here when new vision-capable
      // model families appear on the proxy. Keep in sync with the static fallback below.
      const supportsVision = id.includes("gpt-4o")
        || id.includes("sonnet")
        || id.includes("gemini")
        || id.includes("opus")
        || id.includes("minimax");

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
        id: "minimax/minimax-m2.7",
        name: "Minimax M2.7",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      },
      {
        id: "minimax/minimax-m3",
        name: "Minimax M3",
        reasoning: false,
        input: ["text", "image"],
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

