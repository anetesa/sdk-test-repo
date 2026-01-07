import {GrowthBook} from '@growthbook/growthbook-react';
import {runtimeConfig} from '@/utils/runtimeConfig';

class GrowthBookSingleton {
  private static _instance: GrowthBook;

  constructor() {
    runtimeConfig.addEnvironmentChangeListener(
      this.onEnvironmentChange.bind(this),
    );
    this.reinitialize();
  }

  get instance(): GrowthBook {
    return GrowthBookSingleton._instance;
  }

  public reinitialize(): void {
    GrowthBookSingleton._instance = new GrowthBook({
      apiHost: runtimeConfig.APP_GROWTHBOOK_API_HOST,
      clientKey: runtimeConfig.APP_GROWTHBOOK_CLIENT_KEY,
    });
  }

  public onEnvironmentChange(): void {
    this.reinitialize();
    // https://docs.growthbook.io/lib/react#error-handling
    growthBook.instance.init();
  }
}

export const growthBook = new GrowthBookSingleton();
