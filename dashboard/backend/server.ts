import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs';

const app = express();
app.use(cors());
app.use(express.json());

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: "http://localhost:5173",
    methods: ["GET", "POST"]
  }
});

const BUILDIT_PATH = path.resolve(__dirname, '../../buildit');

io.on('connection', (socket) => {
  console.log('Client connected');

  socket.on('run-task', (data) => {
    const { task, tier, folder } = data;
    const targetDir = path.resolve(folder || process.cwd());

    console.log(`Running task: "${task}" at tier: ${tier} in: ${targetDir}`);

    // Ensure the folder exists
    if (!fs.existsSync(targetDir)) {
      socket.emit('output', { type: 'stderr', data: `Error: Directory ${targetDir} does not exist.\r\n` });
      return;
    }

    const child = spawn('bash', [BUILDIT_PATH, tier, task], {
      cwd: targetDir,
      env: { ...process.env, FORCE_COLOR: '1' }
    });

    child.stdout.on('data', (data) => {
      socket.emit('output', { type: 'stdout', data: data.toString() });
    });

    child.stderr.on('data', (data) => {
      const output = data.toString();
      socket.emit('output', { type: 'stderr', data: output });

      // Identify Gemini-specific logs to send to the right pane
      // buildit uses log() which writes to stderr.
      // We can look for "gemini" in the output to route it.
      if (output.toLowerCase().includes('gemini')) {
        socket.emit('gemini-log', { data: output });
      }
    });

    child.on('close', (code) => {
      socket.emit('output', { type: 'system', data: `\r\nProcess exited with code ${code}\r\n` });
    });

    socket.on('disconnect', () => {
      child.kill();
    });
  });
});

const PORT = process.env.PORT || 3001;
httpServer.listen(PORT, () => {
  console.log(`Backend listening on port ${PORT}`);
});
