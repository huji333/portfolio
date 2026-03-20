import { test, expect } from '@playwright/test';

test.describe('Gallery', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/gallery');
  });

  test('displays image grid', async ({ page }) => {
    const images = page.getByRole('button').filter({ has: page.locator('img') });
    await expect(images.first()).toBeVisible({ timeout: 10_000 });

    const count = await images.count();
    expect(count).toBeGreaterThanOrEqual(3);
  });

  test('opens modal on image click', async ({ page }) => {
    const firstImage = page.getByRole('button', { name: 'Seed Image 1' });
    await expect(firstImage).toBeVisible({ timeout: 10_000 });

    await firstImage.click();

    const modal = page.getByRole('dialog');
    await expect(modal).toBeVisible({ timeout: 5_000 });
  });

  test('navigates with arrow keys and closes with Escape', async ({ page }) => {
    const firstImage = page.getByRole('button', { name: 'Seed Image 1' });
    await expect(firstImage).toBeVisible({ timeout: 10_000 });

    await firstImage.click();

    const modal = page.getByRole('dialog');
    await expect(modal).toBeVisible({ timeout: 5_000 });

    // Navigate forward
    await page.keyboard.press('ArrowRight');
    await expect(modal).toBeVisible();

    // Navigate backward
    await page.keyboard.press('ArrowLeft');
    await expect(modal).toBeVisible();

    // Close with Escape
    await page.keyboard.press('Escape');
    await expect(modal).not.toBeVisible();
  });

  test('filters images by category', async ({ page }) => {
    const images = page.getByRole('button').filter({ has: page.locator('img') });
    await expect(images.first()).toBeVisible({ timeout: 10_000 });

    const initialCount = await images.count();

    // Click a category checkbox
    const categoryCheckbox = page.getByRole('checkbox', { name: 'E2E Test Category' });
    if (await categoryCheckbox.isVisible()) {
      await categoryCheckbox.click();

      // Wait for filter to apply
      await page.waitForTimeout(1000);

      const filteredCount = await images.count();
      expect(filteredCount).toBeLessThanOrEqual(initialCount);
    }
  });
});
