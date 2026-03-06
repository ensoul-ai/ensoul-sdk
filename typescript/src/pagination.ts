export type PageFetcher<T> = (params: Record<string, unknown>) => Promise<{
  items: T[];
  total: number;
  page: number;
  perPage: number;
  pages: number;
}>;

export class Page<T> {
  readonly items: T[];
  readonly total: number;
  readonly page: number;
  readonly perPage: number;
  readonly pages: number;

  private readonly params: Record<string, unknown>;
  private readonly fetcher: PageFetcher<T>;

  constructor(data: {
    items: T[];
    total: number;
    page: number;
    perPage: number;
    pages: number;
    params: Record<string, unknown>;
    fetcher: PageFetcher<T>;
  }) {
    this.items = data.items;
    this.total = data.total;
    this.page = data.page;
    this.perPage = data.perPage;
    this.pages = data.pages;
    this.params = data.params;
    this.fetcher = data.fetcher;
  }

  hasNextPage(): boolean {
    return this.page < this.pages;
  }

  async nextPage(): Promise<Page<T>> {
    if (!this.hasNextPage()) {
      throw new Error(
        `No next page — currently on page ${this.page} of ${this.pages}`
      );
    }

    const nextParams = { ...this.params, page: this.page + 1 };
    const data = await this.fetcher(nextParams);

    return new Page<T>({
      ...data,
      params: nextParams,
      fetcher: this.fetcher,
    });
  }

  async *autoPagingIter(): AsyncIterableIterator<T> {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    let current: Page<T> = this;

    while (true) {
      for (const item of current.items) {
        yield item;
      }

      if (!current.hasNextPage()) break;
      current = await current.nextPage();
    }
  }

  [Symbol.asyncIterator](): AsyncIterator<T> {
    // Iterates over current page items only (consistent with Python's __iter__)
    let index = 0;
    const items = this.items;

    return {
      next(): Promise<IteratorResult<T>> {
        if (index < items.length) {
          return Promise.resolve({ value: items[index++]!, done: false });
        }
        return Promise.resolve({ value: undefined as unknown as T, done: true });
      },
    };
  }
}
