import { describe, it, expect, beforeEach, vi } from "vitest";
import { Page, type PageFetcher } from "../src/pagination.js";

beforeEach(() => {
  vi.restoreAllMocks();
});

type TestItem = { id: string; name: string };

function makeItems(count: number, offset = 0): TestItem[] {
  return Array.from({ length: count }, (_, i) => ({
    id: `item_${offset + i + 1}`,
    name: `Item ${offset + i + 1}`,
  }));
}

function makePage(
  items: TestItem[],
  total: number,
  page: number,
  perPage: number,
  pages: number,
  fetcher?: PageFetcher<TestItem>
): Page<TestItem> {
  return new Page<TestItem>({
    items,
    total,
    page,
    perPage,
    pages,
    params: { page, per_page: perPage },
    fetcher:
      fetcher ??
      vi.fn().mockResolvedValue({ items: [], total, page: page + 1, perPage, pages }),
  });
}

describe("Page", () => {
  describe("hasNextPage()", () => {
    it("returns true when on page 1 of 3", () => {
      const page = makePage(makeItems(10), 30, 1, 10, 3);
      expect(page.hasNextPage()).toBe(true);
    });

    it("returns true when on page 2 of 3", () => {
      const page = makePage(makeItems(10), 30, 2, 10, 3);
      expect(page.hasNextPage()).toBe(true);
    });

    it("returns false on the last page (page = pages)", () => {
      const page = makePage(makeItems(10), 30, 3, 10, 3);
      expect(page.hasNextPage()).toBe(false);
    });

    it("returns false when there is only one page", () => {
      const page = makePage(makeItems(3), 3, 1, 20, 1);
      expect(page.hasNextPage()).toBe(false);
    });

    it("returns false when page > pages (defensive)", () => {
      const page = makePage(makeItems(0), 0, 5, 10, 1);
      expect(page.hasNextPage()).toBe(false);
    });
  });

  describe("nextPage()", () => {
    it("fetches the next page via fetcher", async () => {
      const page2Items = makeItems(10, 10);
      const fetcher = vi.fn().mockResolvedValue({
        items: page2Items,
        total: 20,
        page: 2,
        perPage: 10,
        pages: 2,
      });
      const page1 = makePage(makeItems(10), 20, 1, 10, 2, fetcher);

      const page2 = await page1.nextPage();

      expect(fetcher).toHaveBeenCalledOnce();
      expect(page2.page).toBe(2);
      expect(page2.items).toHaveLength(10);
      expect(page2.items[0].id).toBe("item_11");
    });

    it("passes incremented page number to fetcher", async () => {
      const fetcher = vi.fn().mockResolvedValue({
        items: [],
        total: 20,
        page: 2,
        perPage: 10,
        pages: 2,
      });
      const page1 = makePage(makeItems(10), 20, 1, 10, 2, fetcher);

      await page1.nextPage();

      const fetcherArgs = fetcher.mock.calls[0][0] as Record<string, unknown>;
      expect(fetcherArgs.page).toBe(2);
    });

    it("throws when called on the last page", async () => {
      const page = makePage(makeItems(10), 10, 1, 10, 1);
      await expect(page.nextPage()).rejects.toThrow();
    });

    it("throws with descriptive message when no more pages", async () => {
      const page = makePage(makeItems(5), 5, 1, 10, 1);
      await expect(page.nextPage()).rejects.toThrow(/no next page/i);
    });
  });

  describe("autoPagingIter()", () => {
    it("yields all items across a single page", async () => {
      const items = makeItems(5);
      const fetcher = vi.fn();
      const page = makePage(items, 5, 1, 10, 1, fetcher);

      const collected: TestItem[] = [];
      for await (const item of page.autoPagingIter()) {
        collected.push(item);
      }

      expect(collected).toHaveLength(5);
      expect(fetcher).not.toHaveBeenCalled();
    });

    it("yields all items across multiple pages", async () => {
      const page1Items = makeItems(10);
      const page2Items = makeItems(10, 10);
      const page3Items = makeItems(5, 20);

      const fetcher = vi
        .fn()
        .mockResolvedValueOnce({
          items: page2Items,
          total: 25,
          page: 2,
          perPage: 10,
          pages: 3,
        })
        .mockResolvedValueOnce({
          items: page3Items,
          total: 25,
          page: 3,
          perPage: 10,
          pages: 3,
        });

      const page1 = makePage(page1Items, 25, 1, 10, 3, fetcher);

      const collected: TestItem[] = [];
      for await (const item of page1.autoPagingIter()) {
        collected.push(item);
      }

      expect(collected).toHaveLength(25);
      expect(fetcher).toHaveBeenCalledTimes(2);
    });

    it("yields items in order across pages", async () => {
      const page1Items = makeItems(3);
      const page2Items = makeItems(2, 3);

      const fetcher = vi.fn().mockResolvedValueOnce({
        items: page2Items,
        total: 5,
        page: 2,
        perPage: 3,
        pages: 2,
      });

      const page1 = makePage(page1Items, 5, 1, 3, 2, fetcher);
      const collected: TestItem[] = [];
      for await (const item of page1.autoPagingIter()) {
        collected.push(item);
      }

      expect(collected.map((i) => i.id)).toEqual([
        "item_1",
        "item_2",
        "item_3",
        "item_4",
        "item_5",
      ]);
    });

    it("handles empty page correctly", async () => {
      const page = makePage([], 0, 1, 20, 0, vi.fn());

      const collected: TestItem[] = [];
      for await (const item of page.autoPagingIter()) {
        collected.push(item);
      }

      expect(collected).toHaveLength(0);
    });
  });

  describe("[Symbol.asyncIterator] — current page only", () => {
    it("iterating with for await...of yields only current page items", async () => {
      const items = makeItems(3);
      const fetcher = vi.fn();
      const page = makePage(items, 30, 1, 3, 10, fetcher);

      const collected: TestItem[] = [];
      for await (const item of page) {
        collected.push(item);
      }

      // Should only yield items from the current page, not auto-paginate
      expect(collected).toHaveLength(3);
      expect(fetcher).not.toHaveBeenCalled();
    });

    it("yields items from current page in order", async () => {
      const items = [
        { id: "item_alpha", name: "Alpha" },
        { id: "item_beta", name: "Beta" },
      ];
      const page = makePage(items, 2, 1, 10, 1);

      const collected: TestItem[] = [];
      for await (const item of page) {
        collected.push(item);
      }

      expect(collected[0].id).toBe("item_alpha");
      expect(collected[1].id).toBe("item_beta");
    });
  });

  describe("Page properties", () => {
    it("exposes items correctly", () => {
      const items = makeItems(3);
      const page = makePage(items, 3, 1, 20, 1);
      expect(page.items).toBe(items);
    });

    it("exposes total correctly", () => {
      const page = makePage(makeItems(3), 100, 1, 20, 5);
      expect(page.total).toBe(100);
    });

    it("exposes page number correctly", () => {
      const page = makePage(makeItems(3), 100, 2, 20, 5);
      expect(page.page).toBe(2);
    });

    it("exposes perPage correctly", () => {
      const page = makePage(makeItems(3), 100, 1, 20, 5);
      expect(page.perPage).toBe(20);
    });

    it("exposes pages correctly", () => {
      const page = makePage(makeItems(3), 100, 1, 20, 5);
      expect(page.pages).toBe(5);
    });
  });
});
