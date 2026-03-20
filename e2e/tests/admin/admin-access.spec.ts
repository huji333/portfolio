import { test, expect } from '@playwright/test';

test.describe('Admin Access', () => {
  test('unauthenticated user is redirected to sign in page', async ({ browser }) => {
    // Use a fresh context with NO storageState to simulate unauthenticated user
    const context = await browser.newContext({
      baseURL: test.info().project.use.baseURL!,
      storageState: { cookies: [], origins: [] },
    });
    const page = await context.newPage();

    await page.goto('/admin');
    await expect(page).toHaveURL(/sign_in/);

    await context.close();
  });

  test('guest user cannot access /admin', async ({ browser }) => {
    // Login as guest in a fresh context
    const context = await browser.newContext({
      baseURL: test.info().project.use.baseURL!,
      storageState: { cookies: [], origins: [] },
    });
    const page = await context.newPage();

    // Login as guest
    await page.goto('/users/sign_in');
    await page.getByRole('textbox', { name: 'Email' }).fill('guest@example.com');
    await page.getByRole('textbox', { name: 'Password' }).fill('password123');
    await page.getByRole('button', { name: 'Log in' }).click();

    // Wait for login to complete (Devise redirects to root, which may 404 — that's OK)
    await page.waitForURL((url) => !url.pathname.includes('sign_in'), { timeout: 10_000 });

    // Now try to access admin
    await page.goto('/admin');
    await expect(page.locator('body')).toContainText('You are not authorized to perform this action.');

    await context.close();
  });

  test('admin user can access /admin', async ({ page }) => {
    // Uses storageState from setup (admin login)
    await page.goto('/admin');
    await expect(page).toHaveURL(/\/admin$/);
    await expect(page.locator('body')).toContainText('管理者ページ');
  });
});
