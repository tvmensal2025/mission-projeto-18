module.exports = {
  "build": {
    "command": "npm run build:prod",
    "output": "dist",
    "install": "npm ci"
  },
  "env": {
    "NODE_ENV": "production",
    "NODE_VERSION": "18"
  },
  "ignore": [
    "node_modules",
    ".git",
    "dist",
    "build",
    "*.log",
    ".env.local",
    ".env.production",
    "coverage",
    ".nyc_output",
    "test-*.js",
    "teste-*.js",
    "*.md",
    "docs/",
    "supabase/functions/",
    "supabase/migrations/",
    "update-*.js",
    "fix-*.js",
    "create-*.js"
  ],
  "cache": {
    "paths": [
      "node_modules/.cache",
      ".vite"
    ]
  },
  "network": {
    "timeout": 300000
  }
};