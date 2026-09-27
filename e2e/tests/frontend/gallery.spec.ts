import { test, expect } from '@playwright/test';

test.describe('Gallery', () => {
  test('opens the modal, navigates with arrow keys and closes with Escape', async ({ page }) => {
    await page.goto('/gallery');

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
});
