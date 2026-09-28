import { test, expect } from '@playwright/test';

test.describe('Gallery', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/gallery');
    await expect(page.getByRole('button', { name: 'Seed Image 1' })).toBeVisible({ timeout: 10_000 });
  });

  test('opens the modal, navigates with arrow keys and closes with Escape', async ({ page }) => {
    await page.getByRole('button', { name: 'Seed Image 1' }).click();

    // モーダルは表示中の画像タイトルを accessible name に持つ。
    // featured は Seed Image 1→2 の順に並ぶ（a-image-sort で 3 が先頭へ移っても 1→2 は隣接のまま）。
    await expect(page.getByRole('dialog', { name: 'Seed Image 1' })).toBeVisible({ timeout: 5_000 });

    await page.keyboard.press('ArrowRight');
    await expect(page.getByRole('dialog', { name: 'Seed Image 2' })).toBeVisible();

    await page.keyboard.press('ArrowLeft');
    await expect(page.getByRole('dialog', { name: 'Seed Image 1' })).toBeVisible();

    await page.keyboard.press('Escape');
    await expect(page.getByRole('dialog')).not.toBeVisible();
  });

  // seed（e2e:seed）で Seed Image 1..3 は E2E Test Category、Seed Other Photo だけが
  // E2E Other Category に属する。チェック→API 再取得→グリッド差し替えの配線を実 API で踏む。
  test('filters images by category and restores them when unchecked', async ({ page }) => {
    const seedImage = page.getByRole('button', { name: 'Seed Image 1' });
    const otherPhoto = page.getByRole('button', { name: 'Seed Other Photo' });
    const otherCategory = page.getByRole('checkbox', { name: 'E2E Other Category' });

    // 再取得中はグリッドが一時的に消えるため、否定アサーションはロード完了後に行う。
    // レスポンス受信後、state 反映（=チェックボックスの再有効化）まで待ってから判定する。
    const filtered = page.waitForResponse((res) => res.url().includes('/api/images?categories='));
    await otherCategory.check();
    await filtered;
    await expect(otherCategory).toBeEnabled();
    await expect(otherPhoto).toBeVisible();
    await expect(seedImage).not.toBeVisible();

    await otherCategory.uncheck();
    await expect(seedImage).toBeVisible();
  });
});
