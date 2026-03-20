import { test, expect } from '@playwright/test';
import path from 'path';

const testImage = path.join(__dirname, '..', '..', 'fixtures', 'test_image.jpg');

test.describe('Project management', () => {
  test('creates a project with file upload', async ({ page }) => {
    await page.goto('/admin/projects/new');

    await page.fill('#project_title', 'E2E Test Project');
    await page.fill('#project_link', 'https://example.com/e2e-test');

    await page.setInputFiles('#project_file', testImage);
    await page.click('button:has-text("保存"), input[type="submit"][value="保存"]');

    await expect(page).toHaveURL(/\/admin\/projects$/);
    await expect(page.locator('body')).toContainText('Project was successfully created.');
  });
});
