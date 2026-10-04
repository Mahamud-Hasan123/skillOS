import api from './api';

export const getUserProfile = (id) => api.get(`/users/${id}`);

export const updateProfile = (data) => api.put('/users/me', data);

export const changePassword = (data) => api.put('/users/me/password', data);

export const deleteAccount = (data) => api.delete('/users/me', { data });

export const getUserPreferences = () => api.get('/users/me/preferences');

export const updateUserPreferences = (data) => api.put('/users/me/preferences', data);
