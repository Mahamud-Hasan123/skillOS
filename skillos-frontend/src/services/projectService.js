import api from './api';

export const getUserProjects = () => api.get('/projects');
export const getProject = (id) => api.get(`/projects/${id}`);
export const createProject = (data) => api.post('/projects', data);
export const setActiveProject = (id) => api.post(`/projects/${id}/active`);
export const getKanbanBoard = (projectId) => api.get(`/projects/${projectId}/kanban`);
export const moveKanbanCard = (cardId, data) => api.put(`/kanban/cards/${cardId}/move`, data);
export const getProjectGenerationStatus = (jobId) => api.get(`/projects/generate/status/${jobId}`);
export const getProjectGanttEntries = (projectId) => api.get(`/projects/${projectId}/gantt`);
export const deleteProject = (id) => api.delete(`/projects/${id}`);
