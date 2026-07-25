/**
 * Headroom Retrieve Extension
 * 
 * Registers the headroom_retrieve tool so pi can retrieve compressed content.
 * This extension connects to your Headroom MCP server or proxy API.
 * 
 * Usage: When you see compression markers like [N items compressed... hash=abc123],
 * call headroom_retrieve with the hash to get the full content.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const HEADROOM_BASE_URL = "http://codenamekt-nuc:8787";
const HEADROOM_API_KEY = process.env.HEADROOM_API_KEY ?? "";

const RetrieveParams = Type.Object({
  hash: Type.String({ 
    description: "The hash/id of the compressed content to retrieve" 
  }),
  max_items: Type.Optional(Type.Number({ 
    description: "Maximum number of items to retrieve (default: 10)" 
  })),
});

export default function (pi: ExtensionAPI) {
  // Register the headroom_retrieve tool
  pi.registerTool({
    name: "headroom_retrieve",
    label: "Headroom Retrieve",
    description: `Retrieve original (uncompressed) content from Headroom's CCR store. 
Use this when you see compression markers like "[N items compressed... hash=abc123]".
The hash is required to retrieve the original content.`,
    parameters: RetrieveParams,

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const { hash, max_items = 10 } = params;

      try {
        // Try MCP server first (if headroom mcp serve is running)
        const mcpResponse = await fetch(`${HEADROOM_BASE_URL}/mcp`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${HEADROOM_API_KEY}`,
          },
          body: JSON.stringify({
            jsonrpc: "2.0",
            id: Date.now(),
            method: "tools/call",
            params: {
              name: "headroom_retrieve",
              arguments: { hash, max_items }
            }
          }),
        });

        if (mcpResponse.ok) {
          const mcpResult = await mcpResponse.json();
          if (mcpResult.result) {
            return {
              content: [{ 
                type: "text", 
                text: typeof mcpResult.result === 'string' 
                  ? mcpResult.result 
                  : JSON.stringify(mcpResult.result, null, 2)
              }],
              details: { 
                hash, 
                max_items,
                source: "mcp"
              },
            };
          }
        }
      } catch (_mcpError) {
        // MCP not available, try REST API fallback
      }

      // Fallback: Try the proxy's CCR retrieve endpoint
      try {
        const response = await fetch(`${HEADROOM_BASE_URL}/retrieve/${hash}`, {
          method: "GET",
          headers: {
            "Authorization": `Bearer ${HEADROOM_API_KEY}`,
          },
        });

        if (response.ok) {
          const data = await response.json();
          return {
            content: [{ 
              type: "text", 
              text: typeof data === 'string' ? data : JSON.stringify(data, null, 2)
            }],
            details: { 
              hash, 
              max_items,
              source: "rest"
            },
          };
        }
      } catch (_restError) {
        // REST also not available
      }

      return {
        content: [{ 
          type: "text", 
          text: `Could not retrieve content for hash: ${hash}. Make sure Headroom MCP server or proxy is running at ${HEADROOM_BASE_URL}.` 
        }],
        details: { 
          hash, 
          error: "connection_failed" 
        },
      };
    },
  });

  // Also register headroom_stats for convenience
  pi.registerTool({
    name: "headroom_stats",
    label: "Headroom Stats",
    description: `Get Headroom compression statistics including tokens saved, compression ratio, and cache hit rate.`,
    parameters: Type.Object({}),

    async execute(_toolCallId, _params, _signal, _onUpdate, _ctx) {
      try {
        const response = await fetch(`${HEADROOM_BASE_URL}/stats`, {
          method: "GET",
          headers: {
            "Authorization": `Bearer ${HEADROOM_API_KEY}`,
          },
        });

        if (response.ok) {
          const data = await response.json();
          return {
            content: [{ 
              type: "text", 
              text: typeof data === 'string' ? data : JSON.stringify(data, null, 2)
            }],
            details: { source: "rest" },
          };
        }
      } catch (_error) {
        // Stats endpoint not available
      }

      return {
        content: [{ 
          type: "text", 
          text: `Could not fetch Headroom stats. Make sure Headroom proxy is running at ${HEADROOM_BASE_URL}.` 
        }],
        details: { error: "connection_failed" },
      };
    },
  });

  // Register headroom_compress for manual compression testing
  pi.registerTool({
    name: "headroom_compress",
    label: "Headroom Compress",
    description: `Manually compress content through Headroom. Returns a hash that can be used to retrieve the original.`,
    parameters: Type.Object({
      content: Type.String({ description: "The content to compress" }),
      content_type: Type.Optional(Type.String({ 
        description: "Content type hint (e.g., 'json', 'code', 'text')" 
      })),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const { content, content_type = "text" } = params;

      try {
        const response = await fetch(`${HEADROOM_BASE_URL}/compress`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${HEADROOM_API_KEY}`,
          },
          body: JSON.stringify({ content, content_type }),
        });

        if (response.ok) {
          const data = await response.json();
          return {
            content: [{ 
              type: "text", 
              text: `Content compressed successfully.\n\nHash: ${data.hash || data.id}\nCompressed size: ${data.compressed_size || 'N/A'}\nOriginal size: ${data.original_size || content.length}` 
            }],
            details: data,
          };
        }
      } catch (_error) {
        // Compression endpoint not available
      }

      return {
        content: [{ 
          type: "text", 
          text: `Could not compress content. Make sure Headroom proxy is running at ${HEADROOM_BASE_URL}.` 
        }],
        details: { error: "connection_failed" },
      };
    },
  });
}
