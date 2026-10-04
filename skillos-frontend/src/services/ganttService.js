import api from './api';

export const getProjectGanttEntries = (projectId) => api.get(`/projects/${projectId}/gantt`);
export const updateGanttEntry = (id, data) => api.put(`/gantt/entries/${id}`, data);
