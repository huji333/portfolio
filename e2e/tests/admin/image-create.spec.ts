import { test, expect } from '@playwright/test';
import path from 'path';

const testImage = path.join(__dirname, '..', '..', 'fixtures', 'test_image.jpg');

test.describe('Image Create with EXIF', () => {
  test('auto-populates fields from EXIF data and creates image', async ({ page }) => {
    await page.goto('/admin/images/new');

    // Selecting a file direct-uploads it, then the server resolves EXIF (ruby-vips)
    // and the form is filled with the camera/lens/taken_at it returns.
    await page.setInputFiles('#image_file', testImage);

    // Wait for EXIF reading
    await expect(page.locator('body')).toContainText('EXIFデータを自動読み取り中...', { timeout: 10_000 });

    // Wait for success message
    await expect(page.locator('body')).toContainText(/✓ \d+個のフィールドを自動更新しました/, { timeout: 15_000 });

    // Verify camera auto-selection (server resolves/creates from SONY ILCE-7CM2)
    await expect(page.locator('#image_camera_id')).toHaveValue(/.+/);

    // Verify title auto-populated from filename
    await expect(page.locator('#image_title')).toHaveValue('test_image');

    // Verify taken_at is populated
    await expect(page.locator('#image_taken_at')).not.toHaveValue('');

    // Fill remaining required fields
    await page.fill('#image_caption', 'Auto-populated from a7C II EXIF');
    await page.check('#image_is_published');

    // Check a category
    const categoryCheckbox = page.locator('input[id^="category_"]').first();
    await categoryCheckbox.check();

    await page.click('button:has-text("Save"), input[type="submit"][value="Save"]');

    await expect(page).toHaveURL(/\/admin\/images$/);
    await expect(page.locator('body')).toContainText('Image was successfully created.');
  });
});
