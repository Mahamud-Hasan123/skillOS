import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor: attach JWT token from localStorage
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('skillos_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor: on 401, clear token and redirect to /auth
// If backend is offline (network error), serve high-fidelity mock data to allow local preview of all pages.
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('skillos_token');
      localStorage.removeItem('skillos_user');
      if (window.location.pathname !== '/auth') {
        window.location.href = '/auth';
      }
      return Promise.reject(error);
    }

    // Network error / Backend offline handler
    if (!error.response || error.code === 'ERR_NETWORK') {
      console.warn('Backend is offline. SkillOS Frontend is running in Demo Mock Mode.');
      const url = error.config.url || '';
      const method = error.config.method?.toLowerCase() || 'get';
      const body = error.config.data ? JSON.parse(error.config.data) : {};

      let mockData = null;

      if (url.includes('/auth/login') || url.includes('/auth/register')) {
        mockData = {
          accessToken: 'mock_jwt_token_12345',
          tokenType: 'Bearer',
          expiresIn: null,
          user: {
            id: 99,
            fullName: body.fullName || 'Demo Learner',
            email: body.email || 'demo@skillos.com',
            role: 'user',
            avatar: 'preset_01',
            currentLevel: 7,
            totalXp: 2345
          }
        };
      } else if (url.includes('/users/me/preferences')) {
        if (method === 'get') {
          mockData = {
            theme: 'dark',
            globalRankingOptIn: true,
            notificationEmail: true,
            notificationPush: true,
            notificationPeerActivity: true,
            notificationDailyReminder: true,
            notificationAchievement: true,
            language: 'en',
            timezone: 'UTC'
          };
        } else {
          mockData = { message: 'Preferences updated (Mock Mode).' };
        }
      } else if (url.includes('/users/me/password')) {
        mockData = { message: 'Password changed successfully (Mock Mode).' };
      } else if (url.includes('/users/me')) {
        if (method === 'get') {
          mockData = {
            id: 99,
            fullName: 'Demo Learner',
            email: 'demo@skillos.com',
            role: 'user',
            avatar: 'preset_01',
            bio: 'Learning to code on SkillOS!',
            profession: 'student',
            timezone: 'UTC',
            currentLevel: 7,
            totalXp: 2345,
            createdAt: '2026-06-11T10:00:00'
          };
        } else if (method === 'put') {
          mockData = {
            id: 99,
            fullName: body.fullName || 'Demo Learner',
            email: 'demo@skillos.com',
            role: 'user',
            avatar: body.avatar || 'preset_01',
            bio: body.bio || 'Learning to code on SkillOS!',
            profession: body.profession || 'student',
            timezone: body.timezone || 'UTC',
            currentLevel: 7,
            totalXp: 2345,
            createdAt: '2026-06-11T10:00:00'
          };
        } else if (method === 'delete') {
          return Promise.resolve({ status: 240, data: {} });
        }
      } else if (url.includes('/onboarding/status')) {
        mockData = {
          currentStep: 1,
          isCompleted: false,
          steps: {}
        };
      } else if (url.includes('/onboarding/step/')) {
        const stepNum = parseInt(url.split('/onboarding/step/')[1]) || 1;
        mockData = {
          message: `Step ${stepNum} saved (Mock Mode).`,
          current_step: stepNum < 5 ? stepNum + 1 : 5
        };
      } else if (url.includes('/onboarding/complete')) {
        mockData = {
          message: 'Onboarding complete (Mock Mode). Welcome to SkillOS!',
          onboarding_completed: true
        };
      } else if (url.includes('/roadmaps/generate/status/')) {
        mockData = {
          job_id: 'mock_job_123',
          status: 'complete',
          progress_percent: 100,
          result_id: 101
        };
      } else if (url.includes('/roadmaps/generate')) {
        mockData = {
          job_id: 'mock_job_123',
          status: 'queued'
        };
      } else if (url.includes('/roadmaps/')) {
        const id = url.split('/roadmaps/')[1];
        mockData = {
          id: parseInt(id) || 101,
          title: 'Fullstack React Developer (Mock)',
          skillGoal: 'React, Node, SQL',
          level: 'beginner',
          progressPercent: 0,
          totalDays: 21,
          durationMonths: 1,
          dailyTimeMinutes: 45,
          startDate: '2026-06-11',
          endDate: '2026-07-02',
          tasks: [
            { id: 101, dayNumber: 1, title: 'HTML5 Semantic Tags & Structure', question: 'What HTML tag is used for the main navigation block?', answer: 'nav', xpReward: 10 },
            { id: 102, dayNumber: 2, title: 'CSS Flexbox Alignments', question: 'Which flexbox property aligns items along the cross axis?', answer: 'align-items', xpReward: 10 },
            { id: 103, dayNumber: 3, title: 'CSS Grid Layouts', question: 'What property defines the columns of a grid?', answer: 'grid-template-columns', xpReward: 10 },
            { id: 104, dayNumber: 4, title: 'JavaScript Variables & Data Types', question: 'Which keyword defines a block-scoped reassignable variable?', answer: 'let', xpReward: 10 },
            { id: 105, dayNumber: 5, title: 'JavaScript Functions & Scope', question: 'What arrow function syntax has implicit returns? (short/long)', answer: 'short', xpReward: 10 },
            { id: 106, dayNumber: 6, title: 'DOM Selectors & Event Listeners', question: 'What method returns the first element matching a CSS selector?', answer: 'querySelector', xpReward: 10 },
            { id: 107, dayNumber: 7, title: 'Asynchronous JavaScript & Promises', question: 'What keyword waits for a promise to resolve inside an async function?', answer: 'await', xpReward: 10 },
            { id: 108, dayNumber: 8, title: 'React Functional Components', question: 'What React Hook handles component local state?', answer: 'useState', xpReward: 15 },
            { id: 109, dayNumber: 9, title: 'React Hooks: useEffect', question: 'What dependency array array value triggers useEffect only on mount?', answer: 'empty', xpReward: 15 },
            { id: 110, dayNumber: 10, title: 'React Props and Components', question: 'Can components modify their own props? (yes/no)', answer: 'no', xpReward: 15 }
          ]
        };
      } else if (url.includes('/users/')) {
        const userId = url.split('/users/')[1];
        const mockPeers = {
          '1': { id: 1, fullName: 'Alex Mercer', profession: 'Professional', bio: 'Senior engineer learning Rust & advanced systems design on SkillOS.', timezone: 'EST', currentLevel: 12, totalXp: 12450, avatar: 'preset_01' },
          '2': { id: 2, fullName: 'Jessica Chen', profession: 'Student', bio: 'Computer science major. Focusing on GraphQL, React, and data visualizations.', timezone: 'PST', currentLevel: 8, totalXp: 8120, avatar: 'preset_02' },
          '3': { id: 3, fullName: 'Aaron Brooks', profession: 'Self Learner', bio: 'Bootcamp graduate seeking front-end role. Leveling up CSS layout details.', timezone: 'GMT+6', currentLevel: 5, totalXp: 5400, avatar: 'preset_03' },
          '4': { id: 4, fullName: 'Sarah Jenkins', profession: 'Student', bio: 'UI enthusiast working through the standard Web Dev curriculum.', timezone: 'UTC', currentLevel: 15, totalXp: 15300, avatar: 'preset_04' }
        };
        mockData = mockPeers[userId] || {
          id: parseInt(userId) || 99,
          fullName: 'Demo Peer',
          profession: 'Self Learner',
          bio: 'Enthusiastic developer learning new skills day-by-day on SkillOS.',
          timezone: 'UTC',
          currentLevel: 6,
          totalXp: 6350,
          avatar: 'preset_01'
        };
      } else if (url.includes('/daily-tasks/summary')) {
        mockData = {
          completionRate: 67,
          timeSpentMinutes: 35,
          totalDaysCount: 5
        };
      } else if (url.includes('/daily-tasks')) {
        mockData = [
          { id: 201, title: 'Read 2 articles on MDN Web Docs', completed: false, xpReward: 10, estimatedTimeMinutes: 20, dayNumber: 1 },
          { id: 202, title: 'Write 10 CSS Flexbox exercises', completed: true, xpReward: 15, estimatedTimeMinutes: 15, dayNumber: 1 },
          { id: 203, title: 'Solve 1 Leetcode Javascript problem', completed: false, xpReward: 20, estimatedTimeMinutes: 30, dayNumber: 1 }
        ];
      } else if (url.includes('/timer/status')) {
        mockData = {
          id: 1,
          loggedMinutes: 25,
          running: false,
          currentSessionMinutes: 0
        };
      } else if (url.includes('/timer/action')) {
        const action = body.action || 'START';
        mockData = {
          id: 1,
          loggedMinutes: action === 'STOP' ? 35 : 25,
          running: action === 'START',
          currentSessionMinutes: action === 'START' ? 10 : 0
        };
      } else if (url.includes('/streaks/me')) {
        mockData = {
          current_streak: 12,
          longest_streak: 21,
          total_active_days: 45,
          freeze_tokens_owned: 2
        };
      } else if (url.includes('/streaks/heatmap')) {
        // Generate last 30 days heatmap counts
        const list = [];
        for (let i = 30; i >= 0; i--) {
          const date = new Date();
          date.setDate(date.getDate() - i);
          const dateString = date.toISOString().split('T')[0];
          list.push({
            date: dateString,
            count: i % 7 === 0 ? 0 : (i % 3 === 0 ? 3 : 1)
          });
        }
        mockData = list;
      } else if (url.includes('/streaks/freeze')) {
        mockData = {
          success: true,
          message: 'Streak freeze token used (Mock Mode).'
        };
      } else if (url.includes('/xp/me')) {
        mockData = {
          total_xp: 2345,
          current_level: 7,
          xp_to_next_level: 155
        };
      } else if (url.includes('/xp/log')) {
        mockData = {
          content: [
            { id: 301, xpAmount: 15, source: 'Completed Task: HTML5 Semantic Tags', createdAt: '2026-06-12T14:30:00Z' },
            { id: 302, xpAmount: 100, source: 'Unlocked Achievement: JavaScript Ninja', createdAt: '2026-06-10T12:00:00Z' },
            { id: 303, xpAmount: 10, source: 'Completed Task: CSS Flexbox Alignments', createdAt: '2026-06-08T11:15:00Z' }
          ],
          totalElements: 3,
          totalPages: 1
        };
      } else if (url.includes('/levels')) {
        mockData = [
          { levelNumber: 1, xpRequired: 0, title: 'Novice' },
          { levelNumber: 2, xpRequired: 1000, title: 'Code Apprentice' },
          { levelNumber: 3, xpRequired: 2000, title: 'JS Squire' }
        ];
      } else if (url.includes('/dashboard/xp-chart')) {
        mockData = [
          { date: 'Mon', xp: 50 },
          { date: 'Tue', xp: 80 },
          { date: 'Wed', xp: 120 },
          { date: 'Thu', xp: 10 },
          { date: 'Fri', xp: 90 },
          { date: 'Sat', xp: 210 },
          { date: 'Sun', xp: 140 }
        ];
      } else if (url.includes('/flashcards/study')) {
        mockData = {
          data: [
            { id: 401, question: 'What is a Closure in JavaScript?', answer: 'A closure is the combination of a function bundled together with references to its surrounding state.', skillName: 'JavaScript' },
            { id: 402, question: 'What is the purpose of useEffect Hook?', answer: 'To perform side effects in functional React components.', skillName: 'React' },
            { id: 403, question: 'Explain CSS Box Model.', answer: 'It represents the design and layout of elements, consisting of Margins, Borders, Padding, and Content.', skillName: 'CSS' }
          ]
        };
      } else if (url.includes('/flashcards/') && url.includes('/review')) {
        mockData = {
          success: true,
          message: 'Review recorded (Mock Mode).'
        };
      } else if (url.includes('/flashcards/generate')) {
        mockData = {
          job_id: 'gen_fc_mock123',
          status: 'queued'
        };
      } else if (url.includes('/flashcards')) {
        // manual post
        mockData = {
          id: 404,
          question: body.question || 'Question?',
          answer: body.answer || 'Answer',
          skillName: body.skillName || 'Skill'
        };
      } else if (url.includes('/notes')) {
        if (method === 'get') {
          mockData = {
            data: [
              { id: 501, title: 'React Performance Tips', content: 'Use useMemo and useCallback to avoid unnecessary re-renders. Use React.memo for component optimization.', skillTags: 'react,web', createdAt: '2026-06-12T10:00:00Z' },
              { id: 502, title: 'Flexbox vs Grid', content: 'Flexbox is one-dimensional (row OR column), while Grid is two-dimensional (rows AND columns).', skillTags: 'css,web', createdAt: '2026-06-11T09:30:00Z' }
            ]
          };
        } else if (method === 'post') {
          mockData = {
            id: 503,
            title: body.title || 'Untitled Note',
            content: body.content || '',
            skillTags: body.skillTags || '',
            createdAt: new Date().toISOString()
          };
        } else {
          mockData = {
            id: parseInt(url.split('/notes/')[1]) || 501,
            title: body.title || 'Updated Note',
            content: body.content || '',
            skillTags: body.skillTags || '',
            createdAt: new Date().toISOString()
          };
        }
      } else if (url.includes('/achievements')) {
        mockData = {
          available_achievements: [
            { id: 601, title: 'First Steps', description: 'Complete your first task', xpReward: 50, badgeIcon: '⭐️' },
            { id: 602, title: 'Daily Grind', description: 'Maintain a 5-day streak', xpReward: 150, badgeIcon: '🔥' },
            { id: 603, title: 'Project Builder', description: 'Create an AI structured project', xpReward: 200, badgeIcon: '🛠️' },
            { id: 604, title: 'Flash Master', description: 'Review 50 flashcards', xpReward: 300, badgeIcon: '🧠' }
          ],
          unlocked_achievements: [
            { id: 601, title: 'First Steps', unlockedAt: '2026-06-11T12:00:00Z' }
          ]
        };
      } else if (url.includes('/rewards') && url.includes('/purchase')) {
        mockData = {
          id: 701,
          itemId: parseInt(url.split('/rewards/')[1]),
          purchasedAt: new Date().toISOString()
        };
      } else if (url.includes('/rewards')) {
        mockData = [
          { id: 801, title: 'Streak Freeze', description: 'Saves your daily streak even if you forget to study today.', costPoints: 500, emoji: '❄️' },
          { id: 802, title: 'Custom Avatar Pack', description: 'Unlock a pack of premium geeky avatars.', costPoints: 1200, emoji: '🎭' },
          { id: 803, title: 'VIP Profile Border', description: 'Show off your dedication with a glowing gold border.', costPoints: 2000, emoji: '✨' }
        ];
      } else if (url.includes('/ranks')) {
        mockData = [
          { id: 901, user: { id: 4, fullName: 'Sarah Jenkins', avatar: 'preset_04' }, rankPosition: 1, totalXp: 15300, level: 15 },
          { id: 902, user: { id: 1, fullName: 'Alex Mercer', avatar: 'preset_01' }, rankPosition: 2, totalXp: 12450, level: 12 },
          { id: 903, user: { id: 2, fullName: 'Jessica Chen', avatar: 'preset_02' }, rankPosition: 3, totalXp: 8120, level: 8 },
          { id: 99, user: { id: 99, fullName: 'You', avatar: 'preset_01' }, rankPosition: 4, totalXp: 2345, level: 7 }
        ];
      } else if (url.includes('/peers/search')) {
        mockData = [
          { id: 3, fullName: 'Aaron Brooks', avatar: 'preset_03', profession: 'Self Learner', bio: 'Bootcamp graduate seeking front-end role. Leveling up CSS layout details.' },
          { id: 4, fullName: 'Sarah Jenkins', avatar: 'preset_04', profession: 'Student', bio: 'UI enthusiast working through the standard Web Dev curriculum.' }
        ];
      } else if (url.includes('/peers/requests') && url.includes('/accept')) {
        mockData = {
          id: 15,
          peerInfo: { id: 3, fullName: 'Aaron Brooks', avatar: 'preset_03', profession: 'Self Learner' },
          pairedAt: new Date().toISOString()
        };
      } else if (url.includes('/peers/requests')) {
        if (method === 'get') {
          mockData = [
            { id: 10, sender: { id: 3, fullName: 'Aaron Brooks', avatar: 'preset_03', profession: 'Self Learner' }, status: 'PENDING' }
          ];
        } else {
          mockData = { id: 10, status: 'SENT' };
        }
      } else if (url.includes('/peers')) {
        mockData = [
          { id: 1, peerInfo: { id: 1, fullName: 'Alex Mercer', avatar: 'preset_01', profession: 'Professional', bio: 'Senior engineer learning Rust & advanced systems design on SkillOS.' }, pairedAt: '2026-06-10T09:00:00Z' },
          { id: 2, peerInfo: { id: 2, fullName: 'Jessica Chen', avatar: 'preset_02', profession: 'Student', bio: 'Computer science major. Focusing on GraphQL, React, and data visualizations.' }, pairedAt: '2026-06-09T14:30:00Z' }
        ];
      } else if (url.includes('/chat/')) {
        const peerId = parseInt(url.split('/chat/')[1]);
        mockData = {
          content: [
            { id: 1001, senderId: peerId, receiverId: 99, body: 'Hey, did you complete today\'s Flexbox challenge?', isRead: true, createdAt: '2026-06-12T12:00:00Z' },
            { id: 1002, senderId: 99, receiverId: peerId, body: 'Yes, align-items is indeed the key property.', isRead: true, createdAt: '2026-06-12T12:05:00Z' }
          ],
          totalElements: 2,
          totalPages: 1
        };
      } else if (url.includes('/projects/') && url.includes('/active')) {
        mockData = {
          id: parseInt(url.split('/projects/')[1]),
          name: 'Active Project',
          skillName: 'Skill',
          active: true
        };
      } else if (url.includes('/projects/') && url.includes('/kanban')) {
        mockData = {
          board: { id: 110, name: 'Project Board' },
          columns: [
            { column: { id: 11, name: 'To Do', orderIndex: 0 }, cards: [{ id: 111, title: 'Setup Repository', description: 'Initialize project, git repository and branch structures', orderIndex: 0 }] },
            { column: { id: 12, name: 'In Progress', orderIndex: 1 }, cards: [{ id: 112, title: 'Build UI Layouts', description: 'Translate wireframes into responsive React components', orderIndex: 0 }] },
            { column: { id: 13, name: 'Review', orderIndex: 2 }, cards: [] },
            { column: { id: 14, name: 'Done', orderIndex: 3 }, cards: [{ id: 113, title: 'Project Scope Definition', description: 'Outline target specifications and milestones', orderIndex: 0 }] }
          ]
        };
      } else if (url.includes('/projects/') && url.includes('/gantt')) {
        mockData = {
          data: [
            { id: 121, title: 'Scope & Wireframes', startDate: '2026-06-11', endDate: '2026-06-13', progressPercent: 100 },
            { id: 122, title: 'Base Infrastructure', startDate: '2026-06-14', endDate: '2026-06-18', progressPercent: 40 },
            { id: 123, title: 'UI Design Polish', startDate: '2026-06-19', endDate: '2026-06-25', progressPercent: 0 }
          ]
        };
      } else if (url.includes('/kanban/cards/')) {
        mockData = {
          id: parseInt(url.split('/cards/')[1]),
          title: 'Moved Card',
          description: 'Successfully moved (Mock Mode)'
        };
      } else if (url.includes('/gantt/entries/')) {
        mockData = {
          id: parseInt(url.split('/entries/')[1]),
          title: 'Updated Gantt Entry',
          startDate: body.startDate || '2026-06-14',
          endDate: body.endDate || '2026-06-18',
          progressPercent: body.progressPercent || 0
        };
      } else if (url.includes('/projects')) {
        if (method === 'get') {
          mockData = {
            data: [
              { id: 1, name: 'Portfolio Website', skillName: 'React, CSS', description: 'Create a personal developer portfolio', active: true, createdAt: '2026-06-11T12:00:00Z' }
            ]
          };
        } else {
          mockData = {
            job_id: 'gen_proj_mock123',
            project: { id: 2, name: body.name || 'New Project', skillName: body.skillName || 'Skill', description: body.description || '' },
            status: 'queued'
          };
        }
      } else if (url.includes('/dashboard')) {
        mockData = {
          greeting: 'Good morning, Demo!',
          streakCount: 12,
          todayFocus: {
            badge: 'Focus Session',
            title: 'Learn React Fundamentals',
            subtitle: 'Part of Frontend Roadmap',
            btnText: 'Start Session'
          },
          activeRoadmap: {
            badge: 'Active',
            title: 'Frontend Web Developer',
            subtitle: '78% Complete',
            percent: 78
          },
          levelInfo: {
            level: 7,
            title: '2345 XP Earned',
            subtitle: '155 XP to Lv. 8',
            percent: 84
          },
          upcomingTasks: [
            { id: 1, title: 'Learn React Fundamentals', meta: 'Frontend · 45m', completed: true },
            { id: 2, title: 'CSS Grid & Flexbox', meta: 'CSS · 30m', completed: false },
            { id: 3, title: 'JS Data Structures', meta: 'Backend · 60m', completed: false },
            { id: 4, title: 'API Integration', meta: 'API · 45m', completed: false }
          ],
          peers: [
            { id: 1, name: 'Alex', level: 12, status: 'Completed "React Router" 5m ago', active: false, initial: 'A' },
            { id: 2, name: 'Jessica', level: 8, status: 'Focusing on "GraphQL Basics"', active: true, initial: 'J' },
            { id: 3, name: 'Aaron', level: 5, status: 'Earned +50 XP today', active: false, initial: 'R' },
            { id: 4, name: 'Sarah', level: 15, status: 'Active Now', active: true, initial: 'S' }
          ]
        };

      }

      if (mockData) {
        return Promise.resolve({
          status: 200,
          statusText: 'OK',
          headers: {},
          config: error.config,
          data: mockData
        });
      }
    }

    return Promise.reject(error);
  }
);

export default api;
