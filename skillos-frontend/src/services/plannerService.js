import api from './api';

/**
 * Fetch the planner dashboard for a specific date (defaults to today)
 */
export const getPlannerDashboard = async (date) => {
  const dateStr = date || new Date().toISOString().split('T')[0];
  const [dashboardRes, tasksRes] = await Promise.all([
    api.get(`/planner/dashboard?date=${dateStr}`),
    api.get('/planner/tasks?status=pending,scheduled')
  ]);
  
  return {
    ...dashboardRes.data,
    pendingTasks: tasksRes.data.data
  };
};

/**
 * Generate a new schedule for a specific date
 */
export const generateSchedule = async (date) => {
  const dateStr = date || new Date().toISOString().split('T')[0];
  const response = await api.post('/planner/schedule/generate', { date: dateStr });
  return response.data;
};

/**
 * Reset schedule for a specific date
 */
export const resetSchedule = async (date) => {
  const dateStr = date || new Date().toISOString().split('T')[0];
  await api.delete(`/planner/schedule/${dateStr}/reset`);
};

/**
 * Unschedule a specific task
 */
export const unscheduleTask = async (taskId, date) => {
  const dateStr = date || new Date().toISOString().split('T')[0];
  await api.delete(`/planner/schedule/${dateStr}/tasks/${taskId}/unschedule`);
};

/**
 * Update the user profile (used to silently send the timezone)
 */
export const updateProfile = async (profileData) => {
  const response = await api.put('/users/me', profileData);
  return response.data;
};

/**
 * Create a new pending task
 */
export const createTask = async (taskData) => {
  const response = await api.post('/planner/tasks', taskData);
  return response.data;
};

/**
 * Fetch all routines
 */
export const getRoutines = async () => {
  const response = await api.get('/routines');
  return response.data;
};

/**
 * Create a new routine
 */
export const createRoutine = async (routineData) => {
  const response = await api.post('/routines', routineData);
  return response.data;
};

/**
 * Delete a routine
 */
export const deleteRoutine = async (id) => {
  await api.delete(`/routines/${id}`);
};

/**
 * Update an existing task
 */
export const updateTask = async (id, taskData) => {
  const response = await api.put(`/planner/tasks/${id}`, taskData);
  return response.data;
};

/**
 * Delete a task
 */
export const deleteTask = async (id) => {
  await api.delete(`/planner/tasks/${id}`);
};

/**
 * Mark a schedule entry as started
 */
export const startEntry = async (entryId) => {
  const response = await api.post(`/planner/schedule/entries/${entryId}/start`);
  return response.data;
};

/**
 * Mark a schedule entry as completed
 */
export const completeEntry = async (entryId, actualMinutes) => {
  const response = await api.post(`/planner/schedule/entries/${entryId}/complete`, { actualMinutes });
  return response.data;
};
