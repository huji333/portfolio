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

  test('admin user can access /admin', async ({ page }) => {
    // Uses storageState from setup (admin login)
    await page.goto('/admin');
    await expect(page).toHaveURL(/\/admin$/);
    await expect(page.locator('body')).toContainText('管理者ページ');
  });
});
