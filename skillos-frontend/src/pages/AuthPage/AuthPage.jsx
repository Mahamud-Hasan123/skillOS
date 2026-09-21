import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { loginUser, registerUser } from '../../services/authService';
import styles from './AuthPage.module.css';

export default function AuthPage() {
  const [isLogin, setIsLogin] = useState(true);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const { login } = useAuth();
  const navigate = useNavigate();

  const handleToggleMode = () => {
    setIsLogin(!isLogin);
    setError('');
    setFullName('');
    setEmail('');
    setPassword('');
    setConfirmPassword('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    if (!email || !password) {
      setError('Please fill in all required fields.');
      setLoading(false);
      return;
    }

    if (!isLogin) {
      if (!fullName) {
        setError('Please enter your full name.');
        setLoading(false);
        return;
      }
      if (password !== confirmPassword) {
        setError('Passwords do not match.');
        setLoading(false);
        return;
      }
    }

    try {
      if (isLogin) {
        const response = await loginUser({ email, password });
        const { accessToken, user } = response.data;
        login(accessToken, user);
        navigate('/dashboard');
      } else {
        const response = await registerUser({ fullName, email, password });
        const { accessToken, user } = response.data;
        login(accessToken, user);
        navigate('/dashboard');
      }
    } catch (err) {
      console.error(err);
      setError(err.response?.data?.message || err.response?.data?.error || 'Authentication failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      {/* Left Branding Section */}
      <div className={styles.leftSide}>
        <div className={styles.brand}>
          <div className={styles.logoMark}>S</div>
          <span className={styles.logoText}>SkillOS</span>
        </div>
        
        <div className={styles.heroText}>
          <h1 className={styles.heroTitle}>
            {isLogin ? (
              <>Welcome back,<br />learner.</>
            ) : (
              <>Join 12,000+<br />learners today.</>
            )}
          </h1>
          <p className={styles.heroDesc}>
            {isLogin 
              ? "Pick up where you left off and keep your streak alive."
              : "Build skills, track progress, and stay accountable — every day."
            }
          </p>
        </div>

        {isLogin ? (
          <div className={styles.heroStats}>
            <div className={styles.statItem}>
              <h3>12k+</h3>
              <p>Active Learners</p>
            </div>
            <div className={styles.statItem}>
              <h3>94%</h3>
              <p>Completion Rate</p>
            </div>
            <div className={styles.statItem}>
              <h3>4.9</h3>
              <p>Store Rating</p>
            </div>
          </div>
        ) : (
          <div className={styles.heroSpacer}></div>
        )}
      </div>

      {/* Right Form Section */}
      <div className={styles.rightSide}>
        <div className={styles.authCard}>
          {error && <div className={styles.errorAlert}>{error}</div>}
          
          {isLogin ? (
            /* Login Form */
            <div className={styles.loginFormBlock}>
              <h2>Welcome Back</h2>
              <p className={styles.cardSubtitle}>Enter your details to access your dashboard</p>
              
              <form onSubmit={handleSubmit}>
                <div className={styles.formGroup}>
                  <label htmlFor="login-email">Email Address</label>
                  <input 
                    id="login-email"
                    type="email" 
                    placeholder="you@example.com" 
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
                
                <div className={styles.formGroup}>
                  <div className={styles.labelRow}>
                    <label htmlFor="login-password">Password</label>
                    <a href="#forgot" className={styles.forgotLink}>Forgot?</a>
                  </div>
                  <div className={styles.passwordInputWrap}>
                    <input 
                      id="login-password"
                      type={showPassword ? "text" : "password"} 
                      placeholder="••••••••" 
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                    />
                    <span 
                      className={styles.eyeToggle} 
                      onClick={() => setShowPassword(!showPassword)}
                      style={{ color: showPassword ? '#4338CA' : '#6B7280' }}
                    >
                      👁
                    </span>
                  </div>
                </div>

                <button type="submit" className={styles.submitBtn} disabled={loading}>
                  {loading ? 'Logging in...' : 'Log In'}
                </button>
              </form>
              
              <div className={styles.divider}>
                <span>or continue with</span>
              </div>
              
              <div className={styles.socialBtns}>
                <button className={styles.socialBtn}>
                  <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" />
                  Google
                </button>
                <button className={styles.socialBtn}>
                  <img src="https://www.svgrepo.com/show/512317/github-142.svg" alt="GitHub" />
                  GitHub
                </button>
              </div>
              
              <p className={styles.switchText}>
                Don't have an account? <span onClick={handleToggleMode} className={styles.switchLink}>Sign up</span>
              </p>
            </div>
          ) : (
            /* Signup Form */
            <div className={styles.signupFormBlock}>
              <h2>Create Account</h2>
              <p className={styles.cardSubtitle}>Join the community and start leveling up today</p>
              
              <form onSubmit={handleSubmit}>
                <div className={styles.formGroup}>
                  <label htmlFor="signup-name">Full Name</label>
                  <input 
                    id="signup-name"
                    type="text" 
                    placeholder="John Doe" 
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    required
                  />
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="signup-email">Email Address</label>
                  <input 
                    id="signup-email"
                    type="email" 
                    placeholder="you@example.com" 
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
                
                <div className={styles.formGroup}>
                  <label htmlFor="signup-password">Password</label>
                  <div className={styles.passwordInputWrap}>
                    <input 
                      id="signup-password"
                      type={showPassword ? "text" : "password"} 
                      placeholder="At least 8 characters" 
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                    />
                    <span 
                      className={styles.eyeToggle} 
                      onClick={() => setShowPassword(!showPassword)}
                      style={{ color: showPassword ? '#4338CA' : '#6B7280' }}
                    >
                      👁
                    </span>
                  </div>
                </div>

                <div className={styles.formGroup}>
                  <label htmlFor="signup-confirm">Confirm Password</label>
                  <input 
                    id="signup-confirm"
                    type="password" 
                    placeholder="••••••••" 
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                </div>

                <button type="submit" className={styles.submitBtn} disabled={loading}>
                  {loading ? 'Creating Account...' : 'Sign Up'}
                </button>
              </form>
              
              <div className={styles.divider}>
                <span>or signup with</span>
              </div>
              
              <div className={styles.socialBtns}>
                <button className={styles.socialBtn}>
                  <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="Google" />
                  Google
                </button>
                <button className={styles.socialBtn}>
                  <img src="https://www.svgrepo.com/show/512317/github-142.svg" alt="GitHub" />
                  GitHub
                </button>
              </div>
              
              <p className={styles.switchText}>
                Already have an account? <span onClick={handleToggleMode} className={styles.switchLink}>Log in</span>
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
