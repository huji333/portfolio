import { test, expect } from '@playwright/test';

test.describe('Image Sort', () => {
  test('reorders images via drag and drop', async ({ page }) => {
    await page.goto('/admin/images');

    // Verify seed images exist
    await expect(page.locator('tr[data-image-id]', { hasText: 'Seed Image 1' })).toBeVisible();
    await expect(page.locator('tr[data-image-id]', { hasText: 'Seed Image 2' })).toBeVisible();
    await expect(page.locator('tr[data-image-id]', { hasText: 'Seed Image 3' })).toBeVisible();

    // Verify drag handles exist
    await expect(page.locator('.handle').first()).toBeVisible();

    // Get the drag handle of Seed Image 3 and the target row (Seed Image 1)
    const sourceRow = page.locator('tr[data-image-id]', { hasText: 'Seed Image 3' });
    const targetRow = page.locator('tr[data-image-id]', { hasText: 'Seed Image 1' });
    const handle = sourceRow.locator('.handle');

    // Use explicit mouse operations for more reliable drag and drop
    const sourceBbox = await handle.boundingBox();
    const targetBbox = await targetRow.boundingBox();

    if (sourceBbox && targetBbox) {
      const sourceX = sourceBbox.x + sourceBbox.width / 2;
      const sourceY = sourceBbox.y + sourceBbox.height / 2;
      const targetX = targetBbox.x + targetBbox.width / 2;
      const targetY = targetBbox.y + targetBbox.height / 2;

      await page.mouse.move(sourceX, sourceY);
      await page.mouse.down();
      // Move in steps for sortable to detect
      await page.mouse.move(targetX, targetY, { steps: 10 });
      await page.mouse.up();
    }

    // Wait for the sort to settle
    await page.waitForTimeout(2000);

    // Verify Seed Image 3 moved above Seed Image 1
    const rows = page.locator('tbody[data-sortable-target="list"] tr');
    const allTexts: string[] = [];
    const rowCount = await rows.count();
    for (let i = 0; i < rowCount; i++) {
      allTexts.push(await rows.nth(i).innerText());
    }

    // Find positions of seed images
    const pos3 = allTexts.findIndex((t) => t.includes('Seed Image 3'));
    const pos1 = allTexts.findIndex((t) => t.includes('Seed Image 1'));

    expect(pos3).toBeLessThan(pos1);
  });
});
