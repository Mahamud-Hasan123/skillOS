import React, { useState, useEffect, useCallback } from 'react';
import { getUserNotes, deleteNote } from '../../services/noteService';
import CreateNoteModal from '../../components/CreateNoteModal/CreateNoteModal';
import styles from './NotesView.module.css';

export default function NotesView() {
  const [notes, setNotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingNote, setEditingNote] = useState(null);

  const fetchNotes = useCallback(async () => {
    try {
      setLoading(true);
      const res = await getUserNotes();
      const list = Array.isArray(res?.data?.data) ? res.data.data : (Array.isArray(res?.data) ? res.data : []);
      // Parse resourceLinks which might be a JSON string from backend
      const parsedList = list.map(note => {
        let parsedLinks = [];
        if (typeof note.resourceLinks === 'string') {
          try {
            parsedLinks = JSON.parse(note.resourceLinks);
          } catch(e) {
            console.error('Failed to parse resourceLinks', e);
          }
        } else if (Array.isArray(note.resourceLinks)) {
          parsedLinks = note.resourceLinks;
        }
        return { ...note, resourceLinks: parsedLinks };
      });
      // Sort newest first
      const sorted = [...parsedList].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
      setNotes(sorted);
    } catch (err) {
      console.error(err);
      setError('Failed to load notes.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchNotes();
  }, [fetchNotes]);

  const handleDelete = async (id, e) => {
    e.stopPropagation();
    if (!window.confirm('Are you sure you want to delete this note?')) return;
    try {
      await deleteNote(id);
      setNotes(notes.filter(n => n.id !== id));
    } catch (err) {
      console.error(err);
      alert('Failed to delete note');
    }
  };

  const getTitleAndSnippet = (text) => {
    if (!text) return { title: 'Untitled Note', snippet: '' };
    const lines = text.split('\n').filter(l => l.trim() !== '');
    if (lines.length === 0) return { title: 'Untitled Note', snippet: '' };

    let title = lines[0];
    if (title.length > 50) title = title.substring(0, 50) + '...';

    const rest = text.substring(lines[0].length).trim();
    let snippet = rest.substring(0, 120);
    if (rest.length > 120) snippet += '...';

    return { title, snippet: snippet || title };
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    const d = new Date(dateString);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  if (loading) {
    return <div className={styles.loadingBox}>Loading your vault...</div>;
  }

  if (error) {
    return <div className={styles.errorBox}>{error}</div>;
  }

  return (
    <div className={styles.container}>
      <div className={styles.grid}>

        {/* New Note Button Card */}
        <div 
          className={styles.newNoteCard}
          onClick={() => {
            setEditingNote(null);
            setIsModalOpen(true);
          }}
        >
          <div className={styles.newNoteContent}>
            <div className={styles.plusIcon}>+</div>
            <span>New Note</span>
          </div>
        </div>

        {/* Existing Notes */}
        {notes.map(note => {
          const { title, snippet } = getTitleAndSnippet(note.content);

          return (
            <div key={note.id} className={styles.noteCard}>
              <div className={styles.cardHeader}>
                <div className={styles.headerLeft}>
                  <div className={styles.noteIconBox}>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                    </svg>
                  </div>
                  <button 
                    className={styles.editBtn}
                    onClick={() => {
                      setEditingNote(note);
                      setIsModalOpen(true);
                    }}
                    title="Edit Note"
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                    </svg>
                  </button>
                </div>
                <button 
                  className={styles.deleteBtn}
                  onClick={(e) => handleDelete(note.id, e)}
                  title="Delete Note"
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="3 6 5 6 21 6"></polyline>
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                    <line x1="10" y1="11" x2="10" y2="17"></line>
                    <line x1="14" y1="11" x2="14" y2="17"></line>
                  </svg>
                </button>
              </div>

              <div className={styles.noteContentArea}>
                <p className={styles.noteSnippet}>{snippet}</p>
              </div>

              <div className={styles.cardFooter}>
                <div className={styles.footerRow}>
                  <svg className={styles.footerIcon} style={{color: '#3b82f6'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
                    <line x1="7" y1="7" x2="7.01" y2="7"></line>
                  </svg>
                  <span>Skill: <span className={styles.footerValue}>{note.skillName || 'General'}</span></span>
                </div>
                
                {note.resourceLinks && note.resourceLinks.length > 0 && (
                  <div className={styles.footerRow}>
                    <svg className={styles.footerIcon} style={{color: '#8b5cf6'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                      <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                    </svg>
                    <a href={note.resourceLinks[0]} target="_blank" rel="noopener noreferrer" className={styles.resourceLink}>
                      {note.resourceLinks[0]}
                      <svg className={styles.externalIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
                        <polyline points="15 3 21 3 21 9"></polyline>
                        <line x1="10" y1="14" x2="21" y2="3"></line>
                      </svg>
                    </a>
                  </div>
                )}

                <div className={styles.footerRow}>
                  <svg className={styles.footerIcon} style={{color: '#10b981'}} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                  </svg>
                  <span>Day: <span className={styles.footerValue}>{note.dayNumber || '-'}</span></span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {isModalOpen && (
        <CreateNoteModal 
          roadmapId={editingNote?.roadmap?.id || null}
          dayNumber={editingNote?.dayNumber || null}
          skillName={editingNote?.skillName || ""}
          initialData={editingNote}
          onClose={() => {
            setIsModalOpen(false);
            setEditingNote(null);
          }}
          onSuccess={() => {
            fetchNotes();
          }}
        />
      )}
    </div>
  );
}
