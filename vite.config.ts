import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { VitePWA } from "vite-plugin-pwa";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  server: {
    host: "::",
    port: 8080,
    hmr: {
      overlay: false,
    },
  },
  plugins: [
    react(),
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["bg-logo.svg", "robots.txt"],
      manifest: {
        name: "BG ADM Financeiro",
        short_name: "BG ADM",
        description: "Sistema de Administração Financeira BG",
        theme_color: "#3d4b26",
        background_color: "#3d4b26",
        display: "standalone",
        start_url: "/",
        icons: [
          {
            src: "bg-logo.svg",
            sizes: "any",
            type: "image/svg+xml",
            purpose: "any maskable",
          },
        ],
      },
    }),
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
}));



