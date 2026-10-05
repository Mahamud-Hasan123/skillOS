import api from './api';

export const getProjectKanban = (projectId) => api.get(`/projects/${projectId}/kanban`);
export const moveKanbanCard = (cardId, targetColumnId, targetOrderIndex) => 
  api.put(`/kanban/cards/${cardId}/move`, { targetColumnId, targetOrderIndex });
