import { defineConfig, loadEnv } from "vite"
import vue from "@vitejs/plugin-vue"
import { resolve } from "path"

export default defineConfig(({ command, mode }) => {
  const env = loadEnv(mode, process.cwd(), "")
  
  return {
    plugins: [vue()],
    resolve: {
      alias: {
        "@": resolve(__dirname, "src")
      }
    },
    server: {
      port: 3000,
      open: true
    },
    build: {
      outDir: "dist",
      assetsDir: "assets",
      sourcemap: false,
      minify: "terser",
      rollupOptions: {
        output: {
          // 修复模块初始化问题 - 禁用分包
          manualChunks: undefined
        }
      },
      terserOptions: {
        compress: {
          drop_console: command === "build",
          drop_debugger: command === "build"
        }
      }
    },
    define: {
      __VUE_OPTIONS_API__: true,
      __VUE_PROD_DEVTOOLS__: false
    }
  }
})
