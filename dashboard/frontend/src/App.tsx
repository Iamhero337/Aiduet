import React, { useState, useEffect, useRef } from 'react';
import { io, Socket } from 'socket.io-client';
import './App.css';

const TIER_OPTIONS = ['low', 'med', 'high'] as const;
type Tier = typeof TIER_OPTIONS[number];

function App() {
  const [task, setTask] = useState('');
  const [tier, setTier] = useState<Tier>('med');
  const [folder, setFolder] = useState(window.location.pathname || '');
  const [logs, setLogs] = useState<string[]>([]);
  const [geminiLogs, setGeminiLogs] = useState<string[]>([]);
  const [socket, setSocket] = useState<Socket | null>(null);

  const terminalRef = useRef<HTMLDivElement>(null);
  const geminiTerminalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const newSocket = io('http://localhost:3001');
    setSocket(newSocket);

    newSocket.on('output', (data: { type: string, data: string }) => {
      setLogs((prev) => [...prev, data.data]);
    });

    newSocket.on('gemini-log', (data: { data: string }) => {
      setGeminiLogs((prev) => [...prev, data.data]);
    });

    return () => {
      newSocket.close();
    };
  }, []);

  useEffect(() => {
    if (terminalRef.current) {
      terminalRef.current.scrollTop = terminalRef.current.scrollHeight;
    }
  }, [logs]);

  useEffect(() => {
    if (geminiTerminalRef.current) {
      geminiTerminalRef.current.scrollTop = geminiTerminalRef.current.scrollHeight;
    }
  }, [geminiLogs]);

  const runTask = () => {
    if (!task || !socket) return;
    setLogs([]);
    setGeminiLogs([]);
    socket.emit('run-task', { task, tier, folder });
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      runTask();
    }
  };

  return (
    <>
      <div className="header">
        <div className="input-row">
          <input
            placeholder="What do you want to build?"
            value={task}
            onChange={(e) => setTask(e.target.value)}
            onKeyPress={handleKeyPress}
          />
          <div className="tier-buttons">
            {TIER_OPTIONS.map((t) => (
              <button
                key={t}
                className={`${t} ${tier === t ? 'active' : ''}`}
                onClick={() => setTier(t)}
              >
                {t.toUpperCase()}
              </button>
            ))}
          </div>
          <button style={{ background: '#58a6ff', color: 'white' }} onClick={runTask}>
            RUN
          </button>
        </div>
        <div className="input-row">
          <input
            placeholder="Working Directory"
            value={folder}
            onChange={(e) => setFolder(e.target.value)}
          />
        </div>
      </div>

      <div className="main-view">
        <div className="pane">
          <div className="pane-header">Cloud Terminal (buildit)</div>
          <div className="terminal" ref={terminalRef}>
            {logs.join('')}
          </div>
        </div>
        <div className="pane gemini-pane">
          <div className="pane-header">Gemini Agent</div>
          <div className="terminal" ref={geminiTerminalRef}>
            {geminiLogs.join('')}
          </div>
        </div>
      </div>
    </>
  );
}

export default App;
