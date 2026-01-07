import {LucideIcon} from 'lucide-react-native';

export interface IBaseDictionaryEntry<T> {
  readonly id: T;
  readonly name: string;
  readonly icon?: LucideIcon;
}

export interface IStatusDictionaryEntry<T> extends IBaseDictionaryEntry<T> {
  color?: string;
}
export interface IContractDictionaryEntry<T> extends IBaseDictionaryEntry<T> {
  key: string;
}

export interface IDescriptedDictionaryEntry<T> extends IBaseDictionaryEntry<T> {
  description?: string;
}

export interface IFailureDictionaryEntry<T> extends IBaseDictionaryEntry<T> {
  failure?: string;
}

export class Dictionary<
  T,
  IValue extends IBaseDictionaryEntry<T> = IBaseDictionaryEntry<T>,
> {
  private readonly _items: IValue[];

  constructor(items: IValue[]) {
    this._items = items;
  }

  get items(): IValue[] {
    return this._items;
  }

  byId(idQuery: T) {
    return this._items.find(({id}) => id === idQuery);
  }

  getName = (idQuery: T) => {
    return this.byId(idQuery)?.name || 'unknown';
  };

  getOptions() {
    return this._items.map(({id, name}) => ({id, value: name}));
  }

  getOption(idQuery: T) {
    const opt = this.byId(idQuery);
    if (!opt) {
      return undefined;
    }

    return {
      id: opt?.id,
      value: opt?.name,
    };
  }

  getOptionByName(nameQuery: string | null | undefined) {
    if (!nameQuery) {
      return undefined;
    }

    return this._items.find(({name}) => name === nameQuery);
  }
}
