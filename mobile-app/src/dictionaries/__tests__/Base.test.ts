import {Dictionary, IBaseDictionaryEntry} from '../Base';

type Id = number;
type Entry = IBaseDictionaryEntry<Id>;

const sampleItems: Entry[] = [
  {id: 1, name: 'One'},
  {id: 2, name: 'Two'},
  {id: 3, name: 'Three'},
];

describe('Dictionary Base', () => {
  it('exposes items', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.items).toEqual(sampleItems);
  });

  it('byId returns matching entry or undefined', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.byId(2)).toEqual({id: 2, name: 'Two'});
    expect(dict.byId(99)).toBeUndefined();
  });

  it('getName returns entry name or "unknown"', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.getName(1)).toBe('One');
    expect(dict.getName(42)).toBe('unknown');
  });

  it('getOptions maps items to id/value pairs', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.getOptions()).toEqual([
      {id: 1, value: 'One'},
      {id: 2, value: 'Two'},
      {id: 3, value: 'Three'},
    ]);
  });

  it('getOption returns id/value for existing id or undefined', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.getOption(3)).toEqual({id: 3, value: 'Three'});
    expect(dict.getOption(404 as any)).toBeUndefined();
  });

  it('getOptionByName returns entry by name or undefined for falsy/name not found', () => {
    const dict = new Dictionary<Id, Entry>(sampleItems);
    expect(dict.getOptionByName('Two')).toEqual({id: 2, name: 'Two'});
    expect(dict.getOptionByName('Nope')).toBeUndefined();
    expect(dict.getOptionByName('')).toBeUndefined();
    expect(dict.getOptionByName(null as any)).toBeUndefined();
    expect(dict.getOptionByName(undefined as any)).toBeUndefined();
  });
});
