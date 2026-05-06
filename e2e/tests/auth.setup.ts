import { test as setup, expect } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '..', '.auth', 'admin.json');

setup('authenticate as admin', async ({ page }) => {
  const email = process.env.E2E_ADMIN_EMAIL ?? 'admin@example.com';
  const password = process.env.E2E_ADMIN_PASSWORD ?? 'password123';

  await page.goto('/users/sign_in');

  await page.getByRole('textbox', { name: 'Email' }).fill(email);
  await page.getByRole('textbox', { name: 'Password' }).fill(password);
  await page.getByRole('button', { name: 'Log in' }).click();

  // Wait for redirect after login
  await expect(page).not.toHaveURL(/sign_in/);

  await page.context().storageState({ path: authFile });
});
