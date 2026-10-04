import api from './api';

export const getNotifications = (page = 0, size = 20) => 
  api.get(`/notifications?page=${page}&size=${size}`);

export const markAllAsRead = () => api.put('/notifications/read-all');
