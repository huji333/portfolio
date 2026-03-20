import { test as setup, expect } from '@playwright/test';
import path from 'path';

const authFile = path.join(__dirname, '..', '.auth', 'admin.json');

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/users/sign_in');

  await page.getByRole('textbox', { name: 'Email' }).fill('admin@example.com');
  await page.getByRole('textbox', { name: 'Password' }).fill('password123');
  await page.getByRole('button', { name: 'Log in' }).click();

  // Wait for redirect after login
  await expect(page).not.toHaveURL(/sign_in/);

  await page.context().storageState({ path: authFile });
});
