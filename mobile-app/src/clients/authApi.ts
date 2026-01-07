import axios from 'axios';

const authApi = axios.create({
  headers: {'Content-Type': 'application/json'},
  withCredentials: false,
});

export default authApi;
