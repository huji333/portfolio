import { defineConfig, devices } from '@playwright/test';

const BACKEND_PORT = 3000;
const FRONTEND_PORT = 3002;
const BACKEND_URL = `http://localhost:${BACKEND_PORT}`;
const FRONTEND_URL = `http://localhost:${FRONTEND_PORT}`;

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: process.env.CI ? [['github'], ['html']] : 'html',
  use: {
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    // Setup: login and save storageState
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
      use: {
        baseURL: BACKEND_URL,
      },
    },

    // Admin tests (Rails backend)
    {
      name: 'admin',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: BACKEND_URL,
        storageState: '.auth/admin.json',
      },
      dependencies: ['setup'],
      testDir: './tests/admin',
    },

    // Frontend tests (Next.js)
    {
      name: 'frontend',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: FRONTEND_URL,
      },
      testDir: './tests/frontend',
    },
  ],

  webServer: [
    {
      command: `cd ../backend && RAILS_ENV=test bundle exec rails server -p ${BACKEND_PORT}`,
      url: `${BACKEND_URL}/up`,
      reuseExistingServer: !process.env.CI,
      timeout: 30_000,
    },
    {
      command: `cd ../frontend && NEXT_PUBLIC_API_BASE_URL=${BACKEND_URL}/api API_BASE_URL=${BACKEND_URL}/api npx next dev -p ${FRONTEND_PORT}`,
      url: FRONTEND_URL,
      reuseExistingServer: !process.env.CI,
      timeout: 30_000,
    },
  ],
});
