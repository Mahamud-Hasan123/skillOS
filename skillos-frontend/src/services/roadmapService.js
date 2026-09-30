import api from './api';

// Roadmap Generation
export const generateRoadmap = (data) => api.post('/roadmaps/generate', data);
export const getRoadmapGenerationStatus = (jobId) => api.get(`/roadmaps/generate/status/${jobId}`);

// Roadmap Management
export const getRoadmaps = () => api.get('/roadmaps');
export const getRoadmap = (id) => api.get(`/roadmaps/${id}`);
export const updateRoadmap = (id, data) => api.put(`/roadmaps/${id}`, data);
export const deleteRoadmap = (id) => api.delete(`/roadmaps/${id}`);
export const completeTask = (taskId, data) => api.post(`/roadmaps/tasks/${taskId}/complete`, data);
