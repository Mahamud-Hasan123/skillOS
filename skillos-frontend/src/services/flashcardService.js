import api from './api';

export const createManualFlashcard = (data) => api.post('/flashcards', data);
export const getStudyBatch = (skillName, limit = 10) => 
  api.get('/flashcards/study', { params: { skill_name: skillName, limit } });
export const submitReview = (id, difficulty) => api.post(`/flashcards/${id}/review`, { difficulty });
export const generateFlashcards = (skillName) => api.post('/flashcards/generate', { skillName });
export const getGenerationStatus = (jobId) => api.get(`/flashcards/generate/status/${jobId}`);
export const getAllFlashcards = () => api.get('/flashcards');
export const updateFlashcard = (id, data) => api.put(`/flashcards/${id}`, data);
export const deleteFlashcard = (id) => api.delete(`/flashcards/${id}`);
