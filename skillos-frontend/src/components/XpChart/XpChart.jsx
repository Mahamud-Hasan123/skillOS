import React, { useState, useRef, useEffect } from 'react';
import { Line } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend,
} from 'chart.js';
import { getXpChartData } from '../../services/dashboardService';
import styles from './XpChart.module.css';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend
);

// Fallback mock data in case API fails
const FALLBACK_DATA = {
  week: {
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    data: [0, 0, 0, 0, 0, 0, 0],
  },
  month: {
    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
    data: [0, 0, 0, 0],
  },
  year: {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  },
};

export default function XpChart() {
  const [activeTab, setActiveTab] = useState('week');
  const [chartData, setChartData] = useState({ datasets: [] });
  const [xpDataCache, setXpDataCache] = useState({});

  // Fetch XP chart data from the backend when tab changes
  useEffect(() => {
    const fetchAndRender = async () => {
      let labels;
      let dataPoints;

      // Check cache first
      if (xpDataCache[activeTab]) {
        labels = xpDataCache[activeTab].labels;
        dataPoints = xpDataCache[activeTab].data;
      } else {
        // Fetch from backend
        const apiData = await getXpChartData(activeTab);

        if (apiData && Array.isArray(apiData) && apiData.length > 0) {
          // API returns [{date: "2026-06-10", xp: 40}, ...] or [{label: "...", xp: ...}]
          labels = apiData.map((d) => {
            if (d.date) {
              const dt = new Date(d.date);
              if (activeTab === 'week') return dt.toLocaleDateString('en', { weekday: 'short' });
              if (activeTab === 'month') return dt.toLocaleDateString('en', { month: 'short', day: 'numeric' });
              return dt.toLocaleDateString('en', { month: 'short' });
            }
            return d.label || d.week || d.month || '';
          });
          dataPoints = apiData.map((d) => d.xp || d.totalXp || d.total_xp || 0);

          // Cache it
          setXpDataCache((prev) => ({
            ...prev,
            [activeTab]: { labels, data: dataPoints },
          }));
        } else {
          // Use fallback
          const fb = FALLBACK_DATA[activeTab];
          labels = fb.labels;
          dataPoints = fb.data;
        }
      }

      setChartData({
        labels,
        datasets: [
          {
            label: 'XP Earned',
            data: dataPoints,
            borderColor: '#4f46e5',
            borderWidth: 3.5,
            tension: 0.45,
            fill: true,
            backgroundColor: (context) => {
              const chart = context.chart;
              const { ctx, chartArea } = chart;
              if (!chartArea) {
                return null;
              }
              const gradient = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
              gradient.addColorStop(0, 'rgba(79, 70, 229, 0.22)');
              gradient.addColorStop(1, 'rgba(79, 70, 229, 0.01)');
              return gradient;
            },
            pointBackgroundColor: '#4f46e5',
            pointBorderColor: '#fff',
            pointBorderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 6,
          },
        ],
      });
    };

    fetchAndRender();
  }, [activeTab, xpDataCache]);

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        backgroundColor: '#0f0f1a',
        titleFont: { family: 'Plus Jakarta Sans', size: 12, weight: 'bold' },
        bodyFont: { family: 'Plus Jakarta Sans', size: 13 },
        padding: 10,
        cornerRadius: 8,
        displayColors: false,
      },
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { color: '#9ea3bc', font: { family: 'Plus Jakarta Sans', size: 11, weight: '500' } },
      },
      y: {
        grid: { color: '#f0f1f6', borderDash: [5, 5], drawBorder: false },
        ticks: {
          color: '#9ea3bc',
          font: { family: 'Plus Jakarta Sans', size: 11, weight: '500' },
          callback: (value) => value + ' XP',
        },
      },
    },
  };

  return (
    <div className={styles.chartCard}>
      <div className={styles.chartHeader}>
        <div>
          <h3 className={styles.chartTitle}>XP Progression</h3>
          <p className={styles.chartSub}>Your learning consistency over time</p>
        </div>
        <div className={styles.tabGroup}>
          <button
            className={`${styles.tabBtn} ${activeTab === 'week' ? styles.activeTab : ''}`}
            onClick={() => setActiveTab('week')}
          >
            Week
          </button>
          <button
            className={`${styles.tabBtn} ${activeTab === 'month' ? styles.activeTab : ''}`}
            onClick={() => setActiveTab('month')}
          >
            Month
          </button>
          <button
            className={`${styles.tabBtn} ${activeTab === 'year' ? styles.activeTab : ''}`}
            onClick={() => setActiveTab('year')}
          >
            Year
          </button>
        </div>
      </div>
      <div className={styles.chartContainer}>
        {chartData.datasets.length > 0 ? (
          <Line data={chartData} options={options} />
        ) : (
          <div style={{color: '#9ea3bc', textAlign: 'center', marginTop: '40px'}}>Loading chart...</div>
        )}
      </div>
    </div>
  );
}
