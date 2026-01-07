export const getGenericPassword = jest.fn().mockResolvedValue({
  username: 'testuser',
  password: JSON.stringify({authToken: 'test-token'}),
});

export const setGenericPassword = jest.fn().mockResolvedValue(undefined);
export const resetGenericPassword = jest.fn().mockResolvedValue(undefined);
