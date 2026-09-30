import { test, expect } from '@playwright/test';

test.describe('Image Sort', () => {
  test('reorders images via drag and drop', async ({ page }) => {
    await page.goto('/admin/images/arrange');

    // Verify seed images exist
    await expect(page.locator('tr[data-sortable-id]', { hasText: 'Seed Image 1' })).toBeVisible();
    await expect(page.locator('tr[data-sortable-id]', { hasText: 'Seed Image 2' })).toBeVisible();
    await expect(page.locator('tr[data-sortable-id]', { hasText: 'Seed Image 3' })).toBeVisible();

    // Verify drag handles exist
    await expect(page.locator('.handle').first()).toBeVisible();

    // Get the drag handle of Seed Image 3 and the target row (Seed Image 1)
    const sourceRow = page.locator('tr[data-sortable-id]', { hasText: 'Seed Image 3' });
    const targetRow = page.locator('tr[data-sortable-id]', { hasText: 'Seed Image 1' });
    const handle = sourceRow.locator('.handle');

    // Use explicit mouse operations for more reliable drag and drop
    const sourceBbox = await handle.boundingBox();
    const targetBbox = await targetRow.boundingBox();
    if (!sourceBbox || !targetBbox) throw new Error('drag handle / target row is not laid out');

    const sourceX = sourceBbox.x + sourceBbox.width / 2;
    const sourceY = sourceBbox.y + sourceBbox.height / 2;
    const targetX = targetBbox.x + targetBbox.width / 2;
    // Seed Image 1 の行より上までオーバーシュートする。ドラッグ中は行が
    // リフローして bbox が古くなるため、中央狙いだと直下に入って「上へ移動」
    // にならない。行の上端を明確に越える位置へ落とす。
    const targetY = targetBbox.y - targetBbox.height / 2;

    // 固定 sleep ではなく、ドロップ後の insert_at の完了を待つ
    const insertAt = page.waitForResponse(
      (res) => res.url().includes('/insert_at') && res.request().method() === 'POST',
    );

    await page.mouse.move(sourceX, sourceY);
    await page.mouse.down();
    // まず少し動かして Sortable のドラッグ開始をトリガーする
    await page.mouse.move(sourceX, sourceY - 8, { steps: 4 });
    // ターゲット行の上へ複数ステップで移動して確実に先頭へ差し込む
    await page.mouse.move(targetX, targetY, { steps: 15 });
    await page.mouse.up();

    expect((await insertAt).ok()).toBe(true);

    // DOM 上の並びではなく、サーバーに永続化された順序を再読込して検証する
    await page.reload();
    const rows = page.locator('tbody[data-sortable-target="list"] tr');
    const allTexts = await rows.allInnerTexts();

    const pos3 = allTexts.findIndex((t) => t.includes('Seed Image 3'));
    const pos1 = allTexts.findIndex((t) => t.includes('Seed Image 1'));

    expect(pos3).toBeLessThan(pos1);
  });
});
