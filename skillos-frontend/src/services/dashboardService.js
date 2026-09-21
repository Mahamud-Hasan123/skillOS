import api from './api';

// ─── Mock Fallback Data ──────────────────────────────────────
const MOCK_DASHBOARD = {
  greeting: 'Good morning, Learner!',
  streakCount: 0,
  todayFocus: {
    badge: 'Focus Session',
    title: 'No tasks yet',
    subtitle: 'Generate a roadmap to get started',
    btnText: 'Get Started',
  },
  activeRoadmap: {
    badge: 'No Roadmap',
    title: 'No active roadmap',
    subtitle: 'Generate one to begin',
    percent: 0,
  },
  levelInfo: {
    level: 1,
    title: '0 XP Earned',
    subtitle: 'Complete tasks to earn XP',
    percent: 0,
  },
  upcomingTasks: [],
  peers: [],
};

// ─── Helpers ─────────────────────────────────────────────────
function getGreeting(name) {
  const hour = new Date().getHours();
  let timeOfDay = 'Good morning';
  if (hour >= 12 && hour < 17) timeOfDay = 'Good afternoon';
  else if (hour >= 17) timeOfDay = 'Good evening';
  return `${timeOfDay}, ${name}!`;
}

// ─── Composite Dashboard Fetch ───────────────────────────────
export const getDashboard = async () => {
  try {
    // Fire all requests in parallel
    const [userRes, streakRes, xpRes, roadmapsRes, tasksRes, peersRes, achievementsRes, progressRes] = await Promise.allSettled([
      api.get('/users/me'),
      api.get('/streaks/me'),
      api.get('/xp/me'),
      api.get('/roadmaps'),
      api.get(`/daily-tasks?date=${new Date().toISOString().split('T')[0]}`),
      api.get('/peers'),
      api.get('/achievements'),
      api.get('/progress?period=all')
    ]);

    // Extract values safely
    const user = userRes.status === 'fulfilled' ? userRes.value.data : null;
    const streak = streakRes.status === 'fulfilled' ? streakRes.value.data : null;
    const xp = xpRes.status === 'fulfilled' ? xpRes.value.data : null;
    const roadmaps = roadmapsRes.status === 'fulfilled' ? roadmapsRes.value.data : [];
    const tasks = tasksRes.status === 'fulfilled' ? tasksRes.value.data : [];
    const peers = peersRes.status === 'fulfilled' ? peersRes.value.data : [];
    const achievementsData = achievementsRes.status === 'fulfilled' ? achievementsRes.value.data : { unlocked_achievements: [] };
    const progressData = progressRes.status === 'fulfilled' ? progressRes.value.data : null;

    // ── Greeting ──
    const fullName = user?.fullName || 'Learner';
    const greeting = getGreeting(fullName);
    const streakCount = streak?.current_streak ?? 0;
    const tasksDone = progressData?.user?.tasks_done ?? 0;

    // ── Active Roadmap ──
    const roadmapList = Array.isArray(roadmaps) ? roadmaps : (roadmaps?.data || []);
    const activeRoadmap = roadmapList.find((r) => r.status === 'active') || roadmapList[0] || null;

    let activeRoadmapCard;
    if (activeRoadmap) {
      activeRoadmapCard = {
        badge: 'ACTIVE ROADMAP',
        title: activeRoadmap.title || 'Roadmap',
        subtitle: `${Math.round(activeRoadmap.progressPercent || activeRoadmap.progress_percent || 0)}% complete`,
        percent: Math.round(activeRoadmap.progressPercent || activeRoadmap.progress_percent || 0),
        skillGoal: activeRoadmap.skillGoal || activeRoadmap.title || 'a new skill',
      };
    } else {
      activeRoadmapCard = { ...MOCK_DASHBOARD.activeRoadmap, skillGoal: 'a new skill' };
    }

    // ── XP & Level ──
    const totalXp = xp?.total_xp ?? user?.totalXp ?? 0;
    const currentLevel = xp?.current_level ?? user?.currentLevel ?? 1;
    const xpToNext = xp?.xp_to_next_level ?? 0;
    // Calculate percent to next level (rough estimate: each level ~500 XP)
    const xpPercent = xpToNext > 0 ? Math.min(100, Math.round(((500 - xpToNext) / 500) * 100)) : 0;

    const levelInfo = {
      level: currentLevel,
      title: `${totalXp.toLocaleString()} XP Earned`,
      subtitle: xpToNext > 0 ? `${xpToNext} XP to Lv. ${currentLevel + 1}` : 'Max level reached',
      percent: Math.max(0, xpPercent),
    };

    // ── Today's Focus ──
    const taskList = Array.isArray(tasks) ? tasks : (tasks?.data || []);
    const pendingTask = taskList.find((t) => t.status === 'pending' || t.status === 'not_started') || taskList[0] || null;

    let todayFocus;
    if (pendingTask) {
      todayFocus = {
        badge: 'TODAY\'S FOCUS',
        title: pendingTask.title || 'Today\'s Task',
        subtitle: `Frontend`, // Mocking tag as requested
        time: `${pendingTask.estimatedMinutes || 30}m + 50 XP`,
        btnText: 'Start Session',
      };
    } else {
      todayFocus = {
        badge: 'TODAY\'S FOCUS',
        title: taskList.length > 0 ? 'All tasks completed!' : 'No tasks for today',
        subtitle: 'Break Time',
        time: '0m',
        btnText: taskList.length > 0 ? 'Review' : 'Get Started',
      };
    }

    // ── Upcoming Tasks ──
    let upcomingTasks = taskList.slice(0, 5).map((t, i) => ({
      id: t.id || i + 1,
      title: t.title || `Task ${i + 1}`,
      duration: `${t.estimatedMinutes || 30}m`,
      completed: t.status === 'completed' || t.status === 'done',
    }));

    if (taskList.length === 0 && activeRoadmap) {
      try {
        const roadmapDetailsRes = await api.get(`/roadmaps/${activeRoadmap.id}`);
        const roadmapTasks = roadmapDetailsRes.data.tasks || [];
        roadmapTasks.sort((a, b) => (a.dayNumber || 0) - (b.dayNumber || 0));
        
        const firstUncompleted = roadmapTasks.find(t => t.status !== 'completed');
        if (firstUncompleted) {
          upcomingTasks = [{
            id: firstUncompleted.id,
            title: `Day ${firstUncompleted.dayNumber}`,
            duration: '',
            completed: false
          }];
        }
      } catch (err) {
        console.error('Failed to fetch active roadmap tasks for upcoming tasks fallback', err);
      }
    }

    // ── Peers ──
    const peerList = Array.isArray(peers) ? peers : (peers?.data || []);
    const peerItems = peerList.slice(0, 6).map((p) => {
      const info = p.peerInfo || p;
      const name = info.fullName || info.full_name || info.displayName || 'Peer';
      return {
        id: info.id || p.id,
        name: name, // Full name or split based on design
        level: info.currentLevel || info.current_level || 1,
        status: 'completed a milestone', // Mock text from Figma
        active: false,
        initial: name.substring(0, 2).toUpperCase(),
      };
    });

    // ── Achievements ──
    const unlockedAchievements = Array.isArray(achievementsData.unlocked_achievements) ? achievementsData.unlocked_achievements : [];
    const recentAchievements = unlockedAchievements.slice(0, 3).map((a) => {
      return {
        id: a.id || a.achievement_id,
        name: a.achievement?.name || 'Achievement',
        rarity: a.achievement?.rarity || 'common',
        icon: a.achievement?.icon || '🏆',
      };
    });

    return {
      data: {
        greeting,
        targetGoal: activeRoadmapCard.skillGoal,
        streakCount,
        tasksDone,
        todayFocus,
        activeRoadmap: activeRoadmapCard,
        levelInfo,
        upcomingTasks,
        peers: peerItems,
        achievements: recentAchievements,
      },
    };
  } catch (err) {
    console.warn('Dashboard composite fetch failed, using mock data', err);
    return { data: MOCK_DASHBOARD };
  }
};

// ─── XP Chart Data ───────────────────────────────────────────
export const getXpChartData = async (range = 'week') => {
  try {
    const res = await api.get(`/dashboard/xp-chart?range=${range}`);
    return res.data;
  } catch (err) {
    console.warn(`XP chart fetch failed for range=${range}, using mock`, err);
    return null; // caller will use fallback
  }
};
